// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Live network status for the whole app (offline banner, and later the sync
/// engine). Use the [ConnectivityStatus] value, not ad-hoc boolean checks.
///
/// keepAlive: one platform subscription for the app's lifetime instead of
/// re-subscribing whenever a banner appears or disappears. The stream
/// subscription is closed by Riverpod when the container is disposed.

@ProviderFor(connectionStatus)
final connectionStatusProvider = ConnectionStatusProvider._();

/// Live network status for the whole app (offline banner, and later the sync
/// engine). Use the [ConnectivityStatus] value, not ad-hoc boolean checks.
///
/// keepAlive: one platform subscription for the app's lifetime instead of
/// re-subscribing whenever a banner appears or disappears. The stream
/// subscription is closed by Riverpod when the container is disposed.

final class ConnectionStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<ConnectivityStatus>,
          ConnectivityStatus,
          Stream<ConnectivityStatus>
        >
    with
        $FutureModifier<ConnectivityStatus>,
        $StreamProvider<ConnectivityStatus> {
  /// Live network status for the whole app (offline banner, and later the sync
  /// engine). Use the [ConnectivityStatus] value, not ad-hoc boolean checks.
  ///
  /// keepAlive: one platform subscription for the app's lifetime instead of
  /// re-subscribing whenever a banner appears or disappears. The stream
  /// subscription is closed by Riverpod when the container is disposed.
  ConnectionStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionStatusHash();

  @$internal
  @override
  $StreamProviderElement<ConnectivityStatus> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ConnectivityStatus> create(Ref ref) {
    return connectionStatus(ref);
  }
}

String _$connectionStatusHash() => r'577fa3f48a4981f0babe9b30589d761c96e06c7a';
