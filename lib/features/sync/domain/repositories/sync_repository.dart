import '../entities/sync_entities.dart';

/// Uploads queued local changes to the cloud. Knows nothing about Firestore
/// or the database.
///
/// Conflict strategy: the device's latest local change wins. The cloud copy
/// of a note is replaced by the current local version (or deleted); nothing
/// is downloaded in this phase, and an upload never changes local data.
abstract interface class SyncRepository {
  Stream<PendingChanges> watchPendingChanges();

  /// Uploads everything queued for [userId]'s data. Only one run happens at
  /// a time: calls made while a run is in progress share it (and trigger one
  /// follow-up run for changes queued meanwhile). Never throws; failures are
  /// in the report and stay queued.
  Future<SyncReport> syncPendingChanges(String userId);
}
