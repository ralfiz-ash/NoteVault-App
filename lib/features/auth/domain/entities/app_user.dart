import 'sign_in_method.dart';

/// The signed-in user, independent of any auth provider SDK.
class AppUser {
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
    this.signInMethods = const {},
  });

  /// Stable user id; also the owner id of the user's cloud data.
  final String uid;

  /// Can be null for providers that do not share an email address.
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;

  /// The sign-in methods linked to this account (e.g. to choose how to
  /// confirm the user's identity before deleting the account).
  final Set<SignInMethod> signInMethods;

  @override
  bool operator ==(Object other) =>
      other is AppUser &&
      other.uid == uid &&
      other.email == email &&
      other.displayName == displayName &&
      other.photoUrl == photoUrl &&
      other.emailVerified == emailVerified &&
      other.signInMethods.length == signInMethods.length &&
      other.signInMethods.containsAll(signInMethods);

  @override
  int get hashCode => Object.hash(
    uid,
    email,
    displayName,
    photoUrl,
    emailVerified,
    Object.hashAllUnordered(signInMethods),
  );

  @override
  String toString() => 'AppUser($uid)';
}
