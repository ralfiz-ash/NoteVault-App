import '../../../../core/errors/failure.dart';

/// Local changes not yet in the cloud (from the persistent sync queue).
class PendingChanges {
  const PendingChanges({this.pending = 0, this.failed = 0, this.lastError});

  static const none = PendingChanges();

  /// Everything still to upload (including failed items).
  final int pending;

  /// Items whose last upload attempt failed (they stay queued).
  final int failed;
  final String? lastError;

  bool get isEmpty => pending == 0;

  @override
  bool operator ==(Object other) =>
      other is PendingChanges &&
      other.pending == pending &&
      other.failed == failed &&
      other.lastError == lastError;

  @override
  int get hashCode => Object.hash(pending, failed, lastError);
}

/// Outcome of one sync run.
class SyncReport {
  const SyncReport({
    this.synced = 0,
    this.failed = 0,
    this.conflicts = 0,
    this.error,
  });

  final int synced;
  final int failed;

  /// Uploads that met a newer cloud version (resolved, see conflict rule).
  final int conflicts;

  /// The first failure, if any (for the UI message).
  final Failure? error;

  bool get hasFailures => failed > 0 || error != null;

  SyncReport operator +(SyncReport other) => SyncReport(
    synced: synced + other.synced,
    conflicts: conflicts + other.conflicts,
    failed: other.failed, // the latest pass decides what is still failing
    error: other.error ?? (other.failed > 0 ? error : null),
  );
}

/// Result of applying one batch of cloud changes on this device.
class RemoteSyncReport {
  const RemoteSyncReport({this.applied = 0, this.conflicts = 0});

  /// Notes created, updated or deleted locally from the cloud.
  final int applied;

  /// Local unsynced edits that lost to a newer cloud version (kept as
  /// conflict copies) or cloud edits that beat a local delete.
  final int conflicts;
}
