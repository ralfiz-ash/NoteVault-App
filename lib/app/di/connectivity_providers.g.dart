// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Connectivity chain: Connectivity plugin -> data source -> repository.

@ProviderFor(connectivity)
final connectivityProvider = ConnectivityProvider._();

/// Connectivity chain: Connectivity plugin -> data source -> repository.

final class ConnectivityProvider
    extends $FunctionalProvider<Connectivity, Connectivity, Connectivity>
    with $Provider<Connectivity> {
  /// Connectivity chain: Connectivity plugin -> data source -> repository.
  ConnectivityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityHash();

  @$internal
  @override
  $ProviderElement<Connectivity> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Connectivity create(Ref ref) {
    return connectivity(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Connectivity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Connectivity>(value),
    );
  }
}

String _$connectivityHash() => r'e66720f09edf1a8b09e450e1eaedd51da9443f0e';

@ProviderFor(connectivityDataSource)
final connectivityDataSourceProvider = ConnectivityDataSourceProvider._();

final class ConnectivityDataSourceProvider
    extends
        $FunctionalProvider<
          ConnectivityDataSource,
          ConnectivityDataSource,
          ConnectivityDataSource
        >
    with $Provider<ConnectivityDataSource> {
  ConnectivityDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityDataSourceHash();

  @$internal
  @override
  $ProviderElement<ConnectivityDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConnectivityDataSource create(Ref ref) {
    return connectivityDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectivityDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectivityDataSource>(value),
    );
  }
}

String _$connectivityDataSourceHash() =>
    r'32a175f46b0281d43d0f4ab8377dd844da6fc6c7';

@ProviderFor(connectivityRepository)
final connectivityRepositoryProvider = ConnectivityRepositoryProvider._();

final class ConnectivityRepositoryProvider
    extends
        $FunctionalProvider<
          ConnectivityRepository,
          ConnectivityRepository,
          ConnectivityRepository
        >
    with $Provider<ConnectivityRepository> {
  ConnectivityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityRepositoryHash();

  @$internal
  @override
  $ProviderElement<ConnectivityRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConnectivityRepository create(Ref ref) {
    return connectivityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectivityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectivityRepository>(value),
    );
  }
}

String _$connectivityRepositoryHash() =>
    r'685b8f71adb437d214ec01d6206dfe9ea288b07d';
