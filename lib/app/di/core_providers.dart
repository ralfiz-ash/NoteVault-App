import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/config/app_config.dart';
import '../../core/logging/app_logger.dart';

part 'core_providers.g.dart';

/// Composition root for shared dependencies.
///
/// Everything infrastructure-related (repositories, data sources, database,
/// Firebase) will be exposed from `lib/app/di/` as providers, so the rest of
/// the app depends on abstractions and tests can swap them with
/// `ProviderScope(overrides: [...])` or `ProviderContainer(overrides: [...])`.

/// Application configuration. Overridden in `bootstrap()` and in tests.
@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) => AppConfig.fromEnvironment();

/// App-wide logger. Overridden in `bootstrap()` and in tests.
@Riverpod(keepAlive: true)
AppLogger appLogger(Ref ref) =>
    ConsoleLogger(minLevel: ref.watch(appConfigProvider).minLogLevel);
