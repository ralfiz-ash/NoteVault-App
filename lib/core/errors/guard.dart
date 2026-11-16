import 'dart:async';

import '../logging/app_logger.dart';
import 'exception_mapper.dart';
import 'failure.dart';

/// Runs [action] and rethrows any error as a [Failure].
///
/// Repository implementations wrap data-source calls with this so callers
/// only ever have to handle [Failure]. The original error is logged (never
/// shown to the user).
Future<T> guardFailures<T>(
  Future<T> Function() action, {
  required ExceptionMapper mapper,
  AppLogger logger = const NoOpLogger(),
}) async {
  try {
    return await action();
  } on Failure {
    rethrow;
  } catch (error, stackTrace) {
    final failure = mapper.map(error, stackTrace);
    logger.error(
      'Operation failed: ${failure.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
    throw failure;
  }
}

/// Stream counterpart of [guardFailures]: errors emitted by [source] are
/// converted to [Failure]s (and logged); values pass through unchanged.
Stream<T> guardFailureStream<T>(
  Stream<T> source, {
  required ExceptionMapper mapper,
  AppLogger logger = const NoOpLogger(),
}) {
  return source.transform(
    StreamTransformer<T, T>.fromHandlers(
      handleError: (error, stackTrace, sink) {
        if (error is Failure) {
          sink.addError(error, stackTrace);
          return;
        }
        final failure = mapper.map(error, stackTrace);
        logger.error(
          'Stream failed: ${failure.runtimeType}',
          error: error,
          stackTrace: stackTrace,
        );
        sink.addError(failure, stackTrace);
      },
    ),
  );
}
