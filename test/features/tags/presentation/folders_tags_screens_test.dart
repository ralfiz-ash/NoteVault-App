import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/app.dart';
import 'package:notevalult/app/provider_retry.dart';
import 'package:notevalult/core/presentation/tag_chip.dart';
import 'package:notevalult/features/tags/domain/entities/tag.dart';

import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late FakeNoteRepository notes;
  late FakeFolderRepository folders;
  late FakeTagRepository tags;

  Future<void> pumpApp(WidgetTester tester) async {
    notes = FakeNoteRepository()
      ..seed([
        buildNote(id: 'a', title: 'Alpha note', folderId: 'fa', tags: ['Work']),
        buildNote(id: 'b', title: 'Beta note', folderId: 'fb'),
        buildNote(id: 'c', title: 'Loose note'),
      ]);
    folders = FakeFolderRepository([
      buildFolder(id: 'fa', name: 'Alpha'),
      buildFolder(id: 'fb', name: 'Beta'),
    ]);
    tags = FakeTagRepository(const [
      Tag(id: 'tw', name: 'Work', colorValue: '#2980B9'),
      Tag(id: 'tu', name: 'Unused', colorValue: '#27AE60'),
    ]);
    await tester.pumpWidget(
      ProviderScope(
        retry: providerRetry,
        overrides: appTestOverrides(notes: notes, folders: folders, tags: tags),
        child: const NoteVaultApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> openDrawer(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
  }

  String chipColor(WidgetTester tester, String label) => tester
      .widget<TagChip>(find.widgetWithText(TagChip, label).first)
      .colorValue;

  testWidgets('tags show their colour in the notes list', (tester) async {
    await pumpApp(tester);
    expect(chipColor(tester, 'Work'), '#2980B9');
  });

  testWidgets('drawer shows folder counts and filters by folder and tag', (
    tester,
  ) async {
    await pumpApp(tester);
    await openDrawer(tester);

    final alpha = find.widgetWithText(ListTile, 'Alpha');
    expect(
      find.descendant(of: alpha, matching: find.text('1')),
      findsOneWidget,
    );
    final none = find.widgetWithText(ListTile, 'No folder');
    expect(find.descendant(of: none, matching: find.text('1')), findsOneWidget);

    await tap(tester, alpha);
    expect(find.text('Alpha note'), findsOneWidget);
    expect(find.text('Beta note'), findsNothing);

    // Folder AND tag combine: Alpha has no "Unused" note.
    await openDrawer(tester);
    await tap(tester, find.widgetWithText(ListTile, 'Unused'));
    expect(find.text('No notes found'), findsOneWidget);
    expect(find.text('No notes match the current filters.'), findsOneWidget);

    await tap(tester, find.text('Clear filters'));
    expect(find.text('Beta note'), findsOneWidget);
  });

  testWidgets('create a tag with a chosen colour', (tester) async {
    await pumpApp(tester);
    await openDrawer(tester);
    await tap(tester, find.byTooltip('Manage tags'));

    await tap(tester, find.text('New tag'));
    await tester.enterText(find.byKey(const Key('tag-name')), 'Urgent');
    await tap(tester, find.byKey(const ValueKey('tag-color-#C0392B')));
    await tap(tester, find.text('Save'));

    expect(chipColor(tester, 'Urgent'), '#C0392B');
    expect(
      (await tags.getTags()).any((t) => t.colorValue == '#C0392B'),
      isTrue,
    );
  });

  testWidgets('changing a tag colour updates it everywhere', (tester) async {
    await pumpApp(tester);
    await openDrawer(tester);
    await tap(tester, find.byTooltip('Manage tags'));

    await tap(tester, find.widgetWithText(TagChip, 'Work'));
    expect(find.text('Edit tag'), findsOneWidget);
    await tap(tester, find.byKey(const ValueKey('tag-color-#8E44AD')));
    await tap(tester, find.text('Save'));
    expect(chipColor(tester, 'Work'), '#8E44AD');

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(chipColor(tester, 'Work'), '#8E44AD'); // notes list too
  });

  testWidgets('folders: create, rename, delete (notes are kept)', (
    tester,
  ) async {
    await pumpApp(tester);
    await openDrawer(tester);
    await tap(tester, find.byTooltip('Manage folders'));

    await tap(tester, find.text('New folder'));
    await tester.enterText(find.byKey(const Key('folder-name')), 'Projects');
    await tap(tester, find.text('Save'));
    expect(find.text('Projects'), findsOneWidget);

    await tap(tester, find.text('Projects'));
    await tester.enterText(find.byKey(const Key('folder-name')), 'Archive');
    await tap(tester, find.text('Save'));
    expect(find.text('Archive'), findsOneWidget);

    final beta = find.widgetWithText(ListTile, 'Beta');
    await tap(
      tester,
      find.descendant(of: beta, matching: find.byTooltip('Folder actions')),
    );
    await tap(tester, find.text('Delete'));
    expect(find.textContaining('Its notes are kept'), findsOneWidget);
    await tap(tester, find.widgetWithText(TextButton, 'Delete'));
    expect(find.text('Beta'), findsNothing);
    expect(await notes.getNote('b'), isNotNull);
  });

  testWidgets('remove a tag from a note keeps the tag; add it back', (
    tester,
  ) async {
    await pumpApp(tester);
    await tap(tester, find.text('Alpha note'));

    await tap(tester, find.byTooltip('Remove Work'));
    expect((await notes.getNote('a')).tags, isEmpty);
    expect((await tags.getTags()).any((t) => t.name == 'Work'), isTrue);

    await tap(tester, find.byTooltip('Add tag'));
    await tap(tester, find.widgetWithText(TagChip, 'Work'));
    expect((await notes.getNote('a')).tags, ['Work']);
    expect(chipColor(tester, 'Work'), '#2980B9');
  });
}
