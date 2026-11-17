import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/database/app_database.dart';
import 'package:notevalult/core/database/local_database_exception_mapper.dart';
import 'package:notevalult/core/database/local_transaction.dart';
import 'package:notevalult/core/database/sync_queue_store.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/core/firebase/firestore_exception_mapper.dart';
import 'package:notevalult/features/folders/data/datasources/drift_folder_local_data_source.dart';
import 'package:notevalult/features/folders/data/repositories/folder_repository_impl.dart';
import 'package:notevalult/features/notes/data/datasources/drift_note_local_data_source.dart';
import 'package:notevalult/features/notes/data/datasources/firestore_note_remote_data_source.dart';
import 'package:notevalult/features/notes/data/repositories/note_remote_repository_impl.dart';
import 'package:notevalult/features/notes/data/repositories/note_repository_impl.dart';
import 'package:notevalult/features/notes/domain/entities/note.dart';
import 'package:notevalult/features/notes/domain/repositories/note_remote_repository.dart';
import 'package:notevalult/features/sync/data/repositories/sync_repository_impl.dart';
import 'package:notevalult/features/tags/data/datasources/drift_tag_local_data_source.dart';
import 'package:notevalult/features/tags/data/repositories/tag_repository_impl.dart';
import 'package:notevalult/features/tags/domain/entities/tag.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/sequence_id_generator.dart';

const uid = 'alice';

/// The real Firestore remote (on a fake Firestore) with switchable failures
/// and an upload gate, counting calls per note.
class _ControlledRemote implements NoteRemoteRepository {
  _ControlledRemote(this.inner);

  final NoteRemoteRepository inner;
  Failure? failWith;
  Completer<void>? gate;
  final uploads = <String, int>{};

  Future<void> _before(String id) async {
    uploads[id] = (uploads[id] ?? 0) + 1;
    final wait = gate;
    if (wait != null) await wait.future;
    final failure = failWith;
    if (failure != null) throw failure;
  }

  @override
  Future<void> upsertNote(String userId, Note note) async {
    await _before(note.id);
    await inner.upsertNote(userId, note);
  }

