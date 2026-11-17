import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/app.dart';
import 'package:notevalult/app/di/connectivity_providers.dart';
import 'package:notevalult/app/di/firebase_providers.dart';
import 'package:notevalult/app/di/repository_providers.dart';
import 'package:notevalult/app/di/sync_providers.dart';
import 'package:notevalult/app/provider_retry.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/core/theme/app_theme.dart';
import 'package:notevalult/features/folders/domain/entities/folder.dart';
import 'package:notevalult/features/folders/presentation/providers/folders_provider.dart';
import 'package:notevalult/features/notes/domain/entities/note_draft.dart';
import 'package:notevalult/features/notes/presentation/providers/create_note_controller.dart';
import 'package:notevalult/features/notes/presentation/providers/delete_note_controller.dart';
import 'package:notevalult/features/sync/domain/entities/connectivity_status.dart';
import 'package:notevalult/features/sync/presentation/providers/sync_providers.dart';
import 'package:notevalult/features/tags/domain/entities/tag.dart';
import 'package:notevalult/features/tags/presentation/providers/tags_provider.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/fixtures.dart';
import '../helpers/test_helpers.dart';

class _GatedFolders extends FakeFolderRepository {
  Completer<void>? gate;
  int creates = 0;
  int failingWatches = 0;

  @override
  Future<Folder> createFolder(Folder folder) async {
    creates++;
    await gate?.future;
    return super.createFolder(folder);
  }

  @override
  Stream<List<Folder>> watchFolders() {
    if (failingWatches > 0) {
      failingWatches--;
      return Stream.error(const LocalDatabaseFailure());
    }
    return super.watchFolders();
  }
}

class _GatedTags extends FakeTagRepository {
  Completer<void>? gate;
  int creates = 0;

  @override
  Future<Tag> createTag(Tag tag) async {
    creates++;
    await gate?.future;
    return super.createTag(tag);
  }
}

double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

