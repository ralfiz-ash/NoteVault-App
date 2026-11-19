/// How the user signed in, as reported to analytics.
enum LoginMethod { email, google }

/// The few product analytics events NoteVault reports.
///
/// Fire-and-forget: methods return immediately and never throw, so analytics
/// can never block or break signing in or saving a note (offline included).
/// Events carry no personal data and no note content.
abstract interface class AppAnalytics {
  /// A sign-in completed successfully.
  void logLogin(LoginMethod method);

  /// A note was saved successfully (created or edited).
  void logNoteSaved();
}
