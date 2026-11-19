import '../../../../core/database/app_database.dart';

/// Deletes the user's data on this device.
abstract interface class UserDataLocalDataSource {
  Future<void> clearSyncQueue();

  Future<void> deleteAll();
}

/// The signed-in user's own Drift database. Rows are deleted (rather than
/// the database file) so this works the same on Android, iOS and the web.
class DriftUserDataLocalDataSource implements UserDataLocalDataSource {
  const DriftUserDataLocalDataSource({required AppDatabase database})
    : _db = database;

  final AppDatabase _db;

  @override
  Future<void> clearSyncQueue() => _db.delete(_db.syncQueue).go();

  @override
  Future<void> deleteAll() => _db.transaction(() async {
    // Children before parents (foreign keys are on).
    await _db.delete(_db.noteTags).go();
    await _db.delete(_db.notes).go();
    await _db.delete(_db.tags).go();
    await _db.delete(_db.folders).go();
    await _db.delete(_db.syncQueue).go();
    await _db.delete(_db.preferences).go();
  });
}
