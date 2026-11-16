import '../../domain/entities/connectivity_status.dart';

/// Placeholder boundary for the platform connectivity plugin.
abstract interface class ConnectivityDataSource {
  Stream<ConnectivityStatus> watchStatus();
}