double _contrast(Color a, Color b) {
  final la = _luminance(a), lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('duplicate submission protection', () {
    test('creating a note twice while saving writes once', () async {
      final notes = FakeNoteRepository();
      final c = createContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(notes),
          signedInOverride(),
        ],
      );
      c.listen(createNoteControllerProvider, (_, _) {});
      final gate = notes.gate = Completer<void>();
      final controller = c.read(createNoteControllerProvider.notifier);

      final first = controller.create(const NoteDraft(title: 'T'));
      final second = await controller.create(const NoteDraft(title: 'T'));
      gate.complete();
      await first;

      expect(second, isNull);
      expect(notes.calls.where((c) => c.startsWith('create')), hasLength(1));
    });

    test('deleting the same note twice deletes once', () async {
      final notes = FakeNoteRepository()..seed([buildNote(id: 'n')]);
      final c = createContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(notes),
          signedInOverride(),
        ],
      );
      c.listen(deleteNoteControllerProvider, (_, _) {});
      final gate = notes.gate = Completer<void>();
      final controller = c.read(deleteNoteControllerProvider.notifier);

      final first = controller.delete('n');
      expect(await controller.delete('n'), isFalse);
      gate.complete();
      expect(await first, isTrue);
      expect(notes.calls, ['delete:n']);
    });

    test('folder and tag actions ignore repeats while busy', () async {
      final folders = _GatedFolders()..gate = Completer<void>();
      final tags = _GatedTags()..gate = Completer<void>();
      final c = createContainer(
        overrides: [
          folderRepositoryProvider.overrideWithValue(folders),
          tagRepositoryProvider.overrideWithValue(tags),
          signedInOverride(),
        ],
      );
      c
        ..listen(folderActionsProvider, (_, _) {})
        ..listen(tagActionsProvider, (_, _) {});

      final f1 = c.read(folderActionsProvider.notifier).create('Work');
      expect(
        await c.read(folderActionsProvider.notifier).create('Work'),
        isNull,
      );
      final t1 = c
          .read(tagActionsProvider.notifier)
          .create(name: 'x', colorValue: '#C0392B');
      expect(
        await c
            .read(tagActionsProvider.notifier)
            .create(name: 'x', colorValue: '#C0392B'),
        isNull,
      );
      folders.gate!.complete();
      tags.gate!.complete();
      await f1;
      await t1;
      expect(folders.creates, 1);
      expect(tags.creates, 1);
    });

    test('manual sync retry while syncing runs once', () async {
      final sync = FakeSyncRepository();
      final c = createContainer(
        overrides: [
          syncRepositoryProvider.overrideWithValue(sync),
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(),
          ),
          connectivityRepositoryProvider.overrideWithValue(
            FakeConnectivityRepository()..emit(ConnectivityStatus.connected),
          ),
          authRepositoryProvider.overrideWithValue(
            FakeAuthRepository.signedIn(testUser),
          ),
        ],
      );
      c.listen(syncControllerProvider, (_, _) {});
      await pumpEventQueue(); // startup sync
      sync.calls.clear();

      final gate = sync.gate = Completer<void>();
      final controller = c.read(syncControllerProvider.notifier);
      final first = controller.syncNow();
      await controller.syncNow();
      await controller.syncNow();
      gate.complete();
      await first;
      expect(sync.calls, hasLength(1));
    });
  });

  group('screens', () {
    late FakeNoteRepository notes;
    late _GatedFolders folders;

    Future<void> pumpApp(
      WidgetTester tester, {
      int failingFolderLoads = 0,
    }) async {
      notes = FakeNoteRepository(clock: () => DateTime.utc(2026, 12))
        ..seed([buildNote(id: 'n', title: 'Groceries')]);
      folders = _GatedFolders()..failingWatches = failingFolderLoads;
      await tester.pumpWidget(
        ProviderScope(
          retry: providerRetry,
          overrides: appTestOverrides(notes: notes, folders: folders),
          child: const NoteVaultApp(),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> tap(WidgetTester tester, Finder f) async {
      await tester.ensureVisible(f);
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    testWidgets('leave dialog: Save keeps the edits and leaves', (
      tester,
    ) async {
      await pumpApp(tester);
      await tap(tester, find.text('Groceries'));
      await tap(tester, find.byTooltip('Edit'));
      await tester.enterText(find.byKey(const Key('note-title')), 'Shopping');
      await tester.pump();

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Unsaved changes'), findsOneWidget);
      await tap(tester, find.widgetWithText(FilledButton, 'Save'));

      expect(find.text('Edit note'), findsNothing);
      expect(find.text('Changes saved'), findsOneWidget);
      expect((await notes.getNote('n')).title, 'Shopping');
    });

    testWidgets('leave dialog: Save that fails keeps the user in the editor', (
      tester,
    ) async {
      await pumpApp(tester);
      await tap(tester, find.text('Groceries'));
      await tap(tester, find.byTooltip('Edit'));
      await tester.enterText(find.byKey(const Key('note-title')), 'Shopping');
      await tester.pump();
      notes.nextMutationError = const LocalDatabaseFailure();

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tap(tester, find.widgetWithText(FilledButton, 'Save'));

      expect(find.text('Edit note'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget); // input preserved
      expect(find.textContaining('Unable to update note.'), findsOneWidget);
    });

    testWidgets('creating a note confirms it', (tester) async {
      await pumpApp(tester);
      await tap(tester, find.text('New note'));
      await tester.enterText(find.byKey(const Key('note-title')), 'Fresh');
      await tap(tester, find.text('Save'));
      expect(find.text('Note created'), findsOneWidget);
    });

    testWidgets('folders: empty hint, progress while saving, success', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.text('No folders yet'), findsOneWidget);
      await tap(tester, find.byTooltip('Manage folders'));
      expect(find.textContaining('No folders yet. Tap'), findsOneWidget);

      folders.gate = Completer<void>();
      await tap(tester, find.text('New folder'));
      await tester.enterText(find.byKey(const Key('folder-name')), 'Work');
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      folders.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.text('Folder "Work" created'), findsOneWidget);
    });

    testWidgets('folders: load error with a working Retry', (tester) async {
      // The first folders load fails; Retry recovers.
      await pumpApp(tester, failingFolderLoads: 1);
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tap(tester, find.byTooltip('Manage folders'));

      expect(find.text('Unable to load folders.'), findsOneWidget);
      await tap(tester, find.text('Retry'));
      expect(find.text('Unable to load folders.'), findsNothing);
      expect(find.text('No folder'), findsOneWidget);
    });

    testWidgets('wide screens keep content at a readable width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpApp(tester);
      expect(
        tester.getSize(find.byType(Card).first).width,
        lessThanOrEqualTo(760),
      );
    });
  });

  test('light theme text actions are readable on the background', () {
    final theme = AppTheme.light;
    final fg = theme.textButtonTheme.style!.foregroundColor!.resolve({})!;
    expect(_contrast(fg, theme.colorScheme.surface), greaterThanOrEqualTo(4.5));
  });
}
