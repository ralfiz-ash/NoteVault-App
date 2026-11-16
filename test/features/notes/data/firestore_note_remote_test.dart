import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/core/firebase/firestore_exception_mapper.dart';
import 'package:notevalult/features/notes/data/datasources/firestore_note_remote_data_source.dart';
import 'package:notevalult/features/notes/data/datasources/note_firestore_mapper.dart';
import 'package:notevalult/features/notes/data/datasources/note_remote_data_source.dart';
import 'package:notevalult/features/notes/data/models/note_model.dart';
import 'package:notevalult/features/notes/data/repositories/note_remote_repository_impl.dart';

import '../../../helpers/fixtures.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late NoteRemoteRepositoryImpl repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = NoteRemoteRepositoryImpl(
      remote: FirestoreNoteRemoteDataSource(firestore: firestore),
      exceptionMapper: const FirestoreExceptionMapper(),
    );
  });

  group('document mapping', () {
    final note = buildNote(
      folderId: 'f1',
      tags: ['a', 'b'],
      createdAt: DateTime.utc(2026, 1, 2, 3, 4, 5, 678),
      updatedAt: DateTime.utc(2026, 2, 1),
    );

    test('timestamps are Firestore Timestamps in the document', () {
      final doc = NoteFirestoreMapper.toDocument(NoteModel.fromEntity(note));
      expect(doc['createdAt'], isA<Timestamp>());
      expect(doc['tags'], ['a', 'b']);
      expect(doc['folderId'], 'f1');
    });

    test('round trip returns UTC DateTimes and the same note', () {
      final doc = NoteFirestoreMapper.toDocument(NoteModel.fromEntity(note));
      final back = NoteFirestoreMapper.fromDocument(note.id, doc).toEntity();

      expect(back, note);
      expect(back.createdAt.isUtc, isTrue);
    });

    test('a local-time DateTime is stored as the same instant', () {
      final local = DateTime(2026, 5, 5, 10);
      final doc = NoteFirestoreMapper.toDocument(
        NoteModel.fromEntity(buildNote(createdAt: local, updatedAt: local)),
      );
      final back = NoteFirestoreMapper.fromDocument('note-1', doc);

      expect(back.createdAt.isUtc, isTrue);
      expect(back.createdAt.isAtSameMomentAs(local), isTrue);
    });
  });

  group('repository CRUD against Firestore (fake)', () {
    test('notes are stored under users/{uid}/notes/{id}', () async {
      await repository.createNote('alice', buildNote());

      final doc = await firestore.doc('users/alice/notes/note-1').get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['title'], 'Title');
    });

    test('create, get, list, update, delete', () async {
      final note = buildNote(tags: ['x']);
      expect(await repository.createNote('alice', note), note);
      await repository.createNote(
        'alice',
        buildNote(id: 'note-2', updatedAt: DateTime.utc(2026, 6)),
      );

      expect(await repository.getNote('alice', 'note-1'), note);
      expect(
        (await repository.getNotes('alice')).map((n) => n.id),
        ['note-2', 'note-1'], // newest edit first
      );

      final edited = note.copyWith(
        title: 'Edited',
        updatedAt: DateTime.utc(2026, 7),
      );
      expect(await repository.updateNote('alice', edited), edited);

      await repository.deleteNote('alice', 'note-1');
      await expectLater(
        repository.getNote('alice', 'note-1'),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('values are stored exactly as given (no timestamp changes)', () async {
      final note = buildNote(updatedAt: DateTime.utc(2020));
      await repository.createNote('alice', note);
      expect(
        (await repository.getNote('alice', 'note-1')).updatedAt,
        DateTime.utc(2020),
      );
    });

    test("users cannot see each other's notes", () async {
      await repository.createNote('alice', buildNote());
      expect(await repository.getNotes('bob'), isEmpty);
    });

    test('duplicate create -> RemoteFailure; missing -> NotFound', () async {
      await repository.createNote('alice', buildNote());
      await expectLater(
        repository.createNote('alice', buildNote()),
        throwsA(isA<RemoteFailure>()),
      );
      await expectLater(
        repository.updateNote('alice', buildNote(id: 'nope')),
        throwsA(isA<NotFoundFailure>()),
      );
      await expectLater(
        repository.deleteNote('alice', 'nope'),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('watchNotes emits on changes', () async {
      final counts = <int>[];
      final sub = repository
          .watchNotes('alice')
          .listen((n) => counts.add(n.length));
      addTearDown(sub.cancel);

      await pumpEventQueue();
      await repository.createNote('alice', buildNote());
      await pumpEventQueue();

      expect(counts.first, 0);
      expect(counts.last, 1);
    });
  });

  test('Firestore errors become application failures', () async {
    final repo = NoteRemoteRepositoryImpl(
      remote: _ThrowingRemote(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      ),
      exceptionMapper: const FirestoreExceptionMapper(),
    );

    await expectLater(repo.getNotes('alice'), throwsA(isA<RemoteFailure>()));
    await expectLater(
      repo.watchNotes('alice'),
      emitsError(isA<RemoteFailure>()),
    );
  });
}

class _ThrowingRemote implements NoteRemoteDataSource {
  _ThrowingRemote(this.error);
  final Object error;

  @override
  Stream<List<NoteModel>> watchNotes(String userId) => Stream.error(error);
  @override
  Future<List<NoteModel>> getNotes(String userId) => Future.error(error);
  @override
  Future<NoteModel?> getNote(String userId, String noteId) =>
      Future.error(error);
  @override
  Future<bool> createNote(String userId, NoteModel note) => Future.error(error);
  @override
  Future<bool> updateNote(String userId, NoteModel note) => Future.error(error);
  @override
  Future<bool> deleteNote(String userId, String noteId) => Future.error(error);
}
