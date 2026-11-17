import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/di/database_providers.dart';
import 'package:notevalult/app/di/firebase_providers.dart';
import 'package:notevalult/app/di/repository_providers.dart';
import 'package:notevalult/app/provider_retry.dart';
import 'package:notevalult/core/database/app_database.dart';
import 'package:notevalult/features/auth/domain/entities/app_user.dart';
import 'package:notevalult/features/notes/domain/entities/note_sort.dart';
import 'package:notevalult/features/notes/presentation/providers/notes_filter_provider.dart';
import 'package:notevalult/features/settings/data/models/app_settings_model.dart';
import 'package:notevalult/features/settings/domain/entities/app_settings.dart';
import 'package:notevalult/features/settings/presentation/providers/settings_provider.dart';

import '../../../helpers/fake_repositories.dart';
import '../../../helpers/fixtures.dart';
import '../../../helpers/test_helpers.dart';

const alice = AppUser(uid: 'alice');
const bob = AppUser(uid: 'bob');

/// Settings through the real chain (notifier -> repository -> Drift) on one
/// database file per user, like the app. A new [_App] on the same folder is
/// an app restart.
class _App {
  _App(this.dir, {AppUser? user}) : auth = FakeAuthRepository() {
    if (user != null) auth.emit(user);
    container = ProviderContainer(
      retry: providerRetry,
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        databaseOpenerProvider.overrideWithValue(
          (uid) => AppDatabase(NativeDatabase(File('${dir.path}/$uid.sqlite'))),
        ),
      ],
    );
    container.listen(settingsProvider, (_, _) {});
  }

  final Directory dir;
  final FakeAuthRepository auth;
  late final ProviderContainer container;

  /// The settings once this user's saved values have been read.
  Future<AppSettings> settings() async {
    for (var i = 0; i < 3; i++) {
      await pumpEventQueue();
    }
    return container.read(settingsProvider);
  }

  Settings get notifier => container.read(settingsProvider.notifier);

  Future<void> signIn(AppUser? user) async {
    auth.emit(user);
    for (var i = 0; i < 3; i++) {
      await pumpEventQueue();
    }
  }

  void dispose() => container.dispose();
}

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('notevault_settings'));
  tearDown(() => dir.deleteSync(recursive: true));

  Future<_App> start({AppUser user = alice}) async {
    final app = _App(dir, user: user);
    addTearDown(app.dispose);
    await pumpEventQueue();
    return app;
  }

  test(
    'defaults: system theme, edited newest first, available at once',
    () async {
      final app = _App(dir, user: alice);
      addTearDown(app.dispose);
      // Synchronous: the defaults are there before anything is read.
      expect(app.container.read(settingsProvider), const AppSettings());

      final settings = await app.settings();
      expect(settings.themeMode, ThemeModePreference.system);
      expect(settings.noteSort, NoteSort.defaultSort);
    },
  );

  test('every theme mode applies at once and survives a restart', () async {
    for (final mode in ThemeModePreference.values) {
      final app = await start();
      await app.settings();
      final saved = app.notifier.setThemeMode(mode);
      expect(app.container.read(settingsProvider).themeMode, mode);
      expect(await saved, isTrue);
      app.dispose();

      final restarted = await start();
      expect((await restarted.settings()).themeMode, mode);
      restarted.dispose();
    }
  });

  test('every sort field and direction persists across a restart', () async {
    for (final field in NoteSortField.values) {
      for (final ascending in [true, false]) {
        final sort = NoteSort(field: field, ascending: ascending);
        final app = await start();
        await app.settings();
        expect(await app.notifier.setNoteSort(sort), isTrue);
        expect(app.container.read(noteSortSettingProvider), sort);
        app.dispose();

        final restarted = await start();
        expect((await restarted.settings()).noteSort, sort);
        restarted.dispose();
      }
    }
  });

  test('restart restores Dark + Title ascending together', () async {
    final app = await start();
    await app.settings();
    await app.notifier.setThemeMode(ThemeModePreference.dark);
    await app.notifier.setNoteSort(
      const NoteSort(field: NoteSortField.title, ascending: true),
    );
    app.dispose();

    final restarted = await start();
    final settings = await restarted.settings();
    expect(settings.themeMode, ThemeModePreference.dark);
    expect(
      settings.noteSort,
      const NoteSort(field: NoteSortField.title, ascending: true),
    );
  });

  test('each user has their own settings; nothing leaks on switch', () async {
    final app = await start();
    await app.settings();
    await app.notifier.setThemeMode(ThemeModePreference.dark);
    await app.notifier.setNoteSort(NoteSort.defaultSort);

    await app.signIn(null); // logout -> defaults, nothing of Alice's
    expect(app.container.read(settingsProvider), const AppSettings());

    await app.signIn(bob);
    expect(await app.settings(), const AppSettings()); // not Alice's
    await app.notifier.setThemeMode(ThemeModePreference.light);
    await app.notifier.setNoteSort(
      const NoteSort(field: NoteSortField.title, ascending: true),
    );

    await app.signIn(null);
    await app.signIn(alice);
    final restored = await app.settings();
    expect(restored.themeMode, ThemeModePreference.dark);
    expect(restored.noteSort, NoteSort.defaultSort);

    await app.signIn(null);
    await app.signIn(bob);
    expect((await app.settings()).themeMode, ThemeModePreference.light);
  });

  test('invalid stored values fall back to the defaults', () async {
    final db = AppDatabase(NativeDatabase(File('${dir.path}/alice.sqlite')));
    await db
        .into(db.preferences)
        .insert(
          PreferencesCompanion.insert(
            key: AppSettingsModel.themeModeKey,
            value: 'invalid-theme',
          ),
        );
    await db
        .into(db.preferences)
        .insert(
          PreferencesCompanion.insert(
            key: AppSettingsModel.sortFieldKey,
            value: 'unknown',
          ),
        );
    await db.close();

    final app = await start();
    expect(await app.settings(), const AppSettings());
  });

  test('changing settings never queues anything for cloud sync', () async {
    final app = await start();
    await app.settings();
    await app.notifier.setThemeMode(ThemeModePreference.dark);
    await app.notifier.setNoteSort(
      const NoteSort(field: NoteSortField.created),
    );
    final db = app.container.read(appDatabaseProvider);
    expect(await db.select(db.syncQueue).get(), isEmpty);
  });

  group('with fakes', () {
    test('a change made before the saved settings load is kept', () async {
      final repo = FakeSettingsRepository(
        const AppSettings(themeMode: ThemeModePreference.dark),
      )..loadGate = Completer<void>();
      final c = createContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
          signedInOverride(),
        ],
      );
      c.listen(settingsProvider, (_, _) {});
      await pumpEventQueue(); // signed in; the load is waiting

      expect(
        await c
            .read(settingsProvider.notifier)
            .setThemeMode(ThemeModePreference.light),
        isTrue,
      );
      repo.loadGate!.complete(); // the stored (older) "dark" arrives late
      await pumpEventQueue();

      expect(c.read(themeModePreferenceProvider), ThemeModePreference.light);
    });

    test('saved settings replace the defaults once loaded', () async {
      final repo = FakeSettingsRepository(
        const AppSettings(themeMode: ThemeModePreference.dark),
      );
      final c = createContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
          signedInOverride(),
        ],
      );
      c.listen(settingsProvider, (_, _) {});
      expect(c.read(themeModePreferenceProvider), ThemeModePreference.system);
      await pumpEventQueue();
      expect(c.read(themeModePreferenceProvider), ThemeModePreference.dark);
    });

    test('a failed save is reported, the change still applies', () async {
      final repo = FakeSettingsRepository()..failSaves = true;
      final c = createContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repo),
          signedInOverride(),
        ],
      );
      c.listen(settingsProvider, (_, _) {});
      await pumpEventQueue();

      final saved = await c
          .read(settingsProvider.notifier)
          .setThemeMode(ThemeModePreference.dark);

      expect(saved, isFalse);
      expect(c.read(themeModePreferenceProvider), ThemeModePreference.dark);
    });

    test('changing the sort re-sorts the notes list at once', () async {
      final notes = FakeNoteRepository()
        ..seed([
          buildNote(id: 'b', title: 'Banana', updatedAt: DateTime.utc(2026, 3)),
          buildNote(id: 'a', title: 'Apple', updatedAt: DateTime.utc(2026, 1)),
        ]);
      final c = createContainer(
        overrides: [
          noteRepositoryProvider.overrideWithValue(notes),
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(),
          ),
          signedInOverride(),
        ],
      );
      c.listen(filteredNotesProvider, (_, _) {});
      await pumpEventQueue();
      Future<List<String>> order() async => [
        for (final n in await readFuture(c, filteredNotesProvider)) n.id,
      ];
      expect(await order(), ['b', 'a']);

      await c
          .read(settingsProvider.notifier)
          .setNoteSort(
            const NoteSort(field: NoteSortField.title, ascending: true),
          );
      expect(await order(), ['a', 'b']);
    });
  });
}
