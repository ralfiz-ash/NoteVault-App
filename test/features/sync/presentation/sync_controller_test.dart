import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/di/connectivity_providers.dart';
import 'package:notevalult/app/di/firebase_providers.dart';
import 'package:notevalult/app/di/repository_providers.dart';
import 'package:notevalult/app/di/sync_providers.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/settings/domain/entities/app_settings.dart';
import 'package:notevalult/features/settings/presentation/providers/settings_provider.dart';
import 'package:notevalult/features/sync/domain/entities/connectivity_status.dart';
import 'package:notevalult/features/sync/domain/entities/sync_entities.dart';
import 'package:notevalult/features/sync/presentation/providers/sync_providers.dart';
import 'package:notevalult/features/sync/presentation/state/sync_state.dart';

import '../../../helpers/fake_repositories.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late FakeSyncRepository sync;
  late FakeConnectivityRepository network;
  late FakeAuthRepository auth;

  ProviderContainer start({
    ConnectivityStatus initial = ConnectivityStatus.connected,
  }) {
    sync = FakeSyncRepository();
    network = FakeConnectivityRepository()..emit(initial);
    auth = FakeAuthRepository.signedIn(testUser);
    final container = ProviderContainer(
      overrides: [
        syncRepositoryProvider.overrideWithValue(sync),
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
        connectivityRepositoryProvider.overrideWithValue(network),
        authRepositoryProvider.overrideWithValue(auth),
        syncAfterChangeDelayProvider.overrideWithValue(
          const Duration(seconds: 2),
        ),
        syncRetryBaseDelayProvider.overrideWithValue(
          const Duration(seconds: 30),
        ),
      ],
    );
    container.listen(syncControllerProvider, (_, _) {});
    return container;
  }

  test('syncs once at startup when signed in and online', () {
    fakeAsync((async) {
      final c = start();
      addTearDown(c.dispose);
      async.flushMicrotasks();
      async.elapse(Duration.zero);
      expect(sync.calls, ['test-user']);
      expect(c.read(syncControllerProvider).phase, SyncPhase.synced);
    });
  });

  test('offline: no attempt; reconnect starts a sync', () {
    fakeAsync((async) {
      final c = start(initial: ConnectivityStatus.disconnected);
      addTearDown(c.dispose);
      async.elapse(const Duration(seconds: 5));
      expect(sync.calls, isEmpty);

      network.emit(ConnectivityStatus.connected);
      async.elapse(Duration.zero);
      expect(sync.calls, hasLength(1));

      // Repeated "connected" events do not start more syncs.
      network.emit(ConnectivityStatus.connected);
      async.elapse(const Duration(seconds: 5));
      expect(sync.calls, hasLength(1));
    });
  });

  test('new local changes are synced after a short delay, grouped', () {
    fakeAsync((async) {
      final c = start();
      addTearDown(c.dispose);
      async.elapse(Duration.zero);
      sync.calls.clear();

      sync.pending = const PendingChanges(pending: 1);
      async.elapse(const Duration(milliseconds: 500));
      sync.pending = const PendingChanges(pending: 2);
      async.elapse(const Duration(milliseconds: 1999));
      expect(sync.calls, isEmpty);
      async.elapse(const Duration(milliseconds: 1));
      expect(sync.calls, hasLength(1));
    });
  });

  test('failure -> failed state, backoff retry, then synced', () {
    fakeAsync((async) {
      sync = FakeSyncRepository();
      final c = start();
      addTearDown(c.dispose);
      sync.nextReport = const SyncReport(failed: 1, error: NetworkFailure());
      async.elapse(Duration.zero);
      final failed = c.read(syncControllerProvider);
      expect(failed.phase, SyncPhase.failed);
      expect(failed.errorMessage, const NetworkFailure().message);

      sync.nextReport = const SyncReport(synced: 1);
      async.elapse(const Duration(seconds: 29));
      expect(sync.calls, hasLength(1));
      async.elapse(const Duration(seconds: 1)); // first retry at 30 s
      expect(sync.calls, hasLength(2));
      expect(c.read(syncControllerProvider).phase, SyncPhase.synced);
    });
  });

  test('manual retry runs immediately', () {
    fakeAsync((async) {
      final c = start();
      addTearDown(c.dispose);
      async.elapse(Duration.zero);
      c.read(syncControllerProvider.notifier).syncNow();
      async.flushMicrotasks();
      expect(sync.calls, hasLength(2));
    });
  });

  test('unrelated state changes never trigger a sync', () {
    fakeAsync((async) {
      final c = start();
      addTearDown(c.dispose);
      async.elapse(Duration.zero);
      final before = sync.calls.length;

      for (final mode in ThemeModePreference.values) {
        c.read(settingsProvider.notifier).setThemeMode(mode);
      }
      c.invalidate(settingsProvider);
      async.elapse(const Duration(minutes: 10));
      expect(sync.calls.length, before);
    });
  });

  test('sign-out stops; signing in again syncs that user', () {
    fakeAsync((async) {
      final c = start();
      addTearDown(c.dispose);
      async.elapse(Duration.zero);
      auth.emit(null);
      async.elapse(const Duration(minutes: 1));
      expect(sync.calls, hasLength(1));

      auth.emit(testUser);
      async.elapse(Duration.zero);
      expect(sync.calls, hasLength(2));
    });
  });
}
