// Store screenshots only: runs the real NoteVault UI on in-memory demo data
// (the test fakes), without Firebase, an account or the local database.
//
//   flutter run -t tool/screenshots/main.dart [--dart-define=THEME=dark]
//
// Not part of the app build (lib/main.dart is the app entry point).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notevalult/app/app.dart';
import 'package:notevalult/app/di/app_info_providers.dart';
import 'package:notevalult/app/di/connectivity_providers.dart';
import 'package:notevalult/app/di/core_providers.dart';
import 'package:notevalult/app/di/firebase_providers.dart';
import 'package:notevalult/app/di/repository_providers.dart';
import 'package:notevalult/app/di/sync_providers.dart';
import 'package:notevalult/app/provider_retry.dart';
import 'package:notevalult/core/logging/app_logger.dart';
import 'package:notevalult/features/auth/domain/entities/app_user.dart';
import 'package:notevalult/features/auth/domain/entities/sign_in_method.dart';
import 'package:notevalult/features/folders/domain/entities/folder.dart';
import 'package:notevalult/features/notes/domain/entities/note.dart';
import 'package:notevalult/features/settings/domain/entities/app_settings.dart';
import 'package:notevalult/features/sync/domain/entities/connectivity_status.dart';
import 'package:notevalult/features/tags/domain/entities/tag.dart';

import '../../test/helpers/fake_repositories.dart';

const _theme = String.fromEnvironment('THEME', defaultValue: 'light');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsApp.debugAllowBannerOverride = false; // no DEBUG ribbon

  final now = DateTime.now().toUtc();
  DateTime ago({int days = 0, int hours = 0, int minutes = 0}) =>
      now.subtract(Duration(days: days, hours: hours, minutes: minutes));

  final folders = [
    Folder(id: 'work', name: 'Work', createdAt: ago(days: 30)),
    Folder(id: 'personal', name: 'Personal', createdAt: ago(days: 30)),
    Folder(id: 'travel', name: 'Travel', createdAt: ago(days: 20)),
    Folder(id: 'ideas', name: 'Ideas', createdAt: ago(days: 10)),
  ];
  const tags = [
    Tag(id: 't1', name: 'important', colorValue: '#C0392B'),
    Tag(id: 't2', name: 'meeting', colorValue: '#2980B9'),
    Tag(id: 't3', name: 'todo', colorValue: '#27AE60'),
    Tag(id: 't4', name: 'recipe', colorValue: '#CE8946'),
    Tag(id: 't5', name: 'reading', colorValue: '#8E44AD'),
  ];

  Note note(
    String id,
    String title,
    String content, {
    String? folderId,
    List<String> tags = const [],
    required DateTime updated,
    DateTime? created,
  }) => Note(
    id: id,
    title: title,
    content: content,
    folderId: folderId,
    tags: tags,
    createdAt: created ?? updated.subtract(const Duration(days: 2)),
    updatedAt: updated,
  );

  final notes = FakeNoteRepository()
    ..seed([
      note(
        'n1',
        'Q4 product roadmap',
        'Launch the mobile app in October. Offline mode and sync first, then '
            'sharing. Review metrics every Friday with the team.',
        folderId: 'work',
        tags: ['important', 'meeting'],
        updated: ago(minutes: 12),
      ),
      note(
        'n2',
        'Lisbon trip',
        'Flights booked for 14 May. Visit Belém, ride tram 28, try pastéis de '
            'nata at the bakery near the hotel. Pack a light jacket.',
        folderId: 'travel',
        tags: ['todo'],
        updated: ago(hours: 3),
      ),
      note(
        'n3',
        'Grocery list',
        'Eggs, spinach, parmesan, lemons, oat milk, coffee beans, olive oil '
            'and fresh basil.',
        folderId: 'personal',
        tags: ['todo'],
        updated: ago(hours: 5),
      ),
      note(
        'n4',
        'Weekly team sync',
        'Design review moved to Thursday. Ana takes the onboarding flow; Raj '
            'finishes the release checklist.',
        folderId: 'work',
        tags: ['meeting'],
        updated: ago(days: 1, hours: 2),
      ),
      note(
        'n5',
        'Pasta carbonara',
        'Spaghetti, 3 egg yolks, pecorino, guanciale and black pepper. Mix '
            'the eggs and cheese off the heat so the sauce stays silky.',
        folderId: 'personal',
        tags: ['recipe'],
        updated: ago(days: 2),
      ),
      note(
        'n6',
        'App ideas',
        'A habit tracker that works offline. Voice notes that turn into '
            'checklists. A shared shopping list for the family.',
        folderId: 'ideas',
        tags: ['important'],
        updated: ago(days: 3),
      ),
      note(
        'n7',
        'Deep Work — key ideas',
        'Schedule focus blocks. Batch shallow tasks. Embrace boredom and '
            'quit social media for a month.',
        folderId: 'ideas',
        tags: ['reading'],
        updated: ago(days: 5),
      ),
    ]);

  final connectivity = FakeConnectivityRepository()
    ..emit(ConnectivityStatus.connected);

  runApp(
    ProviderScope(
      retry: providerRetry,
      overrides: [
        appLoggerProvider.overrideWithValue(const NoOpLogger()),
        appVersionProvider.overrideWith((_) async => '1.0.0'),
        appAnalyticsProvider.overrideWithValue(FakeAnalytics()),
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository.signedIn(
            const AppUser(
              uid: 'demo',
              email: 'demo@notevault.app',
              signInMethods: {SignInMethod.emailPassword},
            ),
          ),
        ),
        noteRepositoryProvider.overrideWithValue(notes),
        folderRepositoryProvider.overrideWithValue(
          FakeFolderRepository(folders),
        ),
        tagRepositoryProvider.overrideWithValue(FakeTagRepository(tags)),
        settingsRepositoryProvider.overrideWithValue(
          FakeSettingsRepository(
            AppSettings(
              themeMode: _theme == 'dark'
                  ? ThemeModePreference.dark
                  : ThemeModePreference.light,
            ),
          ),
        ),
        syncRepositoryProvider.overrideWithValue(FakeSyncRepository()),
        connectivityRepositoryProvider.overrideWithValue(connectivity),
        userDataRepositoryProvider.overrideWithValue(FakeUserDataRepository()),
      ],
      child: const NoteVaultApp(),
    ),
  );
}
