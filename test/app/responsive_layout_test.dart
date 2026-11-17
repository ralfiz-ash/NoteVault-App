import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/app.dart';
import 'package:notevalult/app/provider_retry.dart';
import 'package:notevalult/features/folders/domain/entities/folder.dart';
import 'package:notevalult/features/settings/domain/entities/app_settings.dart';
import 'package:notevalult/features/sync/domain/entities/connectivity_status.dart';
import 'package:notevalult/features/sync/domain/entities/sync_entities.dart';
import 'package:notevalult/features/tags/domain/entities/tag.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/fixtures.dart';
import '../helpers/test_helpers.dart';

/// Every main screen on a small phone (320 x 568) with large text (1.5x),
/// in light and dark: a layout overflow fails the test.
void main() {
  const longTitle =
      'A very long note title that keeps going to check wrapping and ellipsis';

  for (final theme in [ThemeModePreference.light, ThemeModePreference.dark]) {
    group('${theme.name} theme, small screen, large text', () {
      late FakeAuthRepository auth;
      late FakeConnectivityRepository network;
      late FakeSyncRepository sync;

      Future<void> pumpApp(WidgetTester tester, {bool signedIn = true}) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 1.5;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        auth = signedIn
            ? FakeAuthRepository.signedIn(testUser)
            : (FakeAuthRepository()..emit(null));
        network = FakeConnectivityRepository()
          ..emit(ConnectivityStatus.disconnected);
        sync = FakeSyncRepository()
          ..pending = const PendingChanges(pending: 12);
        final notes = FakeNoteRepository()
          ..seed([
            buildNote(
              id: 'n',
              title: longTitle,
              content: 'Content ' * 40,
              folderId: 'f',
              tags: ['Extraordinarily long tag name', 'work', 'urgent'],
            ),
          ]);
        await tester.pumpWidget(
          ProviderScope(
            retry: providerRetry,
            overrides: appTestOverrides(
              auth: auth,
              notes: notes,
              connectivity: network,
              sync: sync,
              folders: FakeFolderRepository([
                Folder(
                  id: 'f',
                  name: 'A folder with a rather long name indeed',
                  createdAt: DateTime.utc(2026),
                ),
              ]),
              tags: FakeTagRepository(const [
                Tag(id: 't1', name: 'Extraordinarily long tag name'),
                Tag(id: 't2', name: 'work', colorValue: '#2980B9'),
              ]),
              settings: FakeSettingsRepository(AppSettings(themeMode: theme)),
            ),
            child: const NoteVaultApp(),
          ),
        );
        await tester.pumpAndSettle();
      }

      Future<void> tap(WidgetTester tester, Finder f) async {
        await tester.ensureVisible(f.first);
        await tester.tap(f.first);
        await tester.pumpAndSettle();
      }

      testWidgets('auth screens', (tester) async {
        await pumpApp(tester, signedIn: false);
        expect(find.text('Welcome back'), findsOneWidget);
        await tap(tester, find.text('Create one'));
        expect(find.text('Create your account'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
        await tap(tester, find.text('Forgot password?'));
        expect(find.text('Reset your password'), findsOneWidget);
      });

      testWidgets('notes list, drawer, sort sheet', (tester) async {
        await pumpApp(tester);
        expect(find.byKey(const Key('offline-banner')), findsOneWidget);
        await tester.tap(find.byTooltip('Sort'));
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
      });

      testWidgets('note view and editor', (tester) async {
        await pumpApp(tester);
        await tap(tester, find.text(longTitle));
        await tap(tester, find.byTooltip('Edit'));
        expect(find.text('Edit note'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();
      });

      testWidgets('folders, tags and settings screens', (tester) async {
        await pumpApp(tester);
        for (final (tooltip, title) in [
          ('Manage folders', 'Folders'),
          ('Manage tags', 'Tags'),
        ]) {
          await tester.tap(find.byTooltip('Open navigation menu'));
          await tester.pumpAndSettle();
          await tap(tester, find.byTooltip(tooltip));
          expect(find.text(title), findsWidgets);
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        await tap(tester, find.text('Settings'));
        expect(find.text('Appearance'), findsOneWidget);
      });
    });
  }
}
