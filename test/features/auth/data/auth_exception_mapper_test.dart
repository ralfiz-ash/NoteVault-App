import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/auth/data/mappers/auth_exception_mapper.dart';

void main() {
  const mapper = AuthExceptionMapper();
  Failure map(Object e) => mapper.map(e, StackTrace.empty);

  group('FirebaseAuthException', () {
    test('wrong credentials -> AuthFailure with a friendly message', () {
      for (final code in [
        'wrong-password',
        'user-not-found',
        'invalid-credential',
      ]) {
        final f = map(FirebaseAuthException(code: code));
        expect(f, isA<AuthFailure>(), reason: code);
        expect(f.message, 'Incorrect email or password.');
      }
    });

    test('invalid email / weak password -> ValidationFailure with field', () {
      final email = map(FirebaseAuthException(code: 'invalid-email'));
      final weak = map(FirebaseAuthException(code: 'weak-password'));

      expect(email, isA<ValidationFailure>());
      expect((email as ValidationFailure).fieldErrors, contains('email'));
      expect((weak as ValidationFailure).fieldErrors, contains('password'));
    });

    test('network -> NetworkFailure, popup closed -> CancelledFailure', () {
      expect(
        map(FirebaseAuthException(code: 'network-request-failed')),
        isA<NetworkFailure>(),
      );
      expect(
        map(FirebaseAuthException(code: 'popup-closed-by-user')),
        isA<CancelledFailure>(),
      );
    });

    test('unknown codes -> AuthFailure, original kept as cause', () {
      final error = FirebaseAuthException(code: 'something-new');
      final f = map(error);
      expect(f, isA<AuthFailure>());
      expect(f.cause, same(error));
    });
  });

  group('GoogleSignInException', () {
    test('canceled / interrupted -> CancelledFailure', () {
      for (final code in [
        GoogleSignInExceptionCode.canceled,
        GoogleSignInExceptionCode.interrupted,
      ]) {
        expect(map(GoogleSignInException(code: code)), isA<CancelledFailure>());
      }
    });

    test('configuration errors -> AuthFailure', () {
      final f = map(
        const GoogleSignInException(
          code: GoogleSignInExceptionCode.clientConfigurationError,
        ),
      );
      expect(f, isA<AuthFailure>());
      expect(f.message, contains('not set up'));
    });
  });

  test('timeouts -> NetworkFailure; other errors -> UnknownFailure', () {
    expect(map(TimeoutException('t')), isA<NetworkFailure>());
    expect(map(StateError('x')), isA<UnknownFailure>());
  });

  test('existing Failures pass through', () {
    const f = CancelledFailure();
    expect(map(f), same(f));
  });
}
