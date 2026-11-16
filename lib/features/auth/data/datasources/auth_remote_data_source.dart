import '../models/app_user_model.dart';

/// Placeholder boundary for the Firebase Authentication SDK. The concrete
/// implementation is added in the Authentication phase.
abstract interface class AuthRemoteDataSource {
  Stream<AppUserModel?> authStateChanges();

  Future<void> signOut();
}
