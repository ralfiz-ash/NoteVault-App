/// Input rules for authentication forms, shared by the screens (to show
/// messages before anything is sent) and the use cases (as a safety net).
///
/// Each method returns a user-facing message, or `null` when valid.
abstract final class AuthValidators {
  /// Firebase requires 6; NoteVault asks for a little more.
  static const minPasswordLength = 8;

  static final RegExp _email = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$",
  );

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (!_email.hasMatch(email)) return 'Enter a valid email address';
    return null;
  }

  /// For signing in: only presence is checked (existing accounts may predate
  /// the length rule).
  static String? loginPassword(String? value) =>
      (value == null || value.isEmpty) ? 'Password is required' : null;

  /// For new accounts.
  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }
}
