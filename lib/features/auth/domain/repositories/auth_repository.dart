import '../entities/app_user.dart';

/// Contract for authentication. Sign-in / register / reset-password / Google
/// sign-in methods are added when the Authentication phase starts.
abstract interface class AuthRepository {
  /// Emits the signed-in user, or `null` when signed out.
  Stream<AppUser?> authStateChanges();

  Future<void> signOut();
}
