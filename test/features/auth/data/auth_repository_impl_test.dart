import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/auth/data/datasources/firebase_auth_remote_data_source.dart';
import 'package:notevalult/features/auth/data/mappers/auth_exception_mapper.dart';
import 'package:notevalult/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:notevalult/features/auth/domain/entities/app_user.dart';

import '../../../helpers/fake_firebase_auth.dart';

void main() {
  late FakeFirebaseAuth auth;
  late FakeGoogleIdTokenSource google;
  late AuthRepositoryImpl repository;

  setUp(() {
    auth = FakeFirebaseAuth();
    google = FakeGoogleIdTokenSource();
    repository = AuthRepositoryImpl(
      remote: FirebaseAuthRemoteDataSource(
        auth: auth,
        googleIdTokens: google,
        useWebPopupForGoogle: false,
      ),
      exceptionMapper: const AuthExceptionMapper(),
    );
  });

  test('returns domain users, never Firebase types', () async {
    final AppUser user = await repository.signInWithEmailAndPassword(
      email: 'a@b.c',
      password: 'pw',
    );

    expect(user.uid, 'uid-1');
    expect(repository.currentUser, isA<AppUser>());
  });

  test('auth state stream emits domain users', () async {
    final states = <AppUser?>[];
    final sub = repository.authStateChanges().listen(states.add);
    addTearDown(sub.cancel);

    await repository.signInWithGoogle();
    await repository.signOut();
    await pumpEventQueue();

    expect(states.map((u) => u?.uid), ['uid-1', null]);
  });

  test('Firebase auth errors become application failures', () async {
    auth.nextError = FirebaseAuthException(code: 'email-already-in-use');
    await expectLater(
      repository.registerWithEmailAndPassword(email: 'a@b.c', password: 'pw'),
      throwsA(isA<AuthFailure>()),
    );

    auth.nextError = FirebaseAuthException(code: 'network-request-failed');
    await expectLater(
      repository.sendPasswordResetEmail('a@b.c'),
      throwsA(isA<NetworkFailure>()),
    );
  });

  test('closing the Google picker becomes CancelledFailure', () async {
    google.nextError = const GoogleSignInException(
      code: GoogleSignInExceptionCode.canceled,
    );

    await expectLater(
      repository.signInWithGoogle(),
      throwsA(isA<CancelledFailure>()),
    );
    expect(repository.currentUser, isNull);
  });
}