  @override
  Future<void> deleteNoteIfExists(String userId, String noteId) async {
    await _before(noteId);
    await inner.deleteNoteIfExists(userId, noteId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// One "app session" on a database file.
class _Session {
  _Session(File file, this.firestore, {_ControlledRemote? remote})
    : db = AppDatabase(NativeDatabase(file)) {
    queue = SyncQueueStore(db, () => fixedNow);
    final runner = DriftTransactionRunner(db);
    notes = NoteRepositoryImpl(
      local: DriftNoteLocalDataSource(
        database: db,
        idGenerator: SequenceIdGenerator(),
      ),
      exceptionMapper: const LocalDatabaseExceptionMapper(),
      clock: () => DateTime.utc(2026, 12),
      outbox: queue,
      transactions: runner,
    );
    folders = FolderRepositoryImpl(
      local: DriftFolderLocalDataSource(database: db),
      exceptionMapper: const LocalDatabaseExceptionMapper(),
      outbox: queue,
      transactions: runner,
    );
    tags = TagRepositoryImpl(
      local: DriftTagLocalDataSource(database: db),
      exceptionMapper: const LocalDatabaseExceptionMapper(),
      outbox: queue,
      transactions: runner,
    );
    this.remote =
        remote ??
        _ControlledRemote(
          NoteRemoteRepositoryImpl(
            remote: FirestoreNoteRemoteDataSource(firestore: firestore),
            exceptionMapper: const FirestoreExceptionMapper(),
          ),
        );
    sync = SyncRepositoryImpl(
      queue: queue,
      localNotes: notes,
      remoteNotes: this.remote,
    );
  }

  final AppDatabase db;
  final FakeFirebaseFirestore firestore;
  late final SyncQueueStore queue;
  late final NoteRepositoryImpl notes;
  late final FolderRepositoryImpl folders;
  late final TagRepositoryImpl tags;
  late final _ControlledRemote remote;
  late final SyncRepositoryImpl sync;

  Future<Map<String, Object?>?> cloudDoc(String id) async =>
      (await firestore.doc('users/$uid/notes/$id').get()).data();

  Future<int> cloudCount() async =>
      (await firestore.collection('users/$uid/notes').get()).size;
}

void main() {
  late Directory dir;
  late File file;
  late FakeFirebaseFirestore firestore;
  late _Session s;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('notevault_sync');
    file = File('${dir.path}/db.sqlite');
    firestore = FakeFirebaseFirestore();
    s = _Session(file, firestore);
  });

  tearDown(() async {
    await s.db.close();
    dir.deleteSync(recursive: true);
  });

  group('offline changes are local first and queued', () {
    test('create: note saved and CREATE queued', () async {
      await s.notes.createNote(buildNote(id: 'n', title: 'Offline'));
      expect((await s.notes.getNote('n')).title, 'Offline');
      final q = (await s.queue.all()).single;
      expect(q.operation, SyncOperation.create);
      expect(await s.cloudDoc('n'), isNull); // nothing sent
    });

    test('edit: local updated, queue holds one entry for the latest', () async {
      await s.notes.createNote(buildNote(id: 'n'));
      await s.notes.updateNote(buildNote(id: 'n', title: 'v2'));
      await s.notes.updateNote(buildNote(id: 'n', title: 'v3'));

      expect((await s.notes.getNote('n')).title, 'v3');
      expect(await s.queue.all(), hasLength(1));
    });

    test(
      'delete of a synced note keeps a DELETE after the row is gone',
      () async {
        await s.notes.createNote(buildNote(id: 'n'));
        await s.sync.syncPendingChanges(uid);
        expect(await s.cloudDoc('n'), isNotNull);

        await s.notes.deleteNote('n');
        await expectLater(
          s.notes.getNote('n'),
          throwsA(isA<NotFoundFailure>()),
        );
        expect((await s.queue.all()).single.operation, SyncOperation.delete);

        await s.sync.syncPendingChanges(uid);
        expect(await s.cloudDoc('n'), isNull);
        expect(await s.queue.all(), isEmpty);
      },
    );

    test('the note change and its queue entry are one transaction', () async {
      final notes = NoteRepositoryImpl(
        local: DriftNoteLocalDataSource(
          database: s.db,
          idGenerator: SequenceIdGenerator(),
        ),
        exceptionMapper: const LocalDatabaseExceptionMapper(),
        clock: () => fixedNow,
        outbox: _BrokenOutbox(),
        transactions: DriftTransactionRunner(s.db),
      );
      await expectLater(
        notes.createNote(buildNote(id: 'x')),
        throwsA(isA<Failure>()),
      );
      await expectLater(notes.getNote('x'), throwsA(isA<NotFoundFailure>()));
    });
  });

  group('sync', () {
    test(
      'success uploads the latest local state and clears the queue',
      () async {
        await s.notes.createNote(buildNote(id: 'n', title: 'v1', tags: ['a']));
        await s.notes.updateNote(buildNote(id: 'n', title: 'v2', tags: ['a']));

        final report = await s.sync.syncPendingChanges(uid);

        expect(report.synced, 1);
        expect(report.hasFailures, isFalse);
        expect((await s.cloudDoc('n'))!['title'], 'v2');
        expect(s.remote.uploads['n'], 1); // intermediate versions not sent
        expect(await s.queue.all(), isEmpty);
      },
    );

    for (final (name, failure) in [
      ('no network', const NetworkFailure()),
      ('timeout', const NetworkFailure(message: 'The request timed out.')),
      ('Firestore unavailable', const RemoteFailure(message: 'unavailable')),
      ('permission denied', const RemoteFailure(message: 'permission-denied')),
      ('signed out', const AuthFailure()),
    ]) {
      test(
        'failure ($name): local kept, queued as failed, then retried',
        () async {
          await s.notes.createNote(buildNote(id: 'n', title: 'Mine'));
          s.remote.failWith = failure;

          final report = await s.sync.syncPendingChanges(uid);

          expect(report.hasFailures, isTrue);
          expect(report.error, same(failure));
          expect((await s.notes.getNote('n')).title, 'Mine'); // never reverted
          final q = (await s.queue.all()).single;
          expect(q.status, SyncItemStatus.failed);
          expect(q.retryCount, 1);
          expect(q.lastError, failure.message);

          s.remote.failWith = null; // back online / fixed
          final retry = await s.sync.syncPendingChanges(uid);
          expect(retry.hasFailures, isFalse);
          expect((await s.cloudDoc('n'))!['title'], 'Mine');
          expect(await s.queue.all(), isEmpty);
        },
      );
    }

    test('a newer edit during an upload is not lost or overwritten', () async {
      await s.notes.createNote(buildNote(id: 'n', title: 'A'));
      final gate = s.remote.gate = Completer<void>();

      final running = s.sync.syncPendingChanges(uid);
      await pumpEventQueue();
      await s.notes.updateNote(buildNote(id: 'n', title: 'B')); // meanwhile
      s.remote.gate = null;
      gate.complete();
      await running;

      // The follow-up run (or the next sync) uploads B.
      await s.sync.syncPendingChanges(uid);
      expect((await s.cloudDoc('n'))!['title'], 'B');
      expect((await s.notes.getNote('n')).title, 'B');
      expect(await s.queue.all(), isEmpty);
    });

    test('folder deletion and tag rename queue the affected notes', () async {
      await s.folders.createFolder(buildFolder(id: 'f'));
      await s.notes.createNote(buildNote(id: 'n', folderId: 'f', tags: ['x']));
      await s.sync.syncPendingChanges(uid);

      await s.folders.deleteFolder('f');
      expect((await s.queue.all()).single.entityId, 'n');
      await s.sync.syncPendingChanges(uid);
      expect((await s.cloudDoc('n'))!['folderId'], isNull);

      final tag = (await s.tags.getTags()).single;
      await s.tags.updateTag(tag.copyWith(colorValue: '#C0392B'));
      expect(await s.queue.all(), isEmpty); // colour is local only
      await s.tags.updateTag(const Tag(id: 'id-1', name: 'renamed'));
      await s.sync.syncPendingChanges(uid);
      expect((await s.cloudDoc('n'))!['tags'], ['renamed']);
    });
  });

  group('idempotency and concurrency', () {
    test('repeated syncs and retries keep one document per note', () async {
      await s.notes.createNote(buildNote(id: 'n'));
      s.remote.failWith = const NetworkFailure();
      await s.sync.syncPendingChanges(uid);
      s.remote.failWith = null;
      await s.sync.syncPendingChanges(uid);
      await s.sync.syncPendingChanges(uid);
      await s.sync.syncPendingChanges(uid);

      expect(await s.cloudCount(), 1);
      expect(await s.cloudDoc('n'), isNotNull); // same id as the local note
    });

    test('simultaneous triggers upload each item once', () async {
      await s.notes.createNote(buildNote(id: 'a'));
      await s.notes.createNote(buildNote(id: 'b'));
      final gate = s.remote.gate = Completer<void>();

      // Reconnect + app resume + manual retry at the same moment.
      final runs = [
        s.sync.syncPendingChanges(uid),
        s.sync.syncPendingChanges(uid),
        s.sync.syncPendingChanges(uid),
      ];
      await pumpEventQueue();
      s.remote.gate = null;
      gate.complete();
      await Future.wait(runs);

      expect(s.remote.uploads, {'a': 1, 'b': 1});
      expect(await s.cloudCount(), 2);
      expect(await s.queue.all(), isEmpty);
    });
  });

  test('pending changes survive an app restart and sync afterwards', () async {
    await s.notes.createNote(buildNote(id: 'n', title: 'Before restart'));
    await s.notes.deleteNote('n'); // never attempted: dropped
    await s.notes.createNote(buildNote(id: 'm', title: 'Kept'));
    final gate = s.remote.gate = Completer<void>();
    unawaited(s.sync.syncPendingChanges(uid)); // killed mid-upload
    await pumpEventQueue();
    await s.db.close();
    gate.complete();

    // New process, same database file.
    s = _Session(file, firestore);
    expect((await s.queue.all()).single.entityId, 'm');

    final report = await s.sync.syncPendingChanges(uid);
    expect(report.hasFailures, isFalse);
    expect((await s.cloudDoc('m'))!['title'], 'Kept');
    expect(await s.cloudDoc('n'), isNull);
    expect(await s.queue.all(), isEmpty);
  });
}

class _BrokenOutbox implements SyncOutbox {
  @override
  Future<void> record(String entityType, String entityId, SyncOperation op) =>
      throw StateError('disk full');
}
