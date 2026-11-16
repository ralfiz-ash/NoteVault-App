import 'dart:async';

import 'package:firebase_core/firebase_core.dart';

import '../errors/exception_mapper.dart';
import '../errors/failure.dart';

/// Converts Cloud Firestore / Firebase errors into application failures.
/// Codes: https://firebase.google.com/docs/reference/kotlin/com/google/firebase/firestore/FirebaseFirestoreException.Code
class FirestoreExceptionMapper implements ExceptionMapper {
  const FirestoreExceptionMapper();

  @override
  Failure map(Object error, StackTrace stackTrace) {
    if (error is Failure) return error;
    if (error is TimeoutException) {
      return NetworkFailure(cause: error, stackTrace: stackTrace);
    }
    if (error is FirebaseException) {
      return switch (error.code) {
        'unavailable' || 'deadline-exceeded' => NetworkFailure(
          message: 'Could not reach the server. Please try again.',
          cause: error,
          stackTrace: stackTrace,
        ),
        'unauthenticated' => AuthFailure(
          message: 'Please sign in again.',
          cause: error,
          stackTrace: stackTrace,
        ),
        'permission-denied' => RemoteFailure(
          message: 'You do not have permission to access this data.',
          cause: error,
          stackTrace: stackTrace,
        ),
        'not-found' => NotFoundFailure(cause: error, stackTrace: stackTrace),
        'already-exists' => RemoteFailure(
          message: 'This item already exists.',
          cause: error,
          stackTrace: stackTrace,
        ),
        _ => RemoteFailure(cause: error, stackTrace: stackTrace),
      };
    }
    return UnknownFailure(cause: error, stackTrace: stackTrace);
  }
}
