import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/di/repository_providers.dart';
import 'package:notevalult/app/provider_retry.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/folders/presentation/providers/folders_provider.dart';
import 'package:notevalult/features/notes/domain/entities/note.dart';
import 'package:notevalult/features/notes/domain/entities/note_query.dart';
import 'package:notevalult/features/notes/domain/entities/note_sort.dart';
import 'package:notevalult/features/notes/presentation/providers/notes_filter_provider.dart';
import 'package:notevalult/features/settings/domain/entities/app_settings.dart';
import 'package:notevalult/features/settings/presentation/providers/settings_provider.dart';
import 'package:notevalult/features/tags/domain/entities/tag.dart';
import 'package:notevalult/features/tags/presentation/providers/tags_provider.dart';

import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/test_helpers.dart';

/// Counts how often each provider produced a new value.
final class _UpdateCounter extends ProviderObserver {
  final counts = <String, int>{};

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    final name = context.provider.name ?? '?';
    counts[name] = (counts[name] ?? 0) + 1;
  }

  void reset() => counts.clear();
}

void main() {
  late FakeNoteRepository notes;

  List<Override> overrides({Duration debounce = Duration.zero}) => [
    noteRepositoryProvider.overrideWithValue(notes),
    folderRepositoryProvider.overrideWithValue(FakeFolderRepository()),
    tagRepositoryProvider.overrideWithValue(
      FakeTagRepository(const [Tag(id: 'ti', name: 'Important')]),
    ),
    searchDebounceProvider.overrideWithValue(debounce),
    settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
    signedInOverride(),
  ];

  setUp(() {
    notes = FakeNoteRepository()
      ..seed([
        buildNote(
          id: 'a',
          title: 'Flutter plan',
          folderId: 'work',
          tags: ['Important'],
          updatedAt: DateTime.utc(2026, 3),
        ),
        buildNote(id: 'b', title: 'Budget', folderId: 'work'),
        buildNote(id: 'c', title: 'Recipes', content: 'flutter-free cake'),
      ]);
  });

  group('debounced search', () {
    test('rapid input applies only the final value after the pause', () {
      fakeAsync((async) {
        final container = ProviderContainer(
          overrides: overrides(debounce: const Duration(milliseconds: 300)),
          retry: providerRetry,
        );
        addTearDown(container.dispose);
        final applied = <String>[];
        container.listen(
          noteSearchControllerProvider,
          (_, next) => applied.add(next),
        );
        final search = container.read(noteSearchControllerProvider.notifier);

        for (final text in ['f', 'fl', 'flu', 'flut', 'flutt', 'flutter']) {
          search.onInput(text);
          async.elapse(const Duration(milliseconds: 100));
        }
        expect(applied, isEmpty); // still typing: previous timers cancelled

        async.elapse(const Duration(milliseconds: 300));
        expect(applied, ['flutter']);
        expect(container.read(noteSearchControllerProvider), 'flutter');

        // Same text again: no new state.
        search.onInput(' flutter ');
        async.elapse(const Duration(seconds: 1));
        expect(applied, ['flutter']);
      });
    });

    test('setNow applies immediately and cancels a pending search', () {
      fakeAsync((async) {
        final container = ProviderContainer(
          overrides: overrides(debounce: const Duration(milliseconds: 300)),
        );
        addTearDown(container.dispose);
        container.listen(noteSearchControllerProvider, (_, _) {});
        final search = container.read(noteSearchControllerProvider.notifier);

        search.onInput('flu');
        search.setNow('');
        async.elapse(const Duration(seconds: 1));
        expect(container.read(noteSearchControllerProvider), '');
      });
    });

    test('disposing cancels the pending timer', () {
      fakeAsync((async) {
        final container = ProviderContainer(
          overrides: overrides(debounce: const Duration(milliseconds: 300)),
        );
        final sub = container.listen(noteSearchControllerProvider, (_, _) {});
        container.read(noteSearchControllerProvider.notifier).onInput('x');
        expect(async.pendingTimers, hasLength(1));

        sub.close();
        container.dispose();
        expect(async.pendingTimers, isEmpty);
      });
    });
  });

  group('central filtered list', () {
    late ProviderContainer container;
    setUp(() {
      container = createContainer(overrides: overrides());
      container.listen(filteredNotesProvider, (_, _) {});
    });

    Future<List<String>> ids() async => [
      for (final n in await readFuture(container, filteredNotesProvider)) n.id,
    ];

    test('search + folder + tag + sort combine', () async {
      expect((await ids()).first, 'a'); // default: recently edited first

      container.read(noteSearchControllerProvider.notifier).setNow('FLUTTER');
      expect((await ids()).toSet(), {'a', 'c'});

      container
          .read(notesFilterControllerProvider.notifier)
          .setFolder(const InFolder('work'));
      expect(await ids(), ['a']);

      container.read(notesFilterControllerProvider.notifier)
        ..setFolder(const AnyFolder())
        ..setTag('ti');
      await pumpEventQueue();
      expect(await ids(), ['a']);

      container.read(notesFilterControllerProvider.notifier).clear();
      container.read(noteSearchControllerProvider.notifier).setNow('');
      await container
          .read(settingsProvider.notifier)
          .setNoteSort(
            const NoteSort(field: NoteSortField.title, ascending: true),
          );
      expect(await ids(), ['b', 'a', 'c']);
    });

    test('empty source vs empty filtered result are distinguishable', () async {
      container.read(noteSearchControllerProvider.notifier).setNow('kotlin');
      expect(await ids(), isEmpty);
      expect(container.read(noteQueryProvider).hasFilters, isTrue);
    });

    test('errors stay errors (not an empty list)', () async {
      final failing = FakeNoteRepository()..failingWatches = 1;
      final c = createContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(failing),
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(),
          ),
          signedInOverride(),
        ],
      );
      c.listen(filteredNotesProvider, (_, _) {});
      await pumpEventQueue();
      await pumpEventQueue();
      final state = c.read(filteredNotesProvider);
      expect(state.hasError, isTrue);
      expect(state.error, isA<LocalDatabaseFailure>());
    });
  });

  group('folder counts come from the same notes', () {
    test('create, move, remove folder, delete and folder deletion', () async {
      final container = createContainer(overrides: overrides());
      container.listen(folderNoteCountsProvider, (_, _) {});
      container.listen(filteredNotesProvider, (_, _) {});
      await readFuture(container, filteredNotesProvider);
      expect(container.read(folderNoteCountsProvider), {'work': 2, null: 1});

      await notes.createNote(buildNote(id: 'd', folderId: 'home'));
      await notes.updateNote(buildNote(id: 'b', folderId: 'home'));
      await notes.updateNote(buildNote(id: 'a')); // removed from its folder
      await pumpEventQueue();
      expect(container.read(folderNoteCountsProvider), {'home': 2, null: 2});

      await notes.deleteNote('c');
      for (final id in ['d', 'b']) {
        notes.seed([(await notes.getNote(id)).copyWith(folderId: () => null)]);
      }
      await pumpEventQueue();
      expect(container.read(folderNoteCountsProvider), {null: 3});
      // The list and the counts agree.
      expect(
        (await readFuture(container, filteredNotesProvider)).length,
        container.read(folderNoteCountsProvider).values.reduce((a, b) => a + b),
      );
    });
  });

  group('rebuild scoping', () {
    late _UpdateCounter counter;
    late ProviderContainer container;

    setUp(() async {
      counter = _UpdateCounter();
      container = ProviderContainer(
        overrides: overrides(),
        observers: [counter],
        retry: providerRetry,
      );
      addTearDown(container.dispose);
      container
        ..listen(filteredNotesProvider, (_, _) {})
        ..listen(folderNoteCountsProvider, (_, _) {})
        ..listen(tagsProvider, (_, _) {});
      await readFuture(container, filteredNotesProvider);
      await readFuture(container, tagsProvider);
      await pumpEventQueue();
      counter.reset();
    });

    int updates(String name) => counter.counts[name] ?? 0;

    test('theme change does not recompute the list', () async {
      await container
          .read(settingsProvider.notifier)
          .setThemeMode(ThemeModePreference.dark);
      await pumpEventQueue();
      expect(updates('noteQueryProvider'), 0);
      expect(updates('filteredNotesProvider'), 0);
    });

    test('search changes the list but not the folder counts', () async {
      container.read(noteSearchControllerProvider.notifier).setNow('flutter');
      await pumpEventQueue();
      expect(updates('filteredNotesProvider'), 1);
      expect(updates('folderNoteCountsProvider'), 0);
    });

    test('sort changes the list but not the counts', () async {
      await container
          .read(settingsProvider.notifier)
          .setNoteSort(const NoteSort(field: NoteSortField.title));
      await pumpEventQueue();
      expect(updates('filteredNotesProvider'), 1);
      expect(updates('folderNoteCountsProvider'), 0);
    });

    test('a tag colour change does not recompute the tag filter', () async {
      container.read(notesFilterControllerProvider.notifier).setTag('ti');
      await pumpEventQueue();
      counter.reset();

      container.listen(tagActionsProvider, (_, _) {});
      await container
          .read(tagActionsProvider.notifier)
          .edit(const Tag(id: 'ti', name: 'Important', colorValue: '#C0392B'));
      await pumpEventQueue();

      expect(updates('tagsProvider'), greaterThan(0));
      expect(updates('noteQueryProvider'), 0);
      expect(updates('filteredNotesProvider'), 0);
    });
  });

  test('NoteQuery equality avoids needless updates', () {
    expect(const NoteQuery(search: 'x'), isNot(const NoteQuery(search: 'y')));
    const q = NoteQuery(search: 'x');
    expect(q.apply(<Note>[]), isEmpty);
  });
}
