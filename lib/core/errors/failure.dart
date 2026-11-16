/// Application-level errors shared by every feature.
///
/// Data-layer code catches low-level exceptions (Firebase, database, network)
/// and converts them into a [Failure] with an [ExceptionMapper]; the domain
/// and presentation layers only ever see [Failure]s.
///
/// [message] is safe to show to the user. [cause] and [stackTrace] keep the
/// original error for logging and debugging only: do not render or inspect
/// [cause] in UI code.
sealed class Failure implements Exception {
  const Failure({required this.message, this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

/// No connection, timeout or other transport problem.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No network connection. Please try again.',
    super.cause,
    super.stackTrace,
  });
}

/// Sign-in, sign-up, session or permission problem.
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed. Please try again.',
    super.cause,
    super.stackTrace,
  });
}

/// Local database read/write problem.
class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure({
    super.message = 'Could not access data stored on this device.',
    super.cause,
    super.stackTrace,
  });
}

/// The remote backend (Firestore, server) rejected or failed a request.
class RemoteFailure extends Failure {
  const RemoteFailure({
    super.message = 'The server could not complete the request.',
    super.cause,
    super.stackTrace,
  });
}

/// Input did not pass validation. [fieldErrors] maps a field name to a
/// user-readable problem.
class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Please check the highlighted fields.',
    this.fieldErrors = const {},
    super.cause,
    super.stackTrace,
  });

  final Map<String, String> fieldErrors;
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The requested item was not found.',
    super.cause,
    super.stackTrace,
  });
}

/// The user deliberately stopped the operation (for example closed the
/// Google account picker). Usually not shown as an error.
class CancelledFailure extends Failure {
  const CancelledFailure({
    super.message = 'The operation was cancelled.',
    super.cause,
    super.stackTrace,
  });
}

/// Anything not recognised by a mapper.
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Something went wrong. Please try again.',
    super.cause,
    super.stackTrace,
  });
}
