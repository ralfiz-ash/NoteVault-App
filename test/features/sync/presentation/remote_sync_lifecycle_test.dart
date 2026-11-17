import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/di/connectivity_providers.dart';
import 'package:notevalult/app/di/firebase_providers.dart';
import 'package:notevalult/app/di/sync_providers.dart';
import 'package:notevalult/features/auth/domain/entities/app_user.dart';
import 'package:notevalult/features/settings/domain/entities/app_settings.dart';
import 'package:notevalult/features/settings/presentation/providers/settings_provider.dart';
import 'package:notevalult/features/sync/domain/entities/connectivity_status.dart';
import 'package:notevalult/features/sync/domain/entities/sync_entities.dart';
import 'package:notevalult/features/sync/presentation/providers/sync_providers.dart';

import '../../../helpers/fake_repositories.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  late FakeSyncRepository sync;
  late FakeAuthRepository auth;

  ProviderContainer start() {
    sync = FakeSyncRepository();
    auth = FakeAuthRepository.signedIn(testUser);
    final c = ProviderContainer(
      overrides: [
        syncRepositoryProvider.overrideWithValue(sync),
        connectivityRepositoryProvider.overrideWithValue(
          FakeConnectivityRepository()..emit(ConnectivityStatus.connected),
        ),
        authRepositoryProvider.overrideWithValue(auth),
      ],
    );
    c.listen(syncControllerProvider, (_, _) {});
    return c;
  }

  test('one cloud listener per signed-in user, closed on sign-out', () {
    fakeAsync((async) {
      final c = start();
      addTearDown(c.dispose);
      async.elapse(Duration.zero);
      expect(sync.activeListeners, ['test-user']);

      // Unrelated rebuilds do not add listeners.
      c.read(settingsProvider.notifier).setThemeMode(ThemeModePreference.dark);
      c.invalidate(settingsProvider);
      async.elapse(Duration.zero);
      expect(sync.activeListeners, ['test-user']);

      auth.emit(null); // logout
      async.elapse(Duration.zero);
      expect(sync.activeListeners, isEmpty);

      auth.emit(const AppUser(uid: 'other'));
      async.elapse(Duration.zero);
      expect(sync.activeListeners, ['other']); // new user's context only
    });
  });

  test('disposing the app closes the listener', () {
    fakeAsync((async) {
      final c = start();
      async.elapse(Duration.zero);
      expect(sync.activeListeners, hasLength(1));
      c.dispose();
      async.elapse(Duration.zero);
      expect(sync.activeListeners, isEmpty);
    });
  });

  test('conflicts from the cloud are counted for the UI', () {
    fakeAsync((async) {
      final c = start();
      addTearDown(c.dispose);
      async.elapse(Duration.zero);

      sync.emitRemote('test-user', const RemoteSyncReport(applied: 3));
      sync.emitRemote(
        'test-user',
        const RemoteSyncReport(applied: 1, conflicts: 1),
      );
      async.elapse(Duration.zero);

      expect(c.read(syncControllerProvider).conflicts, 1);
    });
  });
}
