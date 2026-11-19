/// Removes everything NoteVault stores for the signed-in user. Used only by
/// account deletion. Implementations throw `Failure`s from `core/errors`.
abstract interface class UserDataRepository {
  /// Drops changes still waiting to be uploaded, so nothing is written to
  /// the cloud again once deletion has started.
  Future<void> discardPendingSync();

  /// Deletes all of [userId]'s data in the cloud. Requires a connection
  /// (fails with `NetworkFailure` instead of waiting while offline).
  Future<void> deleteCloudData(String userId);

  /// Deletes all of the user's data on this device (notes, folders, tags,
  /// settings, pending sync).
  Future<void> deleteLocalData();
}
