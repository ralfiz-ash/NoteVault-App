import '../entities/sync_entities.dart';

/// Uploads queued local changes to the cloud. Knows nothing about Firestore
/// or the database.
///
/// Two directions, one conflict rule (`NoteVersioning`, "latest revision
/// wins", plus "edits win over deletes"):
/// - upload: queued local changes go up only if the cloud does not hold a
///   newer revision (checked atomically);
/// - download: cloud changes are applied to the local database (never
///   re-queued for upload), unless a newer local change is pending.
/// A local unsynced edit that loses is kept as a separate "conflict copy"
/// note, so no user text is ever silently dropped.
abstract interface class SyncRepository {
  Stream<PendingChanges> watchPendingChanges();

  /// Uploads everything queued for [userId]'s data. Only one run happens at
  /// a time: calls made while a run is in progress share it (and trigger one
  /// follow-up run for changes queued meanwhile). Never throws; failures are
  /// in the report and stay queued.
  Future<SyncReport> syncPendingChanges(String userId);

  /// Follows [userId]'s notes in the cloud and applies every change to the
  /// local database (first all notes, then increments). One report per
  /// batch. Cancel the subscription to stop (e.g. on sign-out).
  Stream<RemoteSyncReport> followRemoteChanges(String userId);
}
