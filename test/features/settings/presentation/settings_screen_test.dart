import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/app.dart';
import 'package:notevalult/app/provider_retry.dart';
import 'package:notevalult/features/notes/domain/entities/note_sort.dart';
import 'package:notevalult/features/settings/domain/entities/app_settings.dart';

import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late FakeSettingsRepository settings;

  Future<void> pumpApp(WidgetTester tester, {AppSettings? stored}) async {
    settings = FakeSettingsRepository(stored);
    final notes = FakeNoteRepository()
      ..seed([
        buildNote(id: 'b', title: 'Banana', updatedAt: DateTime.utc(2026, 3)),
        buildNote(id: 'a', title: 'Apple', updatedAt: DateTime.utc(2026, 1)),
      ]);
    await tester.pumpWidget(
      ProviderScope(
        retry: providerRetry,
        overrides: appTestOverrides(notes: notes, settings: settings),
        child: const NoteVaultApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openSettings(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
  }

  ThemeMode appThemeMode(WidgetTester tester) =>
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;

  double top(WidgetTester tester, String text) =>
      tester.getTopLeft(find.text(text)).dy;

  testWidgets('saved settings are applied at start', (tester) async {
    await pumpApp(
      tester,
      stored: const AppSettings(
        themeMode: ThemeModePreference.dark,
        noteSort: NoteSort(field: NoteSortField.title, ascending: true),
      ),
    );
    expect(appThemeMode(tester), ThemeMode.dark);
    expect(top(tester, 'Apple'), lessThan(top(tester, 'Banana')));
  });

  testWidgets('theme changes apply immediately and are saved', (tester) async {
    await pumpApp(tester);
    await openSettings(tester);
    expect(appThemeMode(tester), ThemeMode.system);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(appThemeMode(tester), ThemeMode.dark);
    expect(settings.stored?.themeMode, ThemeModePreference.dark);

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(appThemeMode(tester), ThemeMode.light);

    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();
    expect(appThemeMode(tester), ThemeMode.system);
    expect(settings.saves, 3);
  });

  testWidgets('sort chosen in Settings reorders the notes list', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(top(tester, 'Banana'), lessThan(top(tester, 'Apple')));

    await openSettings(tester);
    await tester.tap(find.text('Title'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A to Z'));
    await tester.pumpAndSettle();
    expect(
      settings.stored?.noteSort,
      const NoteSort(field: NoteSortField.title, ascending: true),
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(top(tester, 'Apple'), lessThan(top(tester, 'Banana')));
  });

  testWidgets('a save failure is reported but the theme still changes', (
    tester,
  ) async {
    await pumpApp(tester);
    settings.failSaves = true;
    await openSettings(tester);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(appThemeMode(tester), ThemeMode.dark);
    expect(find.textContaining('Could not save this setting'), findsOneWidget);
  });
}
