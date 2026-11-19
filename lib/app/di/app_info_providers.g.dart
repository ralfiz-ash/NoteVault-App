// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_info_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The installed app's version name (e.g. `1.0.0`), read from the platform
/// package metadata. The single source is `version:` in `pubspec.yaml`
/// (Android `versionName` / iOS `CFBundleShortVersionString`), so the version
/// is never written in Dart code.
///
/// keepAlive: static for the app's lifetime, read once. Tests override it.

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// The installed app's version name (e.g. `1.0.0`), read from the platform
/// package metadata. The single source is `version:` in `pubspec.yaml`
/// (Android `versionName` / iOS `CFBundleShortVersionString`), so the version
/// is never written in Dart code.
///
/// keepAlive: static for the app's lifetime, read once. Tests override it.

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The installed app's version name (e.g. `1.0.0`), read from the platform
  /// package metadata. The single source is `version:` in `pubspec.yaml`
  /// (Android `versionName` / iOS `CFBundleShortVersionString`), so the version
  /// is never written in Dart code.
  ///
  /// keepAlive: static for the app's lifetime, read once. Tests override it.
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'59b58cc8214f60571dfe517b1f68cfc1aed29718';
