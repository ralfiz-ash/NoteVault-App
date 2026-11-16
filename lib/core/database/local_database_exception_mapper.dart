import '../errors/exception_mapper.dart';
import '../errors/failure.dart';

/// Maps anything thrown while talking to the local database to a
/// [LocalDatabaseFailure]. The original error is kept as the cause for
/// logging only.
class LocalDatabaseExceptionMapper implements ExceptionMapper {
  const LocalDatabaseExceptionMapper();

  @override
  Failure map(Object error, StackTrace stackTrace) {
    if (error is Failure) return error;
    return LocalDatabaseFailure(cause: error, stackTrace: stackTrace);
  }
}
