import 'dart:developer' as developer;

enum LogLevel {
  debug(500),
  info(800),
  warning(900),
  error(1000);

  const LogLevel(this.severity);

  /// Matches the numeric levels used by `dart:developer` / `package:logging`.
  final int severity;
}

/// One log event after redaction, handed to a [LogSink].
class LogEntry {
  const LogEntry({
    required this.level,
    required this.message,
    this.data,
    this.error,
    this.stackTrace,
  });

  final LogLevel level;
  final String message;

  /// Structured context with sensitive values already masked.
  final Map<String, Object?>? data;
  final Object? error;
  final StackTrace? stackTrace;
}

typedef LogSink = void Function(LogEntry entry);

/// Masks values whose keys look sensitive (passwords, tokens, keys, ...).
///
/// This is a safety net for structured `data`, not a licence to log secrets:
/// never put credentials or personal data in the log *message*.
abstract final class LogRedactor {
  static final RegExp _sensitiveKey = RegExp(
    r'pass(word|code)?|token|secret|api[-_]?key|authorization|credential|cookie',
    caseSensitive: false,
  );

  static const String mask = '***';

  static Map<String, Object?> redact(Map<String, Object?> data) {
    return {
      for (final entry in data.entries)
        entry.key: _sensitiveKey.hasMatch(entry.key)
            ? mask
            : _redactValue(entry.value),
    };
  }

  static Object? _redactValue(Object? value) {
    if (value is Map) {
      return redact({for (final e in value.entries) '${e.key}': e.value});
    }
    if (value is Iterable) return value.map(_redactValue).toList();
    return value;
  }
}

/// The single logging entry point for the app. Features depend on this
/// interface (obtained through Riverpod), never on `print` or `debugPrint`.
abstract class AppLogger {
  const AppLogger();

  void log(
    LogLevel level,
    String message, {
    Map<String, Object?>? data,
    Object? error,
    StackTrace? stackTrace,
  });

  void debug(String message, {Map<String, Object?>? data}) =>
      log(LogLevel.debug, message, data: data);

  void info(String message, {Map<String, Object?>? data}) =>
      log(LogLevel.info, message, data: data);

  void warning(
    String message, {
    Map<String, Object?>? data,
    Object? error,
    StackTrace? stackTrace,
  }) => log(
    LogLevel.warning,
    message,
    data: data,
    error: error,
    stackTrace: stackTrace,
  );

  void error(
    String message, {
    Map<String, Object?>? data,
    Object? error,
    StackTrace? stackTrace,
  }) => log(
    LogLevel.error,
    message,
    data: data,
    error: error,
    stackTrace: stackTrace,
  );
}

/// Filters by [minLevel], redacts `data`, then forwards to [sink]. The default
/// sink writes to `dart:developer` so output shows up in the IDE / DevTools
/// logging view. Swap the sink to forward to a crash reporter in production.
class ConsoleLogger extends AppLogger {
  ConsoleLogger({this.minLevel = LogLevel.debug, LogSink? sink})
    : _sink = sink ?? _developerSink;

  final LogLevel minLevel;
  final LogSink _sink;

  @override
  void log(
    LogLevel level,
    String message, {
    Map<String, Object?>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.severity < minLevel.severity) return;
    _sink(
      LogEntry(
        level: level,
        message: message,
        data: data == null ? null : LogRedactor.redact(data),
        error: error,
        stackTrace: stackTrace,
      ),
    );
  }

  static void _developerSink(LogEntry entry) {
    final suffix = entry.data == null || entry.data!.isEmpty
        ? ''
        : ' ${entry.data}';
    developer.log(
      '${entry.message}$suffix',
      name: 'NoteVault',
      level: entry.level.severity,
      error: entry.error,
      stackTrace: entry.stackTrace,
    );
  }
}

/// Discards everything. Useful as a default in tests.
class NoOpLogger extends AppLogger {
  const NoOpLogger();

  @override
  void log(
    LogLevel level,
    String message, {
    Map<String, Object?>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {}
}
