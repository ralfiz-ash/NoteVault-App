import 'package:drift/drift.dart';

import '../utils/clock.dart';
import 'app_database.dart';

enum SyncOperation { create, update, delete }

enum SyncItemStatus { pending, syncing, failed }

/// Entity types that are synced.
abstract final class SyncEntity {
  static const note = 'note';
}

/// One queued change.
class SyncQueueEntry {
  const SyncQueueEntry({
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.status,
    required this.version,
    required this.retryCount,
    this.lastError,
    this.entityVersion,
  });

  final String entityType;
  final String entityId;
  final SyncOperation operation;
  final SyncItemStatus status;
  final int version;
  final int retryCount;
  final String? lastError;

  /// The entity's revision when last queued (for a delete: the deleted
  /// revision).
  final int? entityVersion;
}

/// Counts of queued changes, for "N changes pending" and failure banners.
class SyncQueueCounts {
  const SyncQueueCounts({
    required this.pending,
    required this.failed,
    this.lastError,
  });

  /// Everything not yet in the cloud (pending + syncing + failed).
  final int pending;
  final int failed;
  final String? lastError;
}

/// Records local changes for later upload. Implemented by [SyncQueueStore];
/// repositories call it inside the same local transaction as the change.
abstract interface class SyncOutbox {
  Future<void> record(
    String entityType,
    String entityId,
    SyncOperation op, {
    int? entityVersion,
  });
}

