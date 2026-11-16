import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/app.dart';
import 'package:notevalult/app/di/core_providers.dart';
import 'package:notevalult/app/router/app_router.dart';
import 'package:notevalult/core/config/app_config.dart';
import 'package:notevalult/core/logging/app_logger.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('dependency injection', () {
    test('providers can be replaced with fakes', () {
      const fakeLogger = NoOpLogger();
      final container = createContainer(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(environment: AppEnvironment.prod),
          ),
          appLoggerProvider.overrideWithValue(fakeLogger),
        ],
      );

      expect(container.read(appConfigProvider).isProduction, isTrue);
      expect(container.read(appLoggerProvider), same(fakeLogger));
    });

    test('default logger follows the configured environment', () {
      final container = createContainer(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(environment: AppEnvironment.prod),
          ),
        ],
      );

      final logger = container.read(appLoggerProvider) as ConsoleLogger;
      expect(logger.minLevel, LogLevel.warning);
    });
  });

  group('routing', () {
    testWidgets('unknown location shows the error screen and can recover', (
      tester,
    ) async {
      final container = createContainer(overrides: appTestOverrides());
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const NoteVaultApp(),
        ),
      );
      await tester.pumpAndSettle();

      container.read(appRouterProvider).go('/does-not-exist');
      await tester.pumpAndSettle();
      expect(find.text('Page not found'), findsOneWidget);

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('No notes yet'), findsOneWidget);
    });
  });
}
