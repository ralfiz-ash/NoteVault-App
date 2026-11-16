import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/database/local_database_exception_mapper.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/notes/data/datasources/drift_note_local_data_source.dart';
import 'package:notevalult/features/notes/data/datasources/note_local_data_source.dart';
import 'package:notevalult/features/notes/data/models/note_model.dart';
import 'package:notevalult/features/notes/data/repositories/note_repository_impl.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/sequence_id_generator.dart';
import '../../../helpers/test_database.dart';

/// A data source whose every call fails, to test failure conversion.
class _ThrowingNoteDataSource implements NoteLocalDataSource {
  _ThrowingNoteDataSource(this.error);

  final Object error;

  @override
  Stream<List<NoteModel>> watchNotes() => Stream.error(error);
  @override
  Future<List<NoteModel>> getNotes() => Future.error(error);
  @override
  Future<NoteModel?> getNote(String id) => Future.error(error);
  @override
  Future<void> insertNote(NoteModel note) => Future.error(error);
  @override
  Future<bool> updateNote(NoteModel note) => Future.error(error);
  @override
  Future<bool> deleteNote(String id) => Future.error(error);
}

void main() {
  late NoteRepositoryImpl repository;
  var now = fixedNow;

  setUp(() {
    now = fixedNow;
    repository = NoteRepositoryImpl(
      local: DriftNoteLocalDataSource(
        database: createTestDatabase(),
        idGenerator: SequenceIdGenerator(),
      ),
      exceptionMapper: const LocalDatabaseExceptionMapper(),
      clock: () => now,
    );
  });

  group('create / read', () {
    test('a created note can be read back by id and in the list', () async {
      final note = buildNote(title: 'A', tags: ['x']);

      final created = await repository.createNote(note);

      expect(created, note);
      expect(await repository.getNote('note-1'), note);
      expect(await repository.getNotes(), [note]);
    });

    test('reads multiple notes, newest edit first', () async {
      await repository.createNote(buildNote(id: 'a'));
      await repository.createNote(
        buildNote(id: 'b', updatedAt: DateTime.utc(2026, 5)),
      );

      final notes = await repository.getNotes();
      expect(notes.map((n) => n.id), ['b', 'a']);
    });

    test('getNote throws NotFoundFailure for an unknown id', () async {
      await expectLater(
        repository.getNote('missing'),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('creating a duplicate id throws LocalDatabaseFailure', () async {
      await repository.createNote(buildNote());
      await expectLater(
        repository.createNote(buildNote()),
        throwsA(isA<LocalDatabaseFailure>()),
      );
    });
  });

  group('update', () {
    test('changes data, keeps id and createdAt, stamps updatedAt', () async {
      final original = buildNote(
        title: 'Old',
        createdAt: DateTime.utc(2026, 1, 1),
      );
      await repository.createNote(original);
      now = DateTime.utc(2026, 11, 20, 9);

      final saved = await repository.updateNote(
        // Caller tries to rewrite createdAt and pass a stale updatedAt.
        buildNote(
          title: 'New',
          content: 'Edited',
          tags: ['t'],
          createdAt: DateTime.utc(1999),
          updatedAt: DateTime.utc(2000),
        ),
      );

      expect(saved.id, 'note-1');
      expect(saved.title, 'New');
      expect(saved.content, 'Edited');
      expect(saved.tags, ['t']);
      expect(saved.createdAt, original.createdAt);
      expect(saved.updatedAt, now);
      expect(await repository.getNote('note-1'), saved);
    });

    test('throws NotFoundFailure when the note does not exist', () async {
      await expectLater(
        repository.updateNote(buildNote(id: 'missing')),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  group('delete', () {
    test('removes the note so it can no longer be read', () async {
      await repository.createNote(buildNote());

      await repository.deleteNote('note-1');

      await expectLater(
        repository.getNote('note-1'),
        throwsA(isA<NotFoundFailure>()),
      );
      expect(await repository.getNotes(), isEmpty);
    });

    test('throws NotFoundFailure when the note does not exist', () async {
      await expectLater(
        repository.deleteNote('missing'),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });

  test('watchNotes emits the latest list after changes', () async {
    final emissions = <int>[];
    final sub = repository.watchNotes().listen((n) => emissions.add(n.length));
    addTearDown(sub.cancel);

    await pumpEventQueue();
    await repository.createNote(buildNote());
    await pumpEventQueue();

    expect(emissions.first, 0);
    expect(emissions.last, 1);
  });

  group('failure handling', () {
    NoteRepositoryImpl failingRepository(Object error) => NoteRepositoryImpl(
      local: _ThrowingNoteDataSource(error),
      exceptionMapper: const LocalDatabaseExceptionMapper(),
      clock: () => fixedNow,
    );

    test(
      'datasource errors become LocalDatabaseFailure with the cause',
      () async {
        final repo = failingRepository(StateError('disk full'));

        for (final call in <Future<Object?> Function()>[
          repo.getNotes,
          () => repo.getNote('x'),
          () => repo.createNote(buildNote()),
          () => repo.updateNote(buildNote()),
          () => repo.deleteNote('x'),
        ]) {
          await expectLater(
            call(),
            throwsA(
              isA<LocalDatabaseFailure>().having(
                (f) => f.cause,
                'cause',
                isA<StateError>(),
              ),
            ),
          );
        }
      },
    );

    test('stream errors become LocalDatabaseFailure', () async {
      final repo = failingRepository(StateError('boom'));
      await expectLater(
        repo.watchNotes(),
        emitsError(isA<LocalDatabaseFailure>()),
      );
    });

    test('an existing Failure is passed through unchanged', () async {
      final repo = failingRepository(const AuthFailure());
      await expectLater(repo.getNotes(), throwsA(isA<AuthFailure>()));
    });
  });
}
