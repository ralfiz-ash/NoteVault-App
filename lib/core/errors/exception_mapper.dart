import 'dart:async';

import 'failure.dart';

/// Converts a low-level error into a [Failure].
///
/// Each infrastructure area (Firebase auth, Firestore, local database) will
/// provide its own mapper in the data layer. They are injected, so they can be
/// replaced in tests.
abstract interface class ExceptionMapper {
  Failure map(Object error, StackTrace stackTrace);
}

/// Handles errors that need no SDK knowledge. Anything else becomes an
/// [UnknownFailure] that keeps the original error as its cause.
class DefaultExceptionMapper implements ExceptionMapper {
  const DefaultExceptionMapper();

  @override
  Failure map(Object error, StackTrace stackTrace) {
    return switch (error) {
      Failure() => error,
      TimeoutException() => NetworkFailure(
        message: 'The request timed out. Please try again.',
        cause: error,
        stackTrace: stackTrace,
      ),
      _ => UnknownFailure(cause: error, stackTrace: stackTrace),
    };
  }
}
