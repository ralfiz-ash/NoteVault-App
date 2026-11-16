import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/connectivity_providers.dart';
import '../../domain/entities/connectivity_status.dart';

part 'connection_status_provider.g.dart';

/// Live network status for the whole app (offline banner, and later the sync
/// engine). Use the [ConnectivityStatus] value, not ad-hoc boolean checks.
///
/// keepAlive: one platform subscription for the app's lifetime instead of
/// re-subscribing whenever a banner appears or disappears. The stream
/// subscription is closed by Riverpod when the container is disposed.
@Riverpod(keepAlive: true)
Stream<ConnectivityStatus> connectionStatus(Ref ref) =>
    ref.watch(connectivityRepositoryProvider).watchStatus();
