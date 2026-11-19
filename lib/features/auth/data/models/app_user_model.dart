import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/entities/app_user.dart';
import '../../domain/entities/sign_in_method.dart';

/// Data-layer form of a user. Firebase's `User` is converted to this inside
/// the data layer and never leaves it.
class AppUserModel {
  const AppUserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
    this.signInMethods = const {},
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;
  final Set<SignInMethod> signInMethods;

  /// Firebase provider ids of the methods NoteVault supports.
  static const _providerIds = {
    'password': SignInMethod.emailPassword,
    'google.com': SignInMethod.google,
  };

  factory AppUserModel.fromFirebaseUser(fb.User user) => AppUserModel(
    uid: user.uid,
    email: user.email,
    displayName: user.displayName,
    photoUrl: user.photoURL,
    emailVerified: user.emailVerified,
    signInMethods: {
      for (final info in user.providerData) ?_providerIds[info.providerId],
    },
  );

  factory AppUserModel.fromMap(Map<String, dynamic> map) => AppUserModel(
    uid: map['uid'] as String,
    email: map['email'] as String?,
    displayName: map['displayName'] as String?,
    photoUrl: map['photoUrl'] as String?,
    emailVerified: map['emailVerified'] as bool? ?? false,
    signInMethods: {
      for (final name in (map['signInMethods'] as List?) ?? const [])
        ?SignInMethod.values.asNameMap()[name],
    },
  );

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'emailVerified': emailVerified,
    'signInMethods': [for (final method in signInMethods) method.name],
  };

  AppUser toEntity() => AppUser(
    uid: uid,
    email: email,
    displayName: displayName,
    photoUrl: photoUrl,
    emailVerified: emailVerified,
    signInMethods: signInMethods,
  );
}
