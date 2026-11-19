/// How the user confirms their identity before their account is deleted.
sealed class AccountDeletionConfirmation {
  const AccountDeletionConfirmation();
}

/// Email/password accounts: the current password.
class ConfirmWithPassword extends AccountDeletionConfirmation {
  const ConfirmWithPassword(this.password);

  final String password;

  @override
  String toString() => 'ConfirmWithPassword(***)'; // never print the password
}

/// Google accounts: sign in with the same Google account again.
class ConfirmWithGoogle extends AccountDeletionConfirmation {
  const ConfirmWithGoogle();
}
