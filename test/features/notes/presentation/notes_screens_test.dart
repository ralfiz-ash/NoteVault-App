import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/app.dart';
import 'package:notevalult/app/provider_retry.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/folders/domain/entities/folder.dart';
import 'package:notevalult/features/notes/domain/entities/note.dart';
import 'package:notevalult/features/tags/domain/entities/tag.dart';

import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/test_helpers.dart';

/// A repository whose list never loads (to see the loading state).
class _NeverLoadsRepository extends FakeNoteRepository {
  @override
  Stream<List<Note>> watchNotes() => const Stream.empty()
      .asBroadcastStream()
      .cast<List<Note>>()
      .asyncExpand((_) => const Stream.empty());
}

void main() {
  late FakeNoteRepository notes;
  final work = Folder(
    id: 'f-work',
    name: 'Work',
    createdAt: DateTime.utc(2026),
  );

  Future<void> pumpApp(WidgetTester tester, {FakeNoteRepository? repo}) async {
    notes = repo ?? FakeNoteRepository(clock: () => DateTime.utc(2026, 12));
    await tester.pumpWidget(
      ProviderScope(
        retry: providerRetry,
        overrides: appTestOverrides(
          notes: notes,
          folders: FakeFolderRepository([work]),
          tags: FakeTagRepository(const [Tag(id: 't1', name: 'existing')]),
        ),
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

  Finder titleField() => find.byKey(const Key('note-title'));
  Finder contentField() => find.byKey(const Key('note-content'));

  Note seeded() => buildNote(
    id: 'n1',
    title: 'Groceries',
    content: 'Milk and eggs',
    folderId: 'f-work',
    tags: ['home'],
    createdAt: DateTime.utc(2026, 1, 2, 9),
    updatedAt: DateTime.utc(2026, 1, 3, 9),
  );

  group('notes list', () {
    testWidgets('loading state', (tester) async {
      notes = _NeverLoadsRepository();
      await tester.pumpWidget(
        ProviderScope(
          retry: providerRetry,
          overrides: appTestOverrides(notes: notes),
          child: const NoteVaultApp(),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('empty state', (tester) async {
      await pumpApp(tester);
      expect(find.text('No notes yet'), findsOneWidget);
    });

    testWidgets('shows title, preview, folder, tags and date', (tester) async {
      final repo = FakeNoteRepository()..seed([seeded()]);
      await pumpApp(tester, repo: repo);

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Milk and eggs'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('home'), findsOneWidget);
      expect(find.textContaining('Edited '), findsOneWidget);
    });

    testWidgets('error state with retry', (tester) async {
      final repo = FakeNoteRepository()
        ..seed([seeded()])
        ..failingWatches = 1;
      await pumpApp(tester, repo: repo);

      expect(find.text('Unable to load notes.'), findsOneWidget);
      await tap(tester, find.text('Retry'));
      expect(find.text('Groceries'), findsOneWidget);
    });
  });

  group('create', () {
    testWidgets('validates the title', (tester) async {
      await pumpApp(tester);
      await tap(tester, find.text('New note'));

      await tap(tester, find.text('Save'));
      expect(find.text('Title is required'), findsOneWidget);
      expect(notes.calls, isEmpty);
    });

    testWidgets('saves title, content, folder and tags, then shows it', (
      tester,
    ) async {
      await pumpApp(tester);
      await tap(tester, find.text('New note'));

      await tester.enterText(titleField(), 'Plan');
      await tester.enterText(contentField(), 'Write the spec');
      await tap(tester, find.byType(DropdownButtonFormField<String?>));
      await tap(tester, find.text('Work').last);
      await tester.enterText(find.byKey(const Key('tag-input')), 'urgent');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      await tap(tester, find.text('existing')); // reuse an existing tag

      final gate = notes.gate = Completer<void>();
      await tester.tap(find.text('Save'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      gate.complete();
      await tester.pumpAndSettle();

      // Replaced by the note screen.
      expect(find.text('Plan'), findsOneWidget);
      expect(find.text('Write the spec'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('urgent'), findsOneWidget);
      expect(find.text('existing'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Plan'), findsOneWidget); // in the list at once
    });

    testWidgets('a failure keeps the editor open with a message', (
      tester,
    ) async {
      await pumpApp(tester);
      await tap(tester, find.text('New note'));
      notes.nextMutationError = const LocalDatabaseFailure();

      await tester.enterText(titleField(), 'Plan');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Unable to create note.'), findsOneWidget);
      expect(find.text('New note'), findsOneWidget);
    });
  });

  group('view and edit', () {
    Future<void> openNote(WidgetTester tester) async {
      final repo = FakeNoteRepository(clock: () => DateTime.utc(2026, 12))
        ..seed([seeded()]);
      await pumpApp(tester, repo: repo);
      await tap(tester, find.text('Groceries'));
    }

    testWidgets('view shows every field and both dates', (tester) async {
      await openNote(tester);

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Milk and eggs'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('home'), findsOneWidget);
      expect(find.textContaining('Created '), findsOneWidget);
      expect(find.textContaining('Edited '), findsOneWidget);
    });

    testWidgets('edit loads the note without marking it changed', (
      tester,
    ) async {
      await openNote(tester);
      await tap(tester, find.byTooltip('Edit'));

      expect(find.text('Edit note'), findsOneWidget);
      expect(
        tester.widget<TextFormField>(titleField()).controller!.text,
        'Groceries',
      );
      final save = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Save'),
      );
      expect(save.onPressed, isNull); // no changes yet

      // Leaving without changes: no warning.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Edit note'), findsNothing);
    });

    testWidgets('unsaved changes: Stay keeps editing, Discard leaves', (
      tester,
    ) async {
      await openNote(tester);
      await tap(tester, find.byTooltip('Edit'));
      await tester.enterText(contentField(), 'Milk, eggs and bread');
      await tester.pump();

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(
        find.text('You have unsaved changes. Do you want to discard them?'),
        findsOneWidget,
      );
      await tap(tester, find.text('Stay'));
      expect(find.text('Edit note'), findsOneWidget);
      expect(find.text('Milk, eggs and bread'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tap(tester, find.text('Discard'));
      expect(find.text('Edit note'), findsNothing);
      expect(find.text('Milk and eggs'), findsOneWidget); // unchanged
      expect(notes.calls, isEmpty);
    });

    testWidgets('save updates the note everywhere', (tester) async {
      await openNote(tester);
      await tap(tester, find.byTooltip('Edit'));
      await tester.enterText(titleField(), 'Groceries for Friday');
      await tester.pump();

      await tap(tester, find.text('Save'));

      expect(find.text('Edit note'), findsNothing);
      expect(find.text('Groceries for Friday'), findsOneWidget); // view
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Groceries for Friday'), findsOneWidget); // list
    });

    testWidgets('a failed update shows a message and keeps the edits', (
      tester,
    ) async {
      await openNote(tester);
      await tap(tester, find.byTooltip('Edit'));
      await tester.enterText(titleField(), 'Changed');
      await tester.pump();
      notes.nextMutationError = const LocalDatabaseFailure();

      await tap(tester, find.text('Save'));

      expect(find.textContaining('Unable to update note.'), findsOneWidget);
      expect(find.text('Edit note'), findsOneWidget);
    });
  });

  group('delete', () {
    Future<void> openNote(WidgetTester tester) async {
      final repo = FakeNoteRepository()..seed([seeded()]);
      await pumpApp(tester, repo: repo);
      await tap(tester, find.text('Groceries'));
    }

    testWidgets('asks first; cancel keeps the note', (tester) async {
      await openNote(tester);
      await tap(tester, find.byTooltip('Delete'));
      expect(find.text('Delete note?'), findsOneWidget);

      await tap(tester, find.text('Cancel'));
      expect(find.text('Groceries'), findsOneWidget);
      expect(notes.calls, isEmpty);
    });

    testWidgets('confirmed: back to the list and the note is gone', (
      tester,
    ) async {
      await openNote(tester);
      await tap(tester, find.byTooltip('Delete'));
      await tap(tester, find.widgetWithText(TextButton, 'Delete'));

      expect(notes.calls, ['delete:n1']);
      expect(find.text('No notes yet'), findsOneWidget);
    });

    testWidgets('failure: the note comes back with a message', (tester) async {
      await openNote(tester);
      notes.nextMutationError = const LocalDatabaseFailure();

      await tap(tester, find.byTooltip('Delete'));
      await tap(tester, find.widgetWithText(TextButton, 'Delete'));

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.textContaining('Unable to delete note.'), findsOneWidget);
    });
  });
}
