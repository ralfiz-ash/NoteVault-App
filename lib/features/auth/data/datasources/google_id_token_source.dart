import 'package:google_sign_in/google_sign_in.dart';

/// Obtains a Google ID token on Android/iOS so it can be exchanged for a
/// Firebase credential. Kept behind an interface so the Firebase data source
/// can be tested without the Google Sign-In plugin.
abstract interface class GoogleIdTokenSource {
  /// Shows the Google account picker. Throws `GoogleSignInException` (code
  /// `canceled` when the user backs out).
  Future<String> fetchIdToken();

  Future<void> signOut();
}

class GoogleSignInIdTokenSource implements GoogleIdTokenSource {
  GoogleSignInIdTokenSource(this._googleSignIn, {this.serverClientId});

  final GoogleSignIn _googleSignIn;

  /// OAuth "Web client" id. Optional on Android when `google-services.json`
  /// is processed by the Google services Gradle plugin.
  final String? serverClientId;

  Future<void>? _initialization;

  // GoogleSignIn.initialize must run exactly once before other calls.
  Future<void> _ensureInitialized() => _initialization ??= _googleSignIn
      .initialize(serverClientId: serverClientId);

  @override
  Future<String> fetchIdToken() async {
    await _ensureInitialized();
    final account = await _googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const GoogleSignInException(
        code: GoogleSignInExceptionCode.providerConfigurationError,
        description: 'Google did not return an ID token.',
      );
    }
    return idToken;
  }

  @override
  Future<void> signOut() async {
    if (_initialization == null) return; // never used Google this session
    await _ensureInitialized();
    await _googleSignIn.signOut();
  }
}
