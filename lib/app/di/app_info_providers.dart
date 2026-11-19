import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_info_providers.g.dart';

/// The installed app's version name (e.g. `1.0.0`), read from the platform
/// package metadata. The single source is `version:` in `pubspec.yaml`
/// (Android `versionName` / iOS `CFBundleShortVersionString`), so the version
/// is never written in Dart code.
///
/// keepAlive: static for the app's lifetime, read once. Tests override it.
@Riverpod(keepAlive: true)
Future<String> appVersion(Ref ref) async =>
    (await PackageInfo.fromPlatform()).version;
