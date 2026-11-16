import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/features/auth/data/datasources/firebase_auth_remote_data_source.dart';

import '../../../helpers/fake_firebase_auth.dart';

void main() {
  late FakeFirebaseAuth auth;
  late FakeGoogleIdTokenSource google;

  FirebaseAuthRemoteDataSource source({bool web = false}) =>
      FirebaseAuthRemoteDataSource(
        auth: auth,
        googleIdTokens: google,
        useWebPopupForGoogle: web,
      );

  setUp(() {
    auth = FakeFirebaseAuth();
    google = FakeGoogleIdTokenSource();
  });

  test('currentUser and auth state are mapped to models', () async {
    final ds = source();
    expect(ds.currentUser, isNull);

    final states = <String?>[];
    final sub = ds.authStateChanges().listen((u) => states.add(u?.uid));
    addTearDown(sub.cancel);

    auth.emit(FakeUser(uid: 'u1'));
    auth.emit(null);
    await pumpEventQueue();

    expect(states, ['u1', null]);
  });

  test('email sign-in and registration trim the email', () async {
    final ds = source();

    final user = await ds.signInWithEmailAndPassword(
      email: ' a@b.c ',
      password: 'secret',
    );
    await ds.registerWithEmailAndPassword(email: 'n@b.c ', password: 'pw');

    expect(user.uid, 'uid-1');
    expect(auth.calls, ['signIn:a@b.c', 'register:n@b.c']);
    expect(ds.currentUser?.uid, 'uid-1');
  });

  test(
    'Google on mobile exchanges the Google ID token for a credential',
    () async {
      final user = await source().signInWithGoogle();

      expect(user.uid, 'uid-1');
      expect(auth.calls, ['credential']);
      expect(auth.lastCredential?.providerId, 'google.com');
    },
  );

  test('Google on web uses the Firebase popup and not the plugin', () async {
    google.nextError = StateError('plugin must not be used on web');

    await source(web: true).signInWithGoogle();

    expect(auth.calls, ['popup']);
    expect(auth.lastPopupProvider, isA<GoogleAuthProvider>());
  });

  test('sign-out clears Google (mobile) and Firebase sessions', () async {
    final ds = source();
    await ds.signInWithGoogle();

    await ds.signOut();

    expect(google.signOuts, 1);
    expect(auth.calls.last, 'signOut');
    expect(ds.currentUser, isNull);
  });

  test(
    'sign-out still signs out of Firebase if Google sign-out fails',
    () async {
      final failingGoogle = _ThrowingSignOutGoogle();
      final ds = FirebaseAuthRemoteDataSource(
        auth: auth,
        googleIdTokens: failingGoogle,
        useWebPopupForGoogle: false,
      );

      await ds.signOut();

      expect(auth.calls, ['signOut']);
    },
  );

  test('password reset trims the email', () async {
    await source().sendPasswordResetEmail(' r@b.c');
    expect(auth.calls, ['reset:r@b.c']);
  });

  test('SDK errors propagate unchanged (the repository maps them)', () async {
    auth.nextError = FirebaseAuthException(code: 'wrong-password');
    await expectLater(
      source().signInWithEmailAndPassword(email: 'a@b.c', password: 'x'),
      throwsA(isA<FirebaseAuthException>()),
    );
  });
}

class _ThrowingSignOutGoogle extends FakeGoogleIdTokenSource {
  @override
  Future<void> signOut() async => throw StateError('no google session');
}
