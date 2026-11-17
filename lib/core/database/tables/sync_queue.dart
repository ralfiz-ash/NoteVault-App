import 'package:drift/drift.dart';

/// Outbox of local changes still to be sent to the cloud (schema version 3).
///
/// One row per entity: repeated local changes to the same note are merged
/// into one row (see `SyncQueueStore.record`). The row holds no copy of the
/// entity: the latest local state is read when syncing (a delete only needs
/// the id).
@DataClassName('SyncQueueRow')
class SyncQueue extends Table {
  /// E.g. "note". Extensible to folders/tags later.
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();

  /// "create" | "update" | "delete".
  TextColumn get operation => text()();

  /// "pending" | "syncing" | "failed".
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// Bumped on every local change; a sync only completes the row if the
  /// version it uploaded is still the latest.
  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  /// Epoch milliseconds (UTC).
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {entityType, entityId};
}
