import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';

import '../analytics/app_analytics.dart';
import '../logging/app_logger.dart';

/// [AppAnalytics] backed by Firebase Analytics (`FirebaseAnalytics.instance`).
///
/// Every call is wrapped: if Analytics is unavailable (Firebase failed to
/// start, the platform channel errors, ...) the problem is only logged.
/// Firebase queues events offline and uploads them later by itself.
class FirebaseAppAnalytics implements AppAnalytics {
  FirebaseAppAnalytics(this._logger, {FirebaseAnalytics Function()? analytics})
    : _analytics = analytics ?? (() => FirebaseAnalytics.instance);

  /// Name of the custom event for a successfully saved note.
  static const noteSavedEvent = 'note_saved';

  final AppLogger _logger;
  final FirebaseAnalytics Function() _analytics;

  @override
  void logLogin(LoginMethod method) =>
      _send(() => _analytics().logLogin(loginMethod: method.name));

  @override
  void logNoteSaved() =>
      _send(() => _analytics().logEvent(name: noteSavedEvent));

  void _send(Future<void> Function() event) {
    try {
      unawaited(event().catchError(_failed));
    } on Object catch (error, stackTrace) {
      _failed(error, stackTrace);
    }
  }

  void _failed(Object error, [StackTrace? stackTrace]) => _logger.warning(
    'Analytics event not sent',
    error: error,
    stackTrace: stackTrace,
  );
}
