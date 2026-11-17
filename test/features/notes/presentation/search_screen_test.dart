import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/app.dart';
import 'package:notevalult/app/provider_retry.dart';

import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, FakeNoteRepository notes) async {
    await tester.pumpWidget(
      ProviderScope(
        retry: providerRetry,
        overrides: appTestOverrides(notes: notes),
        child: const NoteVaultApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  FakeNoteRepository seeded() => FakeNoteRepository()
    ..seed([
      buildNote(
        id: 'a',
        title: 'Banana bread',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 3),
      ),
      buildNote(
        id: 'b',
        title: 'Apple pie',
        content: 'Uses FLUTTER sugar',
        createdAt: DateTime.utc(2026, 1, 2),
        updatedAt: DateTime.utc(2026, 1, 2),
      ),
    ]);

  Finder search() => find.byKey(const Key('notes-search'));

  double top(WidgetTester tester, String text) =>
      tester.getTopLeft(find.text(text)).dy;

  testWidgets('search is debounced, then filters title/content', (
    tester,
  ) async {
    await pumpApp(tester, seeded());

    await tester.enterText(search(), 'flutter');
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Banana bread'), findsOneWidget); // not applied yet

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(find.text('Banana bread'), findsNothing);
    expect(find.text('Apple pie'), findsOneWidget); // matched by content
  });

  testWidgets('no-match message, then clear restores the list', (tester) async {
    await pumpApp(tester, seeded());

    await tester.enterText(search(), 'kotlin');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('No notes found'), findsOneWidget);
    expect(find.text('No notes match "kotlin".'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();
    expect(find.text('Banana bread'), findsOneWidget);
    expect(find.text('Apple pie'), findsOneWidget);
  });

  testWidgets('no notes at all is not a "no match"', (tester) async {
    await pumpApp(tester, FakeNoteRepository());
    await tester.enterText(search(), 'x');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('No notes yet'), findsOneWidget);
  });

  testWidgets('sort sheet changes the order', (tester) async {
    await pumpApp(tester, seeded());
    // Default: recently edited first.
    expect(top(tester, 'Banana bread'), lessThan(top(tester, 'Apple pie')));

    await tester.tap(find.byTooltip('Sort'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Title'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A to Z'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10)); // close the sheet
    await tester.pumpAndSettle();

    expect(top(tester, 'Apple pie'), lessThan(top(tester, 'Banana bread')));
  });
}
