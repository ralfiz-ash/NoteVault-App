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
