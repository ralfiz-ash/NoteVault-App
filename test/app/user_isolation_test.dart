import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderException;
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/di/database_providers.dart';
import 'package:notevalult/app/di/firebase_providers.dart';
import 'package:notevalult/app/di/repository_providers.dart';
import 'package:notevalult/app/di/session_providers.dart';
import 'package:notevalult/core/database/app_database.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/auth/domain/entities/app_user.dart';
import 'package:notevalult/features/notes/presentation/providers/notes_provider.dart';
import 'package:notevalult/features/settings/domain/entities/app_settings.dart';
import 'package:notevalult/features/settings/presentation/providers/settings_provider.dart';

import '../helpers/fake_repositories.dart';
import '../helpers/fixtures.dart';
import '../helpers/test_helpers.dart';

/// User A's data must never be visible to user B on the same device.
void main() {
  late FakeAuthRepository auth;
  late ProviderContainer container;
  late Directory dir;

  const alice = AppUser(uid: 'alice');
  const bob = AppUser(uid: 'bob');

  setUp(() {
    auth = FakeAuthRepository();
    // One database file per user in a temp folder (like the app's
    // per-user files), so a user's data survives sign-out and sign-in.
    dir = Directory.systemTemp.createTempSync('notevault_isolation');
    addTearDown(() => dir.deleteSync(recursive: true));
    container = createContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        databaseOpenerProvider.overrideWithValue(
          (userId) =>
              AppDatabase(NativeDatabase(File('${dir.path}/$userId.sqlite'))),
        ),
      ],
    );
    container.listen(notesProvider, (_, _) {});
    container.listen(currentUserIdProvider, (_, _) {});
  });

  Future<void> signIn(AppUser? user) async {
    auth.emit(user);
    await pumpEventQueue();
  }

  test('currentUserId follows the session', () async {
    await signIn(alice);
    expect(container.read(currentUserIdProvider).value, 'alice');
    await signIn(null);
    expect(container.read(currentUserIdProvider).value, isNull);
  });

  test('signed out: no database is available', () async {
    await signIn(null);
    expect(
      () => container.read(appDatabaseProvider),
      throwsA(
        isA<ProviderException>().having(
          (e) => e.exception,
          'exception',
          isA<AuthFailure>(),
        ),
      ),
    );
  });

  test("user B never sees user A's notes; A gets them back", () async {
    await signIn(alice);
    await container
        .read(noteRepositoryProvider)
        .createNote(buildNote(id: 'a1'));
    await pumpEventQueue();
    expect(container.read(notesProvider).value!.map((n) => n.id), ['a1']);

    await signIn(null); // logout
    expect(container.read(notesProvider), isA<AsyncData<Object>>());
    expect(container.read(notesProvider).value, isEmpty);

    await signIn(bob);
    await container.read(notesProvider.future);
    expect(container.read(notesProvider).value, isEmpty);

    await signIn(null);
    await signIn(alice);
    await container.read(notesProvider.future);
    expect(container.read(notesProvider).value!.map((n) => n.id), ['a1']);
  });

  test('settings reset when the user changes', () async {
    await signIn(alice);
    container.listen(settingsProvider, (_, _) {});
    await container.read(settingsProvider.future);
    await container
        .read(settingsProvider.notifier)
        .setThemeMode(ThemeModePreference.dark);

    await signIn(null);
    expect(
      container.read(settingsProvider).value?.themeMode,
      ThemeModePreference.system,
    );
    await signIn(bob);
    expect(
      (await container.read(settingsProvider.future)).themeMode,
      ThemeModePreference.system,
    );
  });
}
