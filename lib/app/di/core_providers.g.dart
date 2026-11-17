// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composition root for shared dependencies.
///
/// Everything infrastructure-related (repositories, data sources, database,
/// Firebase) will be exposed from `lib/app/di/` as providers, so the rest of
/// the app depends on abstractions and tests can swap them with
/// `ProviderScope(overrides: [...])` or `ProviderContainer(overrides: [...])`.
/// Application configuration. Overridden in `bootstrap()` and in tests.

@ProviderFor(appConfig)
final appConfigProvider = AppConfigProvider._();

/// Composition root for shared dependencies.
///
/// Everything infrastructure-related (repositories, data sources, database,
/// Firebase) will be exposed from `lib/app/di/` as providers, so the rest of
/// the app depends on abstractions and tests can swap them with
/// `ProviderScope(overrides: [...])` or `ProviderContainer(overrides: [...])`.
/// Application configuration. Overridden in `bootstrap()` and in tests.

final class AppConfigProvider
    extends $FunctionalProvider<AppConfig, AppConfig, AppConfig>
    with $Provider<AppConfig> {
  /// Composition root for shared dependencies.
  ///
  /// Everything infrastructure-related (repositories, data sources, database,
  /// Firebase) will be exposed from `lib/app/di/` as providers, so the rest of
  /// the app depends on abstractions and tests can swap them with
  /// `ProviderScope(overrides: [...])` or `ProviderContainer(overrides: [...])`.
  /// Application configuration. Overridden in `bootstrap()` and in tests.
  AppConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appConfigHash();

  @$internal
  @override
  $ProviderElement<AppConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppConfig create(Ref ref) {
    return appConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppConfig>(value),
    );
  }
}

String _$appConfigHash() => r'87f9d20a2d92252672162b2ce97547b7b2479239';

/// App-wide logger. Overridden in `bootstrap()` and in tests.

@ProviderFor(appLogger)
final appLoggerProvider = AppLoggerProvider._();

/// App-wide logger. Overridden in `bootstrap()` and in tests.

final class AppLoggerProvider
    extends $FunctionalProvider<AppLogger, AppLogger, AppLogger>
    with $Provider<AppLogger> {
  /// App-wide logger. Overridden in `bootstrap()` and in tests.
  AppLoggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLoggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLoggerHash();

  @$internal
  @override
  $ProviderElement<AppLogger> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppLogger create(Ref ref) {
    return appLogger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLogger value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLogger>(value),
    );
  }
}

String _$appLoggerHash() => r'96b27942e0241f3e42b252e84b84c877aa8eb90e';
