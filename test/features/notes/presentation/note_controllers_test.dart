import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/di/database_providers.dart';
import 'package:notevalult/app/di/repository_providers.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/notes/domain/entities/note.dart';
import 'package:notevalult/features/notes/domain/entities/note_draft.dart';
import 'package:notevalult/features/notes/presentation/providers/create_note_controller.dart';
import 'package:notevalult/features/notes/presentation/providers/delete_note_controller.dart';
import 'package:notevalult/features/notes/presentation/providers/note_provider.dart';
import 'package:notevalult/features/notes/presentation/providers/notes_provider.dart';
import 'package:notevalult/features/notes/presentation/providers/update_note_controller.dart';
import 'package:notevalult/features/notes/presentation/providers/visible_notes_provider.dart';

import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/sequence_id_generator.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late FakeNoteRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = FakeNoteRepository(clock: () => DateTime.utc(2026, 12));
    container = createContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(repo),
        idGeneratorProvider.overrideWithValue(SequenceIdGenerator()),
        clockProvider.overrideWithValue(() => fixedNow),
        signedInOverride(),
      ],
    );
    container.listen(visibleNotesProvider, (_, _) {});
  });

  List<String> visibleIds() =>
      container.read(visibleNotesProvider).value!.map((n) => n.id).toList();

  group('CreateNoteController', () {
    test('idle -> loading -> created; list updates', () async {
      container.listen(createNoteControllerProvider, (_, _) {});
      expect(container.read(createNoteControllerProvider).value, isNull);

      final gate = repo.gate = Completer<void>();
      final future = container
          .read(createNoteControllerProvider.notifier)
          .create(const NoteDraft(title: 'T'));
      expect(container.read(createNoteControllerProvider).isLoading, isTrue);

      gate.complete();
      final note = await future;
      await pumpEventQueue();

      expect(note!.id, 'id-1');
      expect(container.read(createNoteControllerProvider).value, note);
      expect(visibleIds(), ['id-1']);
    });

    test('error state on failure; nothing added', () async {
      container.listen(createNoteControllerProvider, (_, _) {});
      repo.nextMutationError = const LocalDatabaseFailure();

      final note = await container
          .read(createNoteControllerProvider.notifier)
          .create(const NoteDraft(title: 'T'));
      await pumpEventQueue();

      expect(note, isNull);
      expect(
        container.read(createNoteControllerProvider).error,
        isA<LocalDatabaseFailure>(),
      );
      expect(visibleIds(), isEmpty);
    });
  });

  group('UpdateNoteController', () {
    late Note original;
    setUp(() {
      original = buildNote(
        id: 'n',
        title: 'Old',
        createdAt: DateTime.utc(2026),
      );
      repo.seed([original]);
      container.listen(updateNoteControllerProvider, (_, _) {});
      container.listen(noteProvider('n'), (_, _) {});
    });

    test('loading -> saved; list and noteProvider(id) update', () async {
      final gate = repo.gate = Completer<void>();
      final future = container
          .read(updateNoteControllerProvider.notifier)
          .save(original, const NoteDraft(title: 'New', tags: ['x']));
      expect(container.read(updateNoteControllerProvider).isLoading, isTrue);

      gate.complete();
      final saved = await future;
      await pumpEventQueue();

      expect(saved!.title, 'New');
      expect(saved.createdAt, DateTime.utc(2026));
      expect(saved.updatedAt, DateTime.utc(2026, 12));
      expect(container.read(noteProvider('n')).value!.title, 'New');
      expect(container.read(visibleNotesProvider).value!.single.tags, ['x']);
    });

    test('error leaves the stored note unchanged', () async {
      repo.nextMutationError = const LocalDatabaseFailure();
      final saved = await container
          .read(updateNoteControllerProvider.notifier)
          .save(original, const NoteDraft(title: 'New'));
      await pumpEventQueue();

      expect(saved, isNull);
      expect(
        container.read(updateNoteControllerProvider).error,
        isA<LocalDatabaseFailure>(),
      );
      expect(container.read(noteProvider('n')).value!.title, 'Old');
    });
  });

  group('DeleteNoteController (optimistic)', () {
    setUp(() {
      repo.seed([buildNote(id: 'a'), buildNote(id: 'b')]);
      container.listen(deleteNoteControllerProvider, (_, _) {});
    });

    test('hidden immediately, gone after success', () async {
      final gate = repo.gate = Completer<void>();
      final future = container
          .read(deleteNoteControllerProvider.notifier)
          .delete('a');
      await pumpEventQueue();
      expect(visibleIds(), ['b']); // before the database finished
      expect(container.read(notesProvider).value!.length, 2);

      gate.complete();
      expect(await future, isTrue);
      await pumpEventQueue();

      expect(visibleIds(), ['b']);
      expect(container.read(notesProvider).value!.length, 1);
      expect(container.read(deleteNoteControllerProvider).value, 'a');
    });

    test('failure rolls back and reports the error', () async {
      final gate = repo.gate = Completer<void>();
      repo.nextMutationError = const LocalDatabaseFailure();
      final future = container
          .read(deleteNoteControllerProvider.notifier)
          .delete('a');
      await pumpEventQueue();
      expect(visibleIds(), ['b']); // optimistic

      gate.complete();
      expect(await future, isFalse);
      await pumpEventQueue();

      expect(visibleIds().toSet(), {'a', 'b'}); // restored
      expect(
        container.read(deleteNoteControllerProvider).error,
        isA<LocalDatabaseFailure>(),
      );
    });

    test('noteProvider(id) reports NotFound after deletion', () async {
      expect((await readFuture(container, noteProvider('a'))).id, 'a');
      await container.read(deleteNoteControllerProvider.notifier).delete('a');
      await pumpEventQueue();
      await pumpEventQueue();
      final state = container.read(noteProvider('a'));
      expect(state.error, isA<NotFoundFailure>(), reason: '$state');
    });
  });
}
