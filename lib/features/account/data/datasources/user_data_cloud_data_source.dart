import 'package:cloud_firestore/cloud_firestore.dart';

/// Deletes a user's cloud data.
abstract interface class UserDataCloudDataSource {
  Future<void> deleteAllUserData(String userId);
}

/// Cloud Firestore: everything lives under `users/{userId}/notes`.
class FirestoreUserDataCloudDataSource implements UserDataCloudDataSource {
  FirestoreUserDataCloudDataSource({
    required FirebaseFirestore firestore,
    this.timeout = const Duration(seconds: 30),
  }) : _db = firestore;

  // Same paths as the notes sync (kept here: data layers do not share code
  // across features).
  static const _users = 'users';
  static const _notes = 'notes';

  /// Firestore allows at most 500 writes per batch.
  static const _batchSize = 400;

  final FirebaseFirestore _db;

  /// Each server round trip gives up after this (instead of waiting forever
  /// on a bad connection) and fails with a `TimeoutException`.
  final Duration timeout;

  @override
  Future<void> deleteAllUserData(String userId) async {
    final notes = _db.collection(_users).doc(userId).collection(_notes);
    while (true) {
      // Read from the server only: offline this fails instead of deleting
      // just the cached copy and waiting for a connection.
      final page = await notes
          .limit(_batchSize)
          .get(const GetOptions(source: Source.server))
          .timeout(timeout);
      if (page.docs.isEmpty) break;
      final batch = _db.batch();
      for (final doc in page.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit().timeout(timeout);
    }
  }
}
