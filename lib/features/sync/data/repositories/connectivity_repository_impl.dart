import '../../../../core/errors/exception_mapper.dart';
import '../../../../core/errors/guard.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/connectivity_status.dart';
import '../../domain/repositories/connectivity_repository.dart';
import '../datasources/connectivity_data_source.dart';

class ConnectivityRepositoryImpl implements ConnectivityRepository {
  const ConnectivityRepositoryImpl({
    required this.dataSource,
    required this.exceptionMapper,
    this.logger = const NoOpLogger(),
  });

  final ConnectivityDataSource dataSource;
  final ExceptionMapper exceptionMapper;
  final AppLogger logger;

  /// Repeated values are dropped, so listeners only hear real changes.
  @override
  Stream<ConnectivityStatus> watchStatus() => guardFailureStream(
    dataSource.watchStatus().distinct(),
    mapper: exceptionMapper,
    logger: logger,
  );
}
