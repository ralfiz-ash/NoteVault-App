import '../models/app_user_model.dart';

/// Boundary to the remote authentication service (Firebase Authentication).
/// Speaks only in [AppUserModel]; SDK errors propagate to the repository,
/// which converts them to `Failure`s.
abstract interface class AuthRemoteDataSource {
  AppUserModel? get currentUser;

  Stream<AppUserModel?> authStateChanges();

  Future<AppUserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AppUserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AppUserModel> signInWithGoogle();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();

  Future<void> reauthenticateWithPassword(String password);

  Future<void> reauthenticateWithGoogle();

  Future<void> deleteCurrentUser();
}
