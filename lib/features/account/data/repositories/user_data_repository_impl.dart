import '../../../../core/errors/exception_mapper.dart';
import '../../../../core/errors/guard.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/repositories/user_data_repository.dart';
import '../datasources/user_data_cloud_data_source.dart';
import '../datasources/user_data_local_data_source.dart';

class UserDataRepositoryImpl implements UserDataRepository {
  const UserDataRepositoryImpl({
    required this.cloud,
    required this.local,
    required this.cloudExceptionMapper,
    required this.localExceptionMapper,
    this.logger = const NoOpLogger(),
  });

  final UserDataCloudDataSource cloud;
  final UserDataLocalDataSource local;
  final ExceptionMapper cloudExceptionMapper;
  final ExceptionMapper localExceptionMapper;
  final AppLogger logger;

  @override
  Future<void> discardPendingSync() => guardFailures(
    local.clearSyncQueue,
    mapper: localExceptionMapper,
    logger: logger,
  );

  @override
  Future<void> deleteCloudData(String userId) => guardFailures(
    () => cloud.deleteAllUserData(userId),
    mapper: cloudExceptionMapper,
    logger: logger,
  );

  @override
  Future<void> deleteLocalData() => guardFailures(
    local.deleteAll,
    mapper: localExceptionMapper,
    logger: logger,
  );
}