/// The persistent sync queue (table `sync_queue`).
///
/// Merging rules for a new change to an entity that is already queued
/// (conservative: never drop something the cloud may already have):
/// - create + update  -> create (latest state uploaded once)
/// - update + update  -> update
/// - create + delete  -> row removed, only if the create was never attempted
///   (otherwise -> delete)
/// - anything + delete -> delete
/// - delete + create/update -> update (re-create remotely)
/// Every change bumps `version` and sets the row back to pending, so a sync
/// that is uploading an older version will not mark it done.
class SyncQueueStore implements SyncOutbox {
  SyncQueueStore(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  int get _now => _clock().toUtc().millisecondsSinceEpoch;

  SimpleSelectStatement<$SyncQueueTable, SyncQueueRow> _row(
    String type,
    String id,
  ) =>
      _db.select(_db.syncQueue)
        ..where((q) => q.entityType.equals(type) & q.entityId.equals(id));

  @override
  Future<void> record(
    String entityType,
    String entityId,
    SyncOperation op, {
    int? entityVersion,
  }) {
    return _db.transaction(() async {
      final existing = await _row(entityType, entityId).getSingleOrNull();
      if (existing == null) {
        await _db
            .into(_db.syncQueue)
            .insert(
              SyncQueueCompanion.insert(
                entityType: entityType,
                entityId: entityId,
                operation: op.name,
                entityVersion: Value(entityVersion),
                createdAt: _now,
                updatedAt: _now,
              ),
            );
        return;
      }

      final previous = SyncOperation.values.byName(existing.operation);
      final neverAttempted =
          existing.status == SyncItemStatus.pending.name &&
          existing.retryCount == 0;

      if (previous == SyncOperation.create &&
          op == SyncOperation.delete &&
          neverAttempted) {
        // Created and deleted before it ever left the device.
        await (_db.delete(_db.syncQueue)..where(
              (q) =>
                  q.entityType.equals(entityType) & q.entityId.equals(entityId),
            ))
            .go();
        return;
      }

      final merged = switch ((previous, op)) {
        (SyncOperation.create, SyncOperation.update) => SyncOperation.create,
        (SyncOperation.delete, SyncOperation.create) => SyncOperation.update,
        (SyncOperation.delete, SyncOperation.update) => SyncOperation.update,
        _ => op,
      };
      await (_db.update(_db.syncQueue)..where(
            (q) =>
                q.entityType.equals(entityType) & q.entityId.equals(entityId),
          ))
          .write(
            SyncQueueCompanion(
              operation: Value(merged.name),
              entityVersion: Value(entityVersion ?? existing.entityVersion),
              status: Value(SyncItemStatus.pending.name),
              version: Value(existing.version + 1),
              updatedAt: Value(_now),
            ),
          );
    });
  }

  /// Items to upload (pending or failed), oldest change first.
  Future<List<SyncQueueEntry>> due() async {
    final rows =
        await (_db.select(_db.syncQueue)
              ..where((q) => q.status.isNotValue(SyncItemStatus.syncing.name))
              ..orderBy([(q) => OrderingTerm.asc(q.updatedAt)]))
            .get();
    return rows.map(_toEntry).toList();
  }

  /// Marks [entry] as syncing, only if nothing changed since it was read and
  /// no other sync has claimed it. Returns `false` if it was not claimed.
  Future<bool> claim(SyncQueueEntry entry) async {
    final changed =
        await (_db.update(_db.syncQueue)..where(
              (q) =>
                  _key(q, entry) &
                  q.version.equals(entry.version) &
                  q.status.isNotValue(SyncItemStatus.syncing.name),
            ))
            .write(
              SyncQueueCompanion(status: Value(SyncItemStatus.syncing.name)),
            );
    return changed == 1;
  }

  /// The upload of [entry] succeeded. Removes the row unless the entity was
  /// changed again meanwhile; then the row goes back to pending so the newer
  /// state is uploaded next.
  Future<void> complete(SyncQueueEntry entry) {
    return _db.transaction(() async {
      final removed = await (_db.delete(
        _db.syncQueue,
      )..where((q) => _key(q, entry) & q.version.equals(entry.version))).go();
      if (removed == 0) await _release(entry);
    });
  }

  /// The upload of [entry] failed. Keeps the row (failed, retry count and
  /// error recorded); a newer local change makes it pending instead.
  Future<void> fail(SyncQueueEntry entry, String error) {
    return _db.transaction(() async {
      final changed =
          await (_db.update(
                _db.syncQueue,
              )..where((q) => _key(q, entry) & q.version.equals(entry.version)))
              .write(
                SyncQueueCompanion(
                  status: Value(SyncItemStatus.failed.name),
                  retryCount: Value(entry.retryCount + 1),
                  lastError: Value(error),
                  updatedAt: Value(_now),
                ),
              );
      if (changed == 0) await _release(entry);
    });
  }

  /// Rows left "syncing" by a sync that never finished (app killed) become
  /// pending again. Called before each sync run.
  Future<void> releaseInterrupted() =>
      (_db.update(
        _db.syncQueue,
      )..where((q) => q.status.equals(SyncItemStatus.syncing.name))).write(
        SyncQueueCompanion(status: Value(SyncItemStatus.pending.name)),
      );

  Stream<SyncQueueCounts> watchCounts() =>
      (_db.select(
        _db.syncQueue,
      )..orderBy([(q) => OrderingTerm.desc(q.updatedAt)])).watch().map(
        (rows) => SyncQueueCounts(
          pending: rows.length,
          failed: rows
              .where((r) => r.status == SyncItemStatus.failed.name)
              .length,
          lastError: rows
              .where((r) => r.lastError != null)
              .map((r) => r.lastError)
              .firstOrNull,
        ),
      );

  /// The queued change for one entity, if any (any status).
  Future<SyncQueueEntry?> entry(String entityType, String entityId) async {
    final row = await _row(entityType, entityId).getSingleOrNull();
    return row == null ? null : _toEntry(row);
  }

  /// Drops the queued change for one entity (it no longer needs uploading,
  /// e.g. the cloud already has an equal or newer state).
  Future<void> remove(String entityType, String entityId) =>
      (_db.delete(_db.syncQueue)..where(
            (q) =>
                q.entityType.equals(entityType) & q.entityId.equals(entityId),
          ))
          .go();

  Future<List<SyncQueueEntry>> all() async =>
      (await _db.select(_db.syncQueue).get()).map(_toEntry).toList();

  Future<void> _release(SyncQueueEntry entry) =>
      (_db.update(_db.syncQueue)..where(
            (q) =>
                _key(q, entry) & q.status.equals(SyncItemStatus.syncing.name),
          ))
          .write(
            SyncQueueCompanion(status: Value(SyncItemStatus.pending.name)),
          );

  Expression<bool> _key($SyncQueueTable q, SyncQueueEntry e) =>
      q.entityType.equals(e.entityType) & q.entityId.equals(e.entityId);

  SyncQueueEntry _toEntry(SyncQueueRow row) => SyncQueueEntry(
    entityType: row.entityType,
    entityId: row.entityId,
    operation: SyncOperation.values.byName(row.operation),
    status: SyncItemStatus.values.byName(row.status),
    version: row.version,
    retryCount: row.retryCount,
    lastError: row.lastError,
    entityVersion: row.entityVersion,
  );
}
