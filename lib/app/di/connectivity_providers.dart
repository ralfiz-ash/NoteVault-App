import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/errors/exception_mapper.dart';
import '../../features/sync/data/datasources/connectivity_data_source.dart';
import '../../features/sync/data/datasources/connectivity_plus_data_source.dart';
import '../../features/sync/data/repositories/connectivity_repository_impl.dart';
import '../../features/sync/domain/repositories/connectivity_repository.dart';
import 'core_providers.dart';

part 'connectivity_providers.g.dart';

/// Connectivity chain: Connectivity plugin -> data source -> repository.

@Riverpod(keepAlive: true)
Connectivity connectivity(Ref ref) => Connectivity();

@Riverpod(keepAlive: true)
ConnectivityDataSource connectivityDataSource(Ref ref) =>
    ConnectivityPlusDataSource(ref.watch(connectivityProvider));

@Riverpod(keepAlive: true)
ConnectivityRepository connectivityRepository(Ref ref) =>
    ConnectivityRepositoryImpl(
      dataSource: ref.watch(connectivityDataSourceProvider),
      exceptionMapper: const DefaultExceptionMapper(),
      logger: ref.watch(appLoggerProvider),
    );
