import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/exception_mapper.dart';
import '../../../../core/errors/failure.dart';

/// Converts Firebase Authentication and Google Sign-In errors into
/// application failures with user-friendly messages.
class AuthExceptionMapper implements ExceptionMapper {
  const AuthExceptionMapper();

  @override
  Failure map(Object error, StackTrace stackTrace) {
    if (error is Failure) return error;
    if (error is TimeoutException) {
      return NetworkFailure(cause: error, stackTrace: stackTrace);
    }
    if (error is FirebaseAuthException) return _fromFirebase(error, stackTrace);
    if (error is GoogleSignInException) return _fromGoogle(error, stackTrace);
    return UnknownFailure(cause: error, stackTrace: stackTrace);
  }

  Failure _fromFirebase(FirebaseAuthException e, StackTrace st) {
    AuthFailure auth(String message) =>
        AuthFailure(message: message, cause: e, stackTrace: st);

    return switch (e.code) {
      'invalid-email' => ValidationFailure(
        message: 'Please enter a valid email address.',
        fieldErrors: const {'email': 'Invalid email address.'},
        cause: e,
        stackTrace: st,
      ),
      'weak-password' => ValidationFailure(
        message: 'Please choose a stronger password.',
        fieldErrors: const {'password': 'Password is too weak.'},
        cause: e,
        stackTrace: st,
      ),
      'missing-password' => ValidationFailure(
        message: 'Please enter your password.',
        fieldErrors: const {'password': 'Password is required.'},
        cause: e,
        stackTrace: st,
      ),
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' ||
      'INVALID_LOGIN_CREDENTIALS' => auth('Incorrect email or password.'),
      'email-already-in-use' => auth(
        'An account already exists for this email.',
      ),
      'account-exists-with-different-credential' => auth(
        'This email is already registered with a different sign-in method.',
      ),
      'user-disabled' => auth('This account has been disabled.'),
      'too-many-requests' => auth(
        'Too many attempts. Please wait a moment and try again.',
      ),
      'operation-not-allowed' => auth(
        'This sign-in method is not enabled for NoteVault.',
      ),
      'requires-recent-login' => auth('Please sign in again to continue.'),
      'popup-closed-by-user' ||
      'cancelled-popup-request' ||
      'web-context-canceled' => CancelledFailure(cause: e, stackTrace: st),
      'popup-blocked' => auth(
        'The sign-in popup was blocked. Please allow popups and try again.',
      ),
      'network-request-failed' => NetworkFailure(cause: e, stackTrace: st),
      _ => auth('Authentication failed. Please try again.'),
    };
  }

  Failure _fromGoogle(GoogleSignInException e, StackTrace st) {
    return switch (e.code) {
      GoogleSignInExceptionCode.canceled ||
      GoogleSignInExceptionCode.interrupted => CancelledFailure(
        cause: e,
        stackTrace: st,
      ),
      GoogleSignInExceptionCode.clientConfigurationError ||
      GoogleSignInExceptionCode.providerConfigurationError => AuthFailure(
        message: 'Google sign-in is not set up correctly for this app.',
        cause: e,
        stackTrace: st,
      ),
      GoogleSignInExceptionCode.uiUnavailable => AuthFailure(
        message: 'Google sign-in is not available right now.',
        cause: e,
        stackTrace: st,
      ),
      _ => AuthFailure(
        message: 'Google sign-in failed. Please try again.',
        cause: e,
        stackTrace: st,
      ),
    };
  }
}
