import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/database/app_database.dart';
import 'package:notevalult/core/database/local_database_exception_mapper.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/core/firebase/firestore_exception_mapper.dart';
import 'package:notevalult/features/account/data/datasources/user_data_cloud_data_source.dart';
import 'package:notevalult/features/account/data/datasources/user_data_local_data_source.dart';
import 'package:notevalult/features/account/data/repositories/user_data_repository_impl.dart';

import '../../../helpers/test_database.dart';

void main() {
  group('cloud (Firestore)', () {
    late FakeFirebaseFirestore firestore;

    CollectionReference<Map<String, dynamic>> notesOf(String uid) =>
        firestore.collection('users').doc(uid).collection('notes');

    setUp(() => firestore = FakeFirebaseFirestore());

    test('deletes every note of the user (more than one batch)', () async {
      for (var i = 0; i < 450; i++) {
        await notesOf('u1').doc('n$i').set({'title': 'Note $i'});
      }
      await notesOf('other').doc('x').set({'title': 'Not mine'});

      await FirestoreUserDataCloudDataSource(firestore: firestore)
          .deleteAllUserData('u1');

      expect((await notesOf('u1').get()).docs, isEmpty);
      expect((await notesOf('other').get()).docs, hasLength(1));
    });

    test('nothing stored: completes', () async {
      await FirestoreUserDataCloudDataSource(firestore: firestore)
          .deleteAllUserData('u1');
    });
  });

  group('local (Drift)', () {
    late AppDatabase db;
    late DriftUserDataLocalDataSource local;

    Future<void> seed() async {
      await db
          .into(db.folders)
          .insert(FoldersCompanion.insert(id: 'f', name: 'Work', createdAt: 1));
      await db
          .into(db.notes)
          .insert(
            NotesCompanion.insert(
              id: 'n',
              title: 'T',
              content: 'C',
              folderId: const Value('f'),
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      await db.into(db.tags).insert(TagsCompanion.insert(id: 't', name: 'x'));
      await db
          .into(db.noteTags)
          .insert(NoteTagsCompanion.insert(noteId: 'n', tagId: 't'));
      await db
          .into(db.syncQueue)
          .insert(
            SyncQueueCompanion.insert(
              entityType: 'note',
              entityId: 'n',
              operation: 'upsert',
              createdAt: 1,
              updatedAt: 1,
            ),
          );
      await db
          .into(db.preferences)
          .insert(PreferencesCompanion.insert(key: 'themeMode', value: 'dark'));
    }

    Future<int> count(TableInfo<Table, Object?> table) async =>
        (await db.select(table).get()).length;

    setUp(() async {
      db = createTestDatabase();
      local = DriftUserDataLocalDataSource(database: db);
      await seed();
    });

    test('clearSyncQueue only drops pending uploads', () async {
      await local.clearSyncQueue();
      expect(await count(db.syncQueue), 0);
      expect(await count(db.notes), 1);
    });

    test(
      'deleteAll removes notes, folders, tags, settings and queue',
      () async {
        await local.deleteAll();
        for (final table in db.allTables) {
          expect(await count(table), 0, reason: table.actualTableName);
        }
      },
    );
  });

  test('repository maps errors to Failures', () async {
    final repo = UserDataRepositoryImpl(
      cloud: _ThrowingCloud(),
      local: DriftUserDataLocalDataSource(database: createTestDatabase()),
      cloudExceptionMapper: const FirestoreExceptionMapper(),
      localExceptionMapper: const LocalDatabaseExceptionMapper(),
    );
    await expectLater(repo.deleteCloudData('u1'), throwsA(isA<Failure>()));
  });
}

class _ThrowingCloud implements UserDataCloudDataSource {
  @override
  Future<void> deleteAllUserData(String userId) =>
      Future.error(StateError('boom'));
}
