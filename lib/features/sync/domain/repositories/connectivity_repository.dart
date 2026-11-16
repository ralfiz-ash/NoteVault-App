import '../entities/connectivity_status.dart';

/// Contract for network state. Pending-note upload (sync) contracts are added
/// in the sync phase.
abstract interface class ConnectivityRepository {
  Stream<ConnectivityStatus> watchStatus();
}
