import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/logging/app_logger.dart';

void main() {
  group('ConsoleLogger', () {
    test('drops entries below the minimum level', () {
      final entries = <LogEntry>[];
      final logger = ConsoleLogger(
        minLevel: LogLevel.warning,
        sink: entries.add,
      );

      logger
        ..debug('ignored')
        ..info('ignored too')
        ..warning('kept')
        ..error('kept as well');

      expect(entries.map((e) => e.message), ['kept', 'kept as well']);
    });

    test('masks sensitive keys in structured data, including nested', () {
      final entries = <LogEntry>[];
      ConsoleLogger(sink: entries.add).info(
        'sign in',
        data: {
          'email': 'a@b.c',
          'password': 'hunter2',
          'idToken': 'abc',
          'nested': {'apiKey': 'k', 'ok': 1},
          'list': [
            {'Authorization': 'Bearer x'},
          ],
        },
      );

      final data = entries.single.data!;
      expect(data['email'], 'a@b.c');
      expect(data['password'], LogRedactor.mask);
      expect(data['idToken'], LogRedactor.mask);
      expect((data['nested']! as Map)['apiKey'], LogRedactor.mask);
      expect((data['nested']! as Map)['ok'], 1);
      expect(
        ((data['list']! as List).single as Map)['Authorization'],
        LogRedactor.mask,
      );
    });

    test('forwards error and stack trace', () {
      final entries = <LogEntry>[];
      final trace = StackTrace.current;
      ConsoleLogger(sink: entries.add)
          .error('boom', error: StateError('x'), stackTrace: trace);

      expect(entries.single.level, LogLevel.error);
      expect(entries.single.error, isA<StateError>());
      expect(entries.single.stackTrace, trace);
    });
  });
}
