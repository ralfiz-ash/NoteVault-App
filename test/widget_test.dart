import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/app.dart';
import 'package:notevalult/app/di/core_providers.dart';
import 'package:notevalult/core/config/app_config.dart';
import 'package:notevalult/core/logging/app_logger.dart';

void main() {
  testWidgets('App starts under ProviderScope and shows the home route', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(const AppConfig()),
          appLoggerProvider.overrideWithValue(const NoOpLogger()),
        ],
        child: const NoteVaultApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('NoteVault'), findsOneWidget);
    expect(find.text('Foundation ready'), findsOneWidget);
  });
}
