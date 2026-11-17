import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user_model.dart';
import 'auth_remote_data_source.dart';
import 'google_id_token_source.dart';

/// [AuthRemoteDataSource] backed by Firebase Authentication.
///
/// Google sign-in:
/// - Android / iOS: native Google account picker -> ID token -> Firebase
///   credential.
/// - Web: Firebase's own Google popup (the Google Sign-In plugin's web flow
///   does not provide an ID token through `authenticate`).
class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  FirebaseAuthRemoteDataSource({
    required this._auth,
    required GoogleIdTokenSource googleIdTokens,
    required this.useWebPopupForGoogle,
  }) : _google = googleIdTokens;

  final FirebaseAuth _auth;
  final GoogleIdTokenSource _google;

  /// True on the web. Injected (instead of checking the platform here) so the
  /// data layer stays free of Flutter imports and both paths are testable.
  final bool useWebPopupForGoogle;

  @override
  AppUserModel? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : AppUserModel.fromFirebaseUser(user);
  }

  @override
  Stream<AppUserModel?> authStateChanges() => _auth.authStateChanges().map(
    (user) => user == null ? null : AppUserModel.fromFirebaseUser(user),
  );

  @override
  Future<AppUserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _requireUser(credential);
  }

  @override
  Future<AppUserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _requireUser(credential);
  }

  @override
  Future<AppUserModel> signInWithGoogle() async {
    if (useWebPopupForGoogle) {
      final credential = await _auth.signInWithPopup(GoogleAuthProvider());
      return _requireUser(credential);
    }
    final idToken = await _google.fetchIdToken();
    final credential = await _auth.signInWithCredential(
      GoogleAuthProvider.credential(idToken: idToken),
    );
    return _requireUser(credential);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  @override
  Future<void> signOut() async {
    if (!useWebPopupForGoogle) {
      try {
        await _google.signOut();
      } on Object {
        // Clearing the Google session is best effort; Firebase sign-out
        // below is what matters.
      }
    }
    await _auth.signOut();
  }

  AppUserModel _requireUser(UserCredential credential) {
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'null-user',
        message: 'Sign-in returned no user.',
      );
    }
    return AppUserModel.fromFirebaseUser(user);
  }
}
