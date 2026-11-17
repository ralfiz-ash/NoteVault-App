/// Input for email/password use cases. Transient: never stored or logged
/// ([toString] hides the password).
class EmailPasswordParams {
  const EmailPasswordParams({required this.email, required this.password});

  final String email;
  final String password;

  @override
  String toString() => 'EmailPasswordParams($email, ***)';
}
