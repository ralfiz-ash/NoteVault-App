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
import 'package:notevalult/core/utils/id_generator.dart';
import 'package:notevalult/features/folders/data/datasources/drift_folder_local_data_source.dart';
import 'package:notevalult/features/folders/data/repositories/folder_repository_impl.dart';
import 'package:notevalult/features/notes/data/datasources/drift_note_local_data_source.dart';
import 'package:notevalult/features/notes/data/datasources/firestore_note_remote_data_source.dart';
import 'package:notevalult/features/notes/data/repositories/note_remote_repository_impl.dart';
import 'package:notevalult/features/notes/data/repositories/note_repository_impl.dart';
import 'package:notevalult/features/notes/domain/entities/note.dart';
import 'package:notevalult/features/sync/data/repositories/sync_repository_impl.dart';
import 'package:notevalult/features/sync/domain/entities/sync_entities.dart';

import '../../../helpers/fixtures.dart';

/// Unique ids per device so conflict copies never collide.
class _Ids implements IdGenerator {
  _Ids(this.prefix);
  final String prefix;
  int _n = 0;
  @override
  String newId() => '$prefix-${++_n}';
}

/// One installed app: its own local database, sharing the cloud.
class Device {
  Device(
    this.name,
    this.cloud, {
    this.userId = 'alice',
    File? file,
    DateTime Function()? clock,
  }) : db = AppDatabase(
         file == null ? NativeDatabase.memory() : NativeDatabase(file),
       ) {
    now = clock ?? () => DateTime.utc(2026, 11, 17, 9);
    queue = SyncQueueStore(db, () => now());
    final runner = DriftTransactionRunner(db);
    notes = NoteRepositoryImpl(
      local: DriftNoteLocalDataSource(
        database: db,
        idGenerator: _Ids('$name-tag'),
      ),
      exceptionMapper: const LocalDatabaseExceptionMapper(),
      clock: () => now(),
      outbox: queue,
      transactions: runner,
    );
    folders = FolderRepositoryImpl(
      local: DriftFolderLocalDataSource(database: db),
      exceptionMapper: const LocalDatabaseExceptionMapper(),
      outbox: queue,
      transactions: runner,
    );
    final remote = NoteRemoteRepositoryImpl(
      remote: FirestoreNoteRemoteDataSource(firestore: cloud),
      exceptionMapper: const FirestoreExceptionMapper(),
    );
    sync = SyncRepositoryImpl(
      queue: queue,
      localNotes: notes,
      remoteNotes: remote,
      folders: folders,
      transactions: runner,
      idGenerator: _Ids('$name-copy'),
      clock: () => now(),
    );
  }

  final String name;
  final String userId;
  final FakeFirebaseFirestore cloud;
  final AppDatabase db;
  late DateTime Function() now;
  late final SyncQueueStore queue;
  late final NoteRepositoryImpl notes;
  late final FolderRepositoryImpl folders;
  late final SyncRepositoryImpl sync;
  StreamSubscription<RemoteSyncReport>? _follow;
  final remoteReports = <RemoteSyncReport>[];

  void online() =>
      _follow ??= sync.followRemoteChanges(userId).listen(remoteReports.add);

  Future<void> offline() async {
    await _follow?.cancel();
    _follow = null;
  }

  Future<SyncReport> push() => sync.syncPendingChanges(userId);

  Future<Note?> note(String id) async {
    try {
      return await notes.getNote(id);
    } on NotFoundFailure {
      return null;
    }
  }

  Future<List<String>> titles() async =>
      [for (final n in await notes.getNotes()) n.title]..sort();

  Future<void> close() async {
    await offline();
    await db.close();
  }
}

Future<void> settle() async {
  for (var i = 0; i < 5; i++) {
    await pumpEventQueue();
  }
}

