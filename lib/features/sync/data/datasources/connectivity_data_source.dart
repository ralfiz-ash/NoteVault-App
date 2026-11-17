import '../../domain/entities/connectivity_status.dart';

/// Boundary to the platform's network information.
abstract interface class ConnectivityDataSource {
  /// Emits the current status first, then every change.
  Stream<ConnectivityStatus> watchStatus();
}
