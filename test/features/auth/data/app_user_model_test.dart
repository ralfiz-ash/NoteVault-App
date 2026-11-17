import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/features/auth/data/models/app_user_model.dart';
import 'package:notevalult/features/auth/domain/entities/app_user.dart';

import '../../../helpers/fake_firebase_auth.dart';

void main() {
  test('Firebase User -> data model -> domain entity keeps every field', () {
    final user = FakeUser(
      uid: 'u1',
      email: 'me@example.com',
      displayName: 'Me',
      photoURL: 'https://example.com/me.png',
      emailVerified: true,
    );

    final entity = AppUserModel.fromFirebaseUser(user).toEntity();

    expect(
      entity,
      const AppUser(
        uid: 'u1',
        email: 'me@example.com',
        displayName: 'Me',
        photoUrl: 'https://example.com/me.png',
        emailVerified: true,
      ),
    );
  });

  test('a user without email or profile maps to nulls', () {
    final entity = AppUserModel.fromFirebaseUser(FakeUser(uid: 'u2'))
        .toEntity();

    expect(entity.uid, 'u2');
    expect(entity.email, isNull);
    expect(entity.emailVerified, isFalse);
  });

  test('map round trip', () {
    const model = AppUserModel(uid: 'u3', email: 'x@y.z');
    expect(AppUserModel.fromMap(model.toMap()).toEntity(), model.toEntity());
  });
}
