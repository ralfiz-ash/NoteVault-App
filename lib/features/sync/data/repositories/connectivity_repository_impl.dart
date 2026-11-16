import '../../domain/entities/connectivity_status.dart';
import '../../domain/repositories/connectivity_repository.dart';
import '../datasources/connectivity_data_source.dart';

class ConnectivityRepositoryImpl implements ConnectivityRepository {
  const ConnectivityRepositoryImpl(this.dataSource);

  final ConnectivityDataSource dataSource;

  @override
  Stream<ConnectivityStatus> watchStatus() =>
      throw UnimplementedError('Implemented in the Sync phase.');
}
