import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/features/auth/data/datasources/google_id_token_source.dart';

class FakeUserInfo extends Fake implements UserInfo {
  FakeUserInfo(this.providerId);

  @override
  final String providerId;
}

class FakeUser extends Fake implements User {
  FakeUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.emailVerified = false,
    List<String> providerIds = const [],
  }) : providerData = [for (final id in providerIds) FakeUserInfo(id)];

  @override
  final List<UserInfo> providerData;

  /// Reauthentication / deletion calls on this user.
  final calls = <String>[];
  AuthCredential? lastCredential;

  /// If set, the next reauthentication / deletion throws it.
  Object? nextError;

  /// Called after [delete] succeeds (the fake auth signs out).
  void Function()? onDeleted;

  Future<void> _step(String call) async {
    calls.add(call);
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
  }

  @override
  Future<UserCredential> reauthenticateWithCredential(
    AuthCredential credential,
  ) async {
    lastCredential = credential;
    await _step('reauth:${credential.providerId}');
    return FakeUserCredential(this);
  }

  @override
  Future<UserCredential> reauthenticateWithPopup(AuthProvider provider) async {
    await _step('reauthPopup:${provider.providerId}');
    return FakeUserCredential(this);
  }

  @override
  Future<void> delete() async {
    await _step('delete');
    onDeleted?.call();
  }

  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final String? photoURL;
  @override
  final bool emailVerified;
}

class FakeUserCredential extends Fake implements UserCredential {
  FakeUserCredential(this.user);

  @override
  final User? user;
}

/// Minimal in-memory stand-in for [FirebaseAuth]. Set [nextError] to make the
/// next call throw it.
class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  final _changes = StreamController<User?>.broadcast();
  User? _current;
  Object? nextError;
  User userForSignIn = FakeUser(uid: 'uid-1', email: 'a@b.c');

  final calls = <String>[];
  AuthCredential? lastCredential;
  AuthProvider? lastPopupProvider;

  void emit(User? user) {
    _current = user;
    if (user is FakeUser) user.onDeleted = () => emit(null);
    _changes.add(user);
  }

  Future<UserCredential> _signIn(String call) async {
    calls.add(call);
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
    emit(userForSignIn);
    return FakeUserCredential(userForSignIn);
  }

  @override
  User? get currentUser => _current;

  @override
  Stream<User?> authStateChanges() => _changes.stream;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) => _signIn('signIn:$email');

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) => _signIn('register:$email');

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) {
    lastCredential = credential;
    return _signIn('credential');
  }

  @override
  Future<UserCredential> signInWithPopup(AuthProvider provider) {
    lastPopupProvider = provider;
    return _signIn('popup');
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) async {
    calls.add('reset:$email');
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    emit(null);
  }
}

class FakeGoogleIdTokenSource implements GoogleIdTokenSource {
  Object? nextError;
  int signOuts = 0;

  @override
  Future<String> fetchIdToken() async {
    final error = nextError;
    if (error != null) {
      nextError = null;
      throw error;
    }
    return 'google-id-token';
  }

  @override
  Future<void> signOut() async => signOuts++;
}
