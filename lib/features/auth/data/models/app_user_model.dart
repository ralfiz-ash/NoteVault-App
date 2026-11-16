import '../../domain/entities/app_user.dart';

/// Serializable form of [AppUser]. Plain maps only: infrastructure types
/// (e.g. Firebase `User`) are converted to this inside the data source.
class AppUserModel {
  const AppUserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;

  factory AppUserModel.fromMap(Map<String, dynamic> map) => AppUserModel(
    uid: map['uid'] as String,
    email: map['email'] as String,
    displayName: map['displayName'] as String?,
    photoUrl: map['photoUrl'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
  };

  AppUser toEntity() => AppUser(
    uid: uid,
    email: email,
    displayName: displayName,
    photoUrl: photoUrl,
  );
}
