import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/errors/exception_mapper.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/core/errors/guard.dart';
import 'package:notevalult/core/logging/app_logger.dart';

void main() {
  const mapper = DefaultExceptionMapper();

  group('DefaultExceptionMapper', () {
    test('returns an existing Failure unchanged', () {
      const failure = AuthFailure();
      expect(mapper.map(failure, StackTrace.empty), same(failure));
    });

    test('maps timeouts to NetworkFailure and keeps the cause', () {
      final error = TimeoutException('slow');
      final failure = mapper.map(error, StackTrace.empty);
      expect(failure, isA<NetworkFailure>());
      expect(failure.cause, error);
    });

    test('maps unknown errors to UnknownFailure', () {
      final failure = mapper.map(StateError('x'), StackTrace.empty);
      expect(failure, isA<UnknownFailure>());
      expect(failure.cause, isA<StateError>());
    });
  });

  group('guardFailures', () {
    test('returns the result on success', () async {
      expect(await guardFailures(() async => 42, mapper: mapper), 42);
    });

    test('converts thrown errors to Failure and logs them', () async {
      final entries = <LogEntry>[];
      final logger = ConsoleLogger(sink: entries.add);

      await expectLater(
        guardFailures<void>(
          () async => throw StateError('db exploded'),
          mapper: mapper,
          logger: logger,
        ),
        throwsA(isA<UnknownFailure>()),
      );
      expect(entries.single.level, LogLevel.error);
    });

    test('rethrows Failures as-is without logging', () async {
      final entries = <LogEntry>[];
      final logger = ConsoleLogger(sink: entries.add);

      await expectLater(
        guardFailures<void>(
          () async => throw const NotFoundFailure(),
          mapper: mapper,
          logger: logger,
        ),
        throwsA(isA<NotFoundFailure>()),
      );
      expect(entries, isEmpty);
    });
  });

  test('ValidationFailure carries field errors', () {
    const failure = ValidationFailure(fieldErrors: {'title': 'Required'});
    expect(failure.fieldErrors['title'], 'Required');
  });
}
