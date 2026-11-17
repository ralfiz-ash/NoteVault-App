import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/di/repository_providers.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/notes/domain/entities/note.dart';
import 'package:notevalult/features/notes/presentation/providers/folder_notes_provider.dart';
import 'package:notevalult/features/notes/presentation/providers/note_provider.dart';
import 'package:notevalult/features/notes/presentation/providers/notes_provider.dart';

import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late FakeNoteRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeNoteRepository();
    container = createContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(repository),
        signedInOverride(),
      ],
    );
  });

  group('notesProvider', () {
    test('loading, then data (an empty list is data, not an error)', () async {
      final states = <AsyncValue<List<Note>>>[];
      container.listen(
        notesProvider,
        (_, next) => states.add(next),
        fireImmediately: true,
      );

      expect(states.first, isA<AsyncLoading<List<Note>>>());
      await pumpEventQueue();
      expect(states.last, isA<AsyncData<List<Note>>>());
      expect(states.last.value, isEmpty);
    });

    test('updates when the repository changes', () async {
      container.listen(notesProvider, (_, _) {});
      await pumpEventQueue();

      repository.seed([buildNote(id: 'a')]);
      await pumpEventQueue();

      expect(container.read(notesProvider).value!.map((n) => n.id), ['a']);
    });

    test('errors become AsyncError and ref.invalidate retries', () async {
      repository.failingWatches = 1;
      container.listen(notesProvider, (_, _) {});
      await pumpEventQueue();

      expect(container.read(notesProvider).error, isA<LocalDatabaseFailure>());

      container.invalidate(notesProvider);
      await pumpEventQueue();

      final state = container.read(notesProvider);
      expect(state.hasError, isFalse);
      expect(state.value, isEmpty);
    });
  });

  group('noteProvider(id)', () {
    test('returns the note with the requested id', () async {
      repository.seed([buildNote(id: 'a', title: 'A'), buildNote(id: 'b')]);

      final note = await readFuture(container, noteProvider('a'));

      expect(note.id, 'a');
      expect(note.title, 'A');
    });

    test('each id is a separate provider instance', () {
      expect(noteProvider('a'), isNot(noteProvider('b')));
      expect(noteProvider('a'), noteProvider('a'));
    });

    test('NotFoundFailure for an unknown id', () async {
      await expectLater(
        readFuture(container, noteProvider('missing')),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('reacts when that note changes', () async {
      repository.seed([buildNote(id: 'a', title: 'Old')]);
      container.listen(noteProvider('a'), (_, _) {});
      await container.read(noteProvider('a').future);

      repository.seed([buildNote(id: 'a', title: 'New')]);
      await pumpEventQueue();

      expect(container.read(noteProvider('a')).value?.title, 'New');
    });

    test('is auto-disposed when nobody uses it', () async {
      repository.seed([buildNote(id: 'a')]);
      final sub = container.listen(noteProvider('a'), (_, _) {});
      await pumpEventQueue();
      expect(container.read(noteProvider('a').exists), isTrue);

      sub.close();
      await pumpEventQueue();
      expect(container.read(noteProvider('a').exists), isFalse);
    });
  });

  group('folderNotesProvider(folderId)', () {
    test('returns only the notes in that folder', () async {
      repository.seed([
        buildNote(id: 'a', folderId: 'work'),
        buildNote(id: 'b', folderId: 'home'),
        buildNote(id: 'c', folderId: 'work'),
        buildNote(id: 'd'),
      ]);

      final work = await readFuture(container, folderNotesProvider('work'));
      final home = await readFuture(container, folderNotesProvider('home'));

      expect(work.map((n) => n.id).toSet(), {'a', 'c'});
      expect(home.map((n) => n.id), ['b']);
    });

    test('reacts when a note moves into the folder', () async {
      repository.seed([buildNote(id: 'a')]);
      expect(await readFuture(container, folderNotesProvider('work')), isEmpty);

      repository.seed([buildNote(id: 'a', folderId: 'work')]);
      await pumpEventQueue();

      expect(
        container.read(folderNotesProvider('work')).value!.map((n) => n.id),
        ['a'],
      );
    });
  });
}
