import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../domain/entities/app_user.dart';

/// Data-layer form of a user. Firebase's `User` is converted to this inside
/// the data layer and never leaves it.
class AppUserModel {
  const AppUserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;

  factory AppUserModel.fromFirebaseUser(fb.User user) => AppUserModel(
    uid: user.uid,
    email: user.email,
    displayName: user.displayName,
    photoUrl: user.photoURL,
    emailVerified: user.emailVerified,
  );

  factory AppUserModel.fromMap(Map<String, dynamic> map) => AppUserModel(
    uid: map['uid'] as String,
    email: map['email'] as String?,
    displayName: map['displayName'] as String?,
    photoUrl: map['photoUrl'] as String?,
    emailVerified: map['emailVerified'] as bool? ?? false,
  );

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'emailVerified': emailVerified,
  };

  AppUser toEntity() => AppUser(
    uid: uid,
    email: email,
    displayName: displayName,
    photoUrl: photoUrl,
    emailVerified: emailVerified,
  );
}
