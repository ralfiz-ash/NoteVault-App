import 'package:drift_flutter/drift_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/database/app_database.dart';
import '../../core/database/local_database_exception_mapper.dart';
import '../../core/database/local_transaction.dart';
import '../../core/database/sync_queue_store.dart';
import '../../core/errors/exception_mapper.dart';
import '../../core/errors/failure.dart';
import '../../core/utils/clock.dart';
import '../../core/utils/id_generator.dart';

import 'session_providers.dart';

part 'database_providers.g.dart';

/// Opens the local database for one user. Overridden in tests with an
/// in-memory database.
typedef DatabaseOpener = AppDatabase Function(String userId);

/// - Android / iOS: a SQLite file in the app's documents directory.
/// - Web: SQLite compiled to WebAssembly (OPFS or IndexedDB storage). Needs
///   `web/sqlite3.wasm` and `web/drift_worker.js`, produced by
///   `tool/build_web_db_assets.sh`.
@Riverpod(keepAlive: true)
DatabaseOpener databaseOpener(Ref ref) =>
    (userId) => AppDatabase(
      driftDatabase(
        name: 'notevault_$userId',
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      ),
    );

/// The signed-in user's local database (one database per user, so one user's
/// notes, folders and tags can never be shown to another user of the same
/// device).
///
/// Rebuilt when the user changes: the previous database is closed
/// (`ref.onDispose`) and every data source, repository and provider built on
/// it is rebuilt for the new user. Fails with [AuthFailure] while nobody is
/// signed in (the router keeps signed-out users on the auth screens).
///
/// It is opened lazily on the first query. Tests override this provider (or
/// [databaseOpenerProvider]) with an in-memory database.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final userId = ref.watch(currentUserIdProvider).value;
  if (userId == null) {
    throw const AuthFailure(message: 'Sign in to open your notes.');
  }
  final database = ref.watch(databaseOpenerProvider)(userId);
  ref.onDispose(database.close);
  return database;
}

@Riverpod(keepAlive: true)
ExceptionMapper localDatabaseExceptionMapper(Ref ref) =>
    const LocalDatabaseExceptionMapper();

@Riverpod(keepAlive: true)
Clock clock(Ref ref) => DateTime.now;

@Riverpod(keepAlive: true)
IdGenerator idGenerator(Ref ref) => UuidV4Generator();

/// The signed-in user's persistent sync queue (in their database).
@Riverpod(keepAlive: true)
SyncQueueStore syncQueueStore(Ref ref) =>
    SyncQueueStore(ref.watch(appDatabaseProvider), ref.watch(clockProvider));

/// Makes a local change and its sync record one transaction.
@Riverpod(keepAlive: true)
LocalTransactionRunner localTransactions(Ref ref) =>
    DriftTransactionRunner(ref.watch(appDatabaseProvider));
