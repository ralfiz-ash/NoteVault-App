// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's single [GoRouter], guarded by the auth state ([authRedirect]).
///
/// The router is created once; auth changes only re-run the redirect (via
/// [GoRouter.refreshListenable]) instead of rebuilding the router.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// The app's single [GoRouter], guarded by the auth state ([authRedirect]).
///
/// The router is created once; auth changes only re-run the redirect (via
/// [GoRouter.refreshListenable]) instead of rebuilding the router.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app's single [GoRouter], guarded by the auth state ([authRedirect]).
  ///
  /// The router is created once; auth changes only re-run the redirect (via
  /// [GoRouter.refreshListenable]) instead of rebuilding the router.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'76ebf89821b16e79e6597668b1bcf9caea512119';
