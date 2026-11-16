import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/app.dart';
import 'package:notevalult/app/di/core_providers.dart';
import 'package:notevalult/core/config/app_config.dart';

import 'helpers/test_helpers.dart';

void main() {
  testWidgets('App starts under ProviderScope and shows the home route', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(const AppConfig()),
          ...appTestOverrides(),
        ],
        child: const NoteVaultApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('No notes yet'), findsOneWidget);
  });
}
