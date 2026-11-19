import '../entities/app_user.dart';

/// Authentication contract. Knows nothing about Firebase or Google Sign-In.
///
/// Implementations throw `Failure`s from `core/errors`:
/// - `AuthFailure` for wrong credentials, disabled accounts, ...
/// - `ValidationFailure` for a malformed email or weak password
/// - `NetworkFailure` when offline
/// - `CancelledFailure` when the user closes a sign-in flow
abstract interface class AuthRepository {
  /// The signed-in user right now, or `null`.
  AppUser? get currentUser;

  /// Emits the signed-in user, or `null` when signed out.
  Stream<AppUser?> authStateChanges();

  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AppUser> signInWithGoogle();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();

  /// Confirms the signed-in user's identity again with their password (needed
  /// before sensitive actions such as deleting the account).
  Future<void> reauthenticateWithPassword(String password);

  /// Confirms the signed-in user's identity again with their Google account.
  /// Throws `CancelledFailure` if the user closes the Google flow.
  Future<void> reauthenticateWithGoogle();

  /// Permanently deletes the signed-in user's account; the user is signed out.
  /// Call a `reauthenticate*` method first.
  Future<void> deleteCurrentUser();
}
