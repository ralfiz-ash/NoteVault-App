import 'package:connectivity_plus/connectivity_plus.dart';

import '../../domain/entities/connectivity_status.dart';
import 'connectivity_data_source.dart';

/// [ConnectivityDataSource] backed by `connectivity_plus` (Android, iOS, Web).
class ConnectivityPlusDataSource implements ConnectivityDataSource {
  ConnectivityPlusDataSource(this._connectivity);

  final Connectivity _connectivity;

  @override
  Stream<ConnectivityStatus> watchStatus() async* {
    yield toStatus(await _connectivity.checkConnectivity());
    yield* _connectivity.onConnectivityChanged.map(toStatus);
  }

  /// Any interface other than `none` counts as connected.
  static ConnectivityStatus toStatus(List<ConnectivityResult> results) {
    if (results.isEmpty) return ConnectivityStatus.unknown;
    return results.any((r) => r != ConnectivityResult.none)
        ? ConnectivityStatus.connected
        : ConnectivityStatus.disconnected;
  }
}
