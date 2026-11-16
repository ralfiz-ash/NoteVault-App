/// The signed-in user, independent of any auth provider SDK.
class AppUser {
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
  });

  /// Stable user id; also the owner id of the user's cloud data.
  final String uid;

  /// Can be null for providers that do not share an email address.
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;

  @override
  bool operator ==(Object other) =>
      other is AppUser &&
      other.uid == uid &&
      other.email == email &&
      other.displayName == displayName &&
      other.photoUrl == photoUrl &&
      other.emailVerified == emailVerified;

  @override
  int get hashCode =>
      Object.hash(uid, email, displayName, photoUrl, emailVerified);

  @override
  String toString() => 'AppUser($uid)';
}
