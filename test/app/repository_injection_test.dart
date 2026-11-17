import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/di/connectivity_providers.dart';
import 'package:notevalult/app/di/database_providers.dart';
import 'package:notevalult/app/di/firebase_providers.dart';
import 'package:notevalult/app/di/repository_providers.dart';
import 'package:notevalult/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:notevalult/features/folders/data/repositories/folder_repository_impl.dart';
import 'package:notevalult/features/notes/data/repositories/note_remote_repository_impl.dart';
import 'package:notevalult/features/notes/data/repositories/note_repository_impl.dart';
import 'package:notevalult/features/sync/data/datasources/connectivity_data_source.dart';
import 'package:notevalult/features/sync/data/repositories/connectivity_repository_impl.dart';
import 'package:notevalult/features/sync/domain/entities/connectivity_status.dart';

import '../helpers/fake_firebase_auth.dart';
import '../helpers/test_database.dart';
import '../helpers/test_helpers.dart';

class _FakeConnectivityDataSource implements ConnectivityDataSource {
  @override
  Stream<ConnectivityStatus> watchStatus() =>
      Stream.value(ConnectivityStatus.connected);
}

/// The DI graph resolves to the real implementations when only the
/// outermost infrastructure (database file, Firebase SDKs, plugin) is faked.
void main() {
  test('repository providers resolve to the real implementations', () {
    final container = createContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(createTestDatabase()),
        firebaseAuthProvider.overrideWithValue(FakeFirebaseAuth()),
        googleIdTokenSourceProvider.overrideWithValue(
          FakeGoogleIdTokenSource(),
        ),
        firebaseFirestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
        connectivityDataSourceProvider.overrideWithValue(
          _FakeConnectivityDataSource(),
        ),
      ],
    );

    expect(container.read(noteRepositoryProvider), isA<NoteRepositoryImpl>());
    expect(
      container.read(folderRepositoryProvider),
      isA<FolderRepositoryImpl>(),
    );
    expect(container.read(authRepositoryProvider), isA<AuthRepositoryImpl>());
    expect(
      container.read(noteRemoteRepositoryProvider),
      isA<NoteRemoteRepositoryImpl>(),
    );
    expect(
      container.read(connectivityRepositoryProvider),
      isA<ConnectivityRepositoryImpl>(),
    );
  });

  test('the database is shared: one instance for all data sources', () {
    final db = createTestDatabase();
    final container = createContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );

    expect(container.read(appDatabaseProvider), same(db));
    // Reading twice returns the same cached repository (keepAlive).
    expect(
      container.read(noteRepositoryProvider),
      same(container.read(noteRepositoryProvider)),
    );
  });
}
