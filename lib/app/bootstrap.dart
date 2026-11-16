import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/logging/app_logger.dart';
import 'app.dart';
import 'di/core_providers.dart';

/// Starts the app: builds config and logger, installs global error hooks and
/// wraps the app in the root [ProviderScope].
///
/// Future async initialisation (Firebase, local database) happens here, before
/// `runApp`, and is handed to the scope as overrides.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appConfig = AppConfig.fromEnvironment();
  final logger = ConsoleLogger(minLevel: appConfig.minLogLevel);

  FlutterError.onError = (details) {
    logger.error(
      'Flutter framework error',
      error: details.exception,
      stackTrace: details.stack,
    );
    if (!appConfig.isProduction) FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    logger.error('Uncaught error', error: error, stackTrace: stackTrace);
    return true;
  };

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(appConfig),
        appLoggerProvider.overrideWithValue(logger),
      ],
      child: const NoteVaultApp(),
    ),
  );
}
