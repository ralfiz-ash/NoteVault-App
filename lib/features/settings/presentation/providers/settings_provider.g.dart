// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App settings (theme mode and note sort order) and how to change them.
///
/// Held in memory for now; loading/saving through `SettingsRepository` is
/// added in the Settings phase without changing this provider's API.
///
/// keepAlive: settings are app-wide and must not reset to defaults when no
/// screen happens to be listening.

@ProviderFor(Settings)
final settingsProvider = SettingsProvider._();

/// App settings (theme mode and note sort order) and how to change them.
///
/// Held in memory for now; loading/saving through `SettingsRepository` is
/// added in the Settings phase without changing this provider's API.
///
/// keepAlive: settings are app-wide and must not reset to defaults when no
/// screen happens to be listening.
final class SettingsProvider extends $NotifierProvider<Settings, AppSettings> {
  /// App settings (theme mode and note sort order) and how to change them.
  ///
  /// Held in memory for now; loading/saving through `SettingsRepository` is
  /// added in the Settings phase without changing this provider's API.
  ///
  /// keepAlive: settings are app-wide and must not reset to defaults when no
  /// screen happens to be listening.
  SettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsHash();

  @$internal
  @override
  Settings create() => Settings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSettings>(value),
    );
  }
}

String _$settingsHash() => r'212937beefd001a9ff73723c86d2ca502a2c968b';

/// App settings (theme mode and note sort order) and how to change them.
///
/// Held in memory for now; loading/saving through `SettingsRepository` is
/// added in the Settings phase without changing this provider's API.
///
/// keepAlive: settings are app-wide and must not reset to defaults when no
/// screen happens to be listening.

abstract class _$Settings extends $Notifier<AppSettings> {
  AppSettings build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppSettings, AppSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppSettings, AppSettings>,
              AppSettings,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