void main() {
  late FakeFirebaseFirestore cloud;
  late Device a;
  late Device b;

  setUp(() {
    cloud = FakeFirebaseFirestore();
    a = Device('A', cloud);
    b = Device('B', cloud);
  });

  tearDown(() async {
    await a.close();
    await b.close();
  });

  Future<Map<String, Object?>?> cloudDoc(String id) async =>
      (await cloud.doc('users/alice/notes/$id').get()).data();

  group('A -> B and B -> A', () {
    test('create, update and delete reach the other device', () async {
      a.online();
      b.online();

      await a.notes.createNote(buildNote(id: 'n', title: 'From A'));
      await a.push();
      await settle();
      final created = (await b.note('n'))!;
      expect(created.title, 'From A');
      expect(created.id, 'n'); // same id on every device
      expect(created.version, 1);

      await a.notes.updateNote(buildNote(id: 'n', title: 'Edited on A'));
      await a.push();
      await settle();
      expect((await b.note('n'))!.title, 'Edited on A');
      expect((await b.note('n'))!.version, 2);

      // And back: B edits, A receives.
      await b.notes.updateNote(buildNote(id: 'n', title: 'Edited on B'));
      await b.push();
      await settle();
      expect((await a.note('n'))!.title, 'Edited on B');
      expect((await a.note('n'))!.version, 3);

      await b.notes.deleteNote('n');
      await b.push();
      await settle();
      expect(await a.note('n'), isNull);
      expect(await cloudDoc('n'), isNull);
    });

    test(
      'remote changes never create outbound queue entries (no loop)',
      () async {
        a.online();
        b.online();
        await a.notes.createNote(buildNote(id: 'n'));
        await a.push();
        await settle();

        expect(await b.note('n'), isNotNull);
        expect(await b.queue.all(), isEmpty); // B has nothing to upload
        expect((await b.push()).synced, 0);
        expect(await a.queue.all(), isEmpty); // A ignored its own echo
        expect(a.remoteReports.last.applied, 0);
      },
    );

    test('duplicate listeners / repeated events apply once', () async {
      b.online();
      final second = b.sync.followRemoteChanges('alice').listen((_) {});
      addTearDown(second.cancel);

      await a.notes.createNote(buildNote(id: 'n'));
      await a.push();
      await settle();

      expect((await b.notes.getNotes()), hasLength(1));
      expect(await b.queue.all(), isEmpty);
    });
  });

  test('initial sync on a new device fills the local database', () async {
    await a.folders.createFolder(buildFolder(id: 'f', name: 'Work'));
    for (final id in ['1', '2', '3']) {
      await a.notes.createNote(
        buildNote(id: id, title: 'Note $id', folderId: id == '1' ? 'f' : null),
      );
    }
    await a.push();

    final c = Device('C', cloud);
    addTearDown(c.close);
    c.online();
    await settle();

    expect(await c.titles(), ['Note 1', 'Note 2', 'Note 3']);
    expect((await c.folders.getFolder('f')).name, 'Work'); // folder came too
    expect(await c.queue.all(), isEmpty);
  });

  test('folder rename travels with its notes', () async {
    b.online();
    await a.folders.createFolder(buildFolder(id: 'f', name: 'Work'));
    await a.notes.createNote(buildNote(id: 'n', folderId: 'f'));
    await a.push();
    await settle();
    expect((await b.folders.getFolder('f')).name, 'Work');

    await a.folders.updateFolder(buildFolder(id: 'f', name: 'Office'));
    await a.push();
    await settle();
    expect((await b.folders.getFolder('f')).name, 'Office');
  });

  group('conflicts', () {
    setUp(() async {
      a.online();
      b.online();
      await a.notes.createNote(buildNote(id: 'n', title: 'Base'));
      await a.push();
      await settle();
      await a.offline();
      await b.offline();
    });

    test(
      'update/update: the later edit wins, the other is kept as a copy',
      () async {
        a.now = () => DateTime.utc(2026, 11, 17, 10);
        b.now = () => DateTime.utc(2026, 11, 17, 11); // later
        await a.notes.updateNote(buildNote(id: 'n', title: 'A text'));
        await b.notes.updateNote(buildNote(id: 'n', title: 'B text'));

        // A uploads first, then B (whose edit is newer) overwrites.
        await a.push();
        final bReport = await b.push();
        expect(bReport.conflicts, 0);
        a.online();
        b.online();
        await settle();

        expect((await cloudDoc('n'))!['title'], 'B text');
        expect((await a.note('n'))!.title, 'B text');
        expect((await b.note('n'))!.title, 'B text');
      },
    );

    test(
      'older unsynced edit loses: kept as a conflict copy, both converge',
      () async {
        a.now = () => DateTime.utc(2026, 11, 17, 11); // later
        b.now = () => DateTime.utc(2026, 11, 17, 10);
        await a.notes.updateNote(buildNote(id: 'n', title: 'A text'));
        await b.notes.updateNote(buildNote(id: 'n', title: 'B text'));

        await a.push();
        final bReport = await b.push(); // cloud already has the newer A text
        expect(bReport.conflicts, 1);
        await b.push(); // uploads B's conflict copy
        a.online();
        b.online();
        await settle();

        for (final device in [a, b]) {
          expect((await device.note('n'))!.title, 'A text');
          expect(await device.titles(), [
            'A text',
            'B text (conflict copy)',
          ], reason: device.name);
        }
        expect(await a.queue.all(), isEmpty);
        expect(await b.queue.all(), isEmpty);
      },
    );

    test(
      'remote change arriving while a newer local edit is pending',
      () async {
        a.now = () => DateTime.utc(2026, 11, 17, 10);
        b.now = () => DateTime.utc(2026, 11, 17, 11);
        await a.notes.updateNote(buildNote(id: 'n', title: 'A text'));
        await a.push();
        await b.notes.updateNote(buildNote(id: 'n', title: 'B text')); // newer
        b.online();
        await settle();

        // B keeps its newer pending edit; it uploads and wins.
        expect((await b.note('n'))!.title, 'B text');
        expect(await b.queue.all(), hasLength(1));
        await b.push();
        a.online();
        await settle();
        expect((await a.note('n'))!.title, 'B text');
      },
    );

    test('update/delete: an unsynced edit wins over a delete', () async {
      await b.notes.deleteNote('n');
      await b.push(); // cloud copy deleted
      await a.notes.updateNote(buildNote(id: 'n', title: 'Still needed'));
      a.online();
      await settle(); // A hears the delete but keeps its pending edit
      expect((await a.note('n'))!.title, 'Still needed');

      await a.push(); // re-creates the note
      b.online();
      await settle();
      expect((await b.note('n'))!.title, 'Still needed');
      expect((await cloudDoc('n'))!['title'], 'Still needed');
    });

    test(
      'delete/update: an edit made elsewhere beats a pending delete',
      () async {
        await a.notes.deleteNote('n'); // pending delete of version 1
        await b.notes.updateNote(buildNote(id: 'n', title: 'Edited on B'));
        await b.push(); // cloud now version 2
        a.online();
        await settle();

        expect((await a.note('n'))!.title, 'Edited on B'); // restored
        expect(await a.queue.all(), isEmpty); // delete dropped
        expect((await a.push()).synced, 0);
        expect(await cloudDoc('n'), isNotNull);
      },
    );

    test(
      'delete then upload of the delete is not undone by an older echo',
      () async {
        await a.notes.deleteNote('n');
        a.online();
        await settle();
        expect(await a.note('n'), isNull); // version-1 cloud copy ignored
        await a.push();
        await settle();
        expect(await cloudDoc('n'), isNull);
      },
    );
  });

  group('versions', () {
    test(
      'increment locally, persist from the cloud, ignore older ones',
      () async {
        b.online();
        await a.notes.createNote(buildNote(id: 'n'));
        expect((await a.note('n'))!.version, 1);
        await a.notes.updateNote(buildNote(id: 'n', title: 'v2'));
        await a.notes.updateNote(buildNote(id: 'n', title: 'v3'));
        expect((await a.note('n'))!.version, 3);
        await a.push();
        await settle();
        expect((await b.note('n'))!.version, 3);

        // A stale cloud write (older revision) must not replace newer data.
        await cloud.doc('users/alice/notes/n').update({
          'title': 'stale',
          'version': 2,
        });
        await settle();
        expect((await b.note('n'))!.title, 'v3');
      },
    );

    test('version and data survive an app restart; sync resumes', () async {
      final dir = Directory.systemTemp.createTempSync('notevault_x');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/b.sqlite');
      var device = Device('B2', cloud, file: file)..online();
      await a.notes.createNote(buildNote(id: 'n'));
      await a.notes.updateNote(buildNote(id: 'n', title: 'v2'));
      await a.push();
      await settle();
      expect((await device.note('n'))!.version, 2);
      await device.close();

      await a.notes.updateNote(buildNote(id: 'n', title: 'While closed'));
      await a.push();

      device = Device('B2', cloud, file: file);
      addTearDown(device.close);
      expect((await device.note('n'))!.version, 2); // persisted
      device.online();
      await settle();
      expect((await device.note('n'))!.title, 'While closed');
      expect((await device.note('n'))!.version, 3);
    });
  });

  test('users only sync their own notes', () async {
    final bob = Device('Bob', cloud, userId: 'bob');
    addTearDown(bob.close);
    bob.online();
    a.online();
    await a.notes.createNote(buildNote(id: 'alice-note'));
    await a.push();
    await settle();

    expect(await bob.notes.getNotes(), isEmpty);
    expect((await cloud.collection('users/bob/notes').get()).docs, isEmpty);
  });

  test('offline edit on A reaches B after A reconnects', () async {
    a.online();
    b.online();
    await a.notes.createNote(buildNote(id: 'n', title: 'v1'));
    await a.push();
    await settle();

    await a.offline();
    await a.notes.updateNote(buildNote(id: 'n', title: 'Offline edit'));
    expect((await a.note('n'))!.title, 'Offline edit');
    await settle();
    expect((await b.note('n'))!.title, 'v1');

    a.online();
    await a.push();
    await settle();
    expect((await b.note('n'))!.title, 'Offline edit');
  });
}
