import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/di/database_providers.dart';
import 'package:notevalult/app/di/repository_providers.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/notes/presentation/providers/note_mutations_provider.dart';
import 'package:notevalult/features/notes/presentation/providers/notes_provider.dart';
import 'package:notevalult/features/notes/presentation/state/note_mutation_result.dart';

import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/sequence_id_generator.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late FakeNoteRepository repository;
  late ProviderContainer container;
  late List<AsyncValue<NoteMutationResult?>> states;

  setUp(() {
    repository = FakeNoteRepository(clock: () => DateTime.utc(2026, 12));
    container = createContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(repository),
        idGeneratorProvider.overrideWithValue(SequenceIdGenerator()),
        clockProvider.overrideWithValue(() => fixedNow),
      ],
    );
    states = [];
    // A listener keeps the auto-disposed notifier alive, as a screen would.
    container.listen(
      noteMutationsProvider,
      (_, next) => states.add(next),
      fireImmediately: true,
    );
  });

  NoteMutations notifier() => container.read(noteMutationsProvider.notifier);

  test('starts idle', () {
    expect(states.single, const AsyncData<NoteMutationResult?>(null));
  });

  test(
    'create: loading then success, with generated id and timestamps',
    () async {
      final note = await notifier().createNote(
        title: 'T',
        content: 'C',
        tags: ['x'],
      );

      expect(note!.id, 'id-1');
      expect(note.createdAt, fixedNow);
      expect(note.updatedAt, fixedNow);
      expect(repository.calls, ['create:id-1']);
      expect(states[1], isA<AsyncLoading<NoteMutationResult?>>());
      expect(
        states.last.value,
        const NoteMutationResult(NoteMutationKind.created, 'id-1'),
      );
    },
  );

  test('update goes through the repository', () async {
    repository.seed([buildNote(id: 'n', title: 'Old')]);

    final saved = await notifier().updateNote(buildNote(id: 'n', title: 'New'));

    expect(saved!.title, 'New');
    expect(saved.updatedAt, DateTime.utc(2026, 12)); // stamped by repository
    expect(states.last.value?.kind, NoteMutationKind.updated);
  });

  test('delete goes through the repository', () async {
    repository.seed([buildNote(id: 'n')]);

    await notifier().deleteNote('n');

    expect(repository.calls, ['delete:n']);
    expect(
      states.last.value,
      const NoteMutationResult(NoteMutationKind.deleted, 'n'),
    );
  });

  test('a failure becomes AsyncError and returns null', () async {
    repository.nextMutationError = const LocalDatabaseFailure();

    final note = await notifier().createNote(title: 'T', content: 'C');

    expect(note, isNull);
    expect(states.last.error, isA<LocalDatabaseFailure>());
  });

  test('missing note on update -> AsyncError(NotFoundFailure)', () async {
    await notifier().updateNote(buildNote(id: 'ghost'));
    expect(states.last.error, isA<NotFoundFailure>());
  });

  test('the notes list reflects mutations without manual refresh', () async {
    container.listen(notesProvider, (_, _) {});
    await notifier().createNote(title: 'T', content: 'C');
    await pumpEventQueue();

    expect(container.read(notesProvider).value!.map((n) => n.id), ['id-1']);
  });
}
