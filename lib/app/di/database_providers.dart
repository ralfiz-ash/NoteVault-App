import 'package:drift_flutter/drift_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/database/app_database.dart';
import '../../core/database/local_database_exception_mapper.dart';
import '../../core/errors/exception_mapper.dart';
import '../../core/utils/clock.dart';
import '../../core/utils/id_generator.dart';

part 'database_providers.g.dart';

/// The app database. It is opened lazily on the first query, and closed when
/// the container is disposed. Tests override this provider with an in-memory
/// database.
///
/// - Android / iOS: a SQLite file in the app's documents directory.
/// - Web: SQLite compiled to WebAssembly (OPFS or IndexedDB storage). Needs
///   `web/sqlite3.wasm` and `web/drift_worker.js`, produced by
///   `tool/build_web_db_assets.sh`.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase(
    driftDatabase(
      name: 'notevault',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    ),
  );
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
