import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/app.dart';
import 'package:notevalult/app/provider_retry.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/sync/domain/entities/connectivity_status.dart';
import 'package:notevalult/features/sync/domain/entities/sync_entities.dart';

import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late FakeSyncRepository sync;
  late FakeConnectivityRepository network;
  late FakeNoteRepository notes;

  Future<void> pumpApp(WidgetTester tester, ConnectivityStatus status) async {
    sync = FakeSyncRepository();
    network = FakeConnectivityRepository()..emit(status);
    notes = FakeNoteRepository()..seed([buildNote(title: 'Local note')]);
    await tester.pumpWidget(
      ProviderScope(
        retry: providerRetry,
        overrides: appTestOverrides(
          notes: notes,
          connectivity: network,
          sync: sync,
        ),
        child: const NoteVaultApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('offline banner; notes stay usable; gone when back online', (
    tester,
  ) async {
    await pumpApp(tester, ConnectivityStatus.disconnected);
    sync.pending = const PendingChanges(pending: 2);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('offline-banner')), findsOneWidget);
    expect(find.textContaining('2 changes will sync'), findsOneWidget);
    expect(find.text('Local note'), findsOneWidget);
    expect(find.text('New note'), findsOneWidget); // still available

    sync.pending = PendingChanges.none;
    network.emit(ConnectivityStatus.connected);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('offline-banner')), findsNothing);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('failed sync shows Retry, which asks the sync engine', (
    tester,
  ) async {
    await pumpApp(tester, ConnectivityStatus.connected);
    sync.nextReport = const SyncReport(failed: 1, error: NetworkFailure());
    sync.pending = const PendingChanges(pending: 1, failed: 1);
    await tester.pump(const Duration(seconds: 3)); // change -> sync -> fails
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sync-failed-banner')), findsOneWidget);
    expect(find.textContaining('safe on this device'), findsOneWidget);
    final before = sync.calls.length;

    sync.nextReport = const SyncReport(synced: 1);
    await tester.tap(find.text('Retry'));
    sync.pending = PendingChanges.none;
    await tester.pumpAndSettle();

    expect(sync.calls.length, before + 1);
    expect(find.byKey(const Key('sync-failed-banner')), findsNothing);
    await tester.pump(const Duration(minutes: 6)); // let any timers finish
  });

  testWidgets('pending changes indicator while online', (tester) async {
    await pumpApp(tester, ConnectivityStatus.connected);
    sync.pending = const PendingChanges(pending: 3);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    expect(find.text('3 changes waiting to sync'), findsOneWidget);
    sync.pending = PendingChanges.none;
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });

  testWidgets('a resolved conflict shows a one-off notice', (tester) async {
    await pumpApp(tester, ConnectivityStatus.connected);
    sync.emitRemote(
      testUser.uid,
      const RemoteSyncReport(applied: 1, conflicts: 1),
    );
    await tester.pump();
    await tester.pump();
    expect(
      find.textContaining('also changed on another device'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 10));
  });
}
