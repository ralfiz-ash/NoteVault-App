// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One sync repository per signed-in user's database. keepAlive: it holds
/// the single-flight guard, so there must be exactly one instance.

@ProviderFor(syncRepository)
final syncRepositoryProvider = SyncRepositoryProvider._();

/// One sync repository per signed-in user's database. keepAlive: it holds
/// the single-flight guard, so there must be exactly one instance.

final class SyncRepositoryProvider
    extends $FunctionalProvider<SyncRepository, SyncRepository, SyncRepository>
    with $Provider<SyncRepository> {
  /// One sync repository per signed-in user's database. keepAlive: it holds
  /// the single-flight guard, so there must be exactly one instance.
  SyncRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncRepositoryHash();

  @$internal
  @override
  $ProviderElement<SyncRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncRepository create(Ref ref) {
    return syncRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncRepository>(value),
    );
  }
}

String _$syncRepositoryHash() => r'f886398811f9ea5df0e5e82afc1cad230a3461e4';
