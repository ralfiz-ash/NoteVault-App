import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/app.dart';
import 'package:notevalult/features/auth/domain/entities/app_user.dart';
import 'package:notevalult/features/settings/domain/entities/app_settings.dart';
import 'package:notevalult/features/settings/presentation/providers/settings_provider.dart';
import 'package:notevalult/features/sync/domain/entities/connectivity_status.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/fixtures.dart';
import '../helpers/test_helpers.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeNoteRepository notes;
  late FakeConnectivityRepository connectivity;
  late ProviderContainer container;

  Future<void> pumpApp(WidgetTester tester) async {
    auth = FakeAuthRepository();
    notes = FakeNoteRepository();
    connectivity = FakeConnectivityRepository();
    container = createContainer(
      overrides: appTestOverrides(
        auth: auth,
        notes: notes,
        connectivity: connectivity,
      ),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const NoteVaultApp(),
      ),
    );
    // Let the router build the home route (which subscribes the providers).
    await tester.pumpAndSettle();
  }

  testWidgets('status reflects providers reactively (ref.watch)', (
    tester,
  ) async {
    await pumpApp(tester);
    auth.emit(null);
    connectivity.emit(ConnectivityStatus.connected);
    await tester.pumpAndSettle();

    expect(find.text('Signed out'), findsOneWidget);
    expect(find.text('No notes yet'), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);

    auth.emit(const AppUser(uid: 'u1'));
    notes.seed([buildNote(id: 'a'), buildNote(id: 'b')]);
    await tester.pumpAndSettle();

    expect(find.text('Signed in (u1)'), findsOneWidget);
    expect(find.text('2 notes'), findsOneWidget);
  });

  testWidgets('network changes show a SnackBar once (ref.listen)', (
    tester,
  ) async {
    await pumpApp(tester);
    connectivity.emit(ConnectivityStatus.connected);
    await tester.pump();
    expect(find.byType(SnackBar), findsNothing);

    connectivity.emit(ConnectivityStatus.disconnected);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('You are offline'), findsOneWidget);
  });

  testWidgets('theme follows the settings notifier', (tester) async {
    await pumpApp(tester);

    container
        .read(settingsProvider.notifier)
        .setThemeMode(ThemeModePreference.dark);
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });
}
