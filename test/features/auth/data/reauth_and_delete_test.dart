import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/auth/data/datasources/firebase_auth_remote_data_source.dart';
import 'package:notevalult/features/auth/data/mappers/auth_exception_mapper.dart';
import 'package:notevalult/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:notevalult/features/auth/domain/entities/sign_in_method.dart';

import '../../../helpers/fake_firebase_auth.dart';

void main() {
  late FakeFirebaseAuth auth;
  late FakeGoogleIdTokenSource google;
  late FakeUser user;

  FirebaseAuthRemoteDataSource source({bool web = false}) =>
      FirebaseAuthRemoteDataSource(
        auth: auth,
        googleIdTokens: google,
        useWebPopupForGoogle: web,
      );

  AuthRepositoryImpl repo() => AuthRepositoryImpl(
    remote: source(),
    exceptionMapper: const AuthExceptionMapper(),
  );

  setUp(() {
    auth = FakeFirebaseAuth();
    google = FakeGoogleIdTokenSource();
    user = FakeUser(
      uid: 'u1',
      email: 'a@b.c',
      providerIds: ['password', 'google.com', 'phone'],
    );
    auth.emit(user);
  });

  test('sign-in methods come from the linked providers', () {
    expect(repo().currentUser!.signInMethods, {
      SignInMethod.emailPassword,
      SignInMethod.google,
    });
  });

  test('password reauthentication uses the account email', () async {
    await repo().reauthenticateWithPassword('secret');
    expect(user.calls, ['reauth:password']);
    expect(user.lastCredential?.providerId, 'password');
  });

  test('wrong password -> "Incorrect password."', () async {
    user.nextError = FirebaseAuthException(code: 'invalid-credential');
    await expectLater(
      repo().reauthenticateWithPassword('wrong'),
      throwsA(
        isA<AuthFailure>().having(
          (f) => f.message,
          'message',
          'Incorrect password.',
        ),
      ),
    );
  });

  test(
    'Google reauthentication: native token on mobile, popup on web',
    () async {
      await repo().reauthenticateWithGoogle();
      expect(user.calls, ['reauth:google.com']);

      await source(web: true).reauthenticateWithGoogle();
      expect(user.calls.last, 'reauthPopup:google.com');
    },
  );

  test('another Google account -> friendly message', () async {
    user.nextError = FirebaseAuthException(code: 'user-mismatch');
    await expectLater(
      repo().reauthenticateWithGoogle(),
      throwsA(isA<AuthFailure>()),
    );
  });

  test('deleting the user signs out and clears the Google session', () async {
    await repo().deleteCurrentUser();
    expect(user.calls, ['delete']);
    expect(auth.currentUser, isNull);
    expect(google.signOuts, 1);
  });

  test('nobody signed in -> AuthFailure', () async {
    auth.emit(null);
    await expectLater(repo().deleteCurrentUser(), throwsA(isA<AuthFailure>()));
  });
}
