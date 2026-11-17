import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/app_config.dart';
import '../core/firebase/firebase_initializer.dart';
import '../core/logging/app_logger.dart';
import 'app.dart';
import 'di/core_providers.dart';
import 'provider_retry.dart';

/// Starts the app: builds config and logger, installs global error hooks and
/// wraps the app in the root [ProviderScope].
///
/// Firebase is initialised here, once, before any Firebase-backed provider can
/// be read. If it fails (for example a broken configuration) the error is
/// logged and the app still starts: notes are local-first and keep working;
/// only cloud features are unavailable.
Future<void> bootstrap({
  FirebaseInitializer firebaseInitializer = const DefaultFirebaseInitializer(),
}) async {
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

  try {
    await firebaseInitializer.initialize();
    logger.info('Firebase initialized');
  } catch (error, stackTrace) {
    logger.error(
      'Firebase initialization failed; cloud features are unavailable',
      error: error,
      stackTrace: stackTrace,
    );
  }

  runApp(
    ProviderScope(
      retry: providerRetry,
      overrides: [
        appConfigProvider.overrideWithValue(appConfig),
        appLoggerProvider.overrideWithValue(logger),
      ],
      child: const NoteVaultApp(),
    ),
  );
}
