import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/di/app_info_providers.dart';
import 'package:notevalult/core/analytics/app_analytics.dart';
import 'package:notevalult/app/di/connectivity_providers.dart';
import 'package:notevalult/app/di/core_providers.dart';
import 'package:notevalult/app/di/firebase_providers.dart';
import 'package:notevalult/app/di/repository_providers.dart';
import 'package:notevalult/app/di/sync_providers.dart';
import 'package:notevalult/app/provider_retry.dart';
import 'package:notevalult/core/logging/app_logger.dart';
import 'package:notevalult/features/auth/domain/entities/app_user.dart';
import 'package:notevalult/features/folders/domain/repositories/folder_repository.dart';
import 'package:notevalult/features/notes/domain/repositories/note_repository.dart';
import 'package:notevalult/features/settings/domain/repositories/settings_repository.dart';
import 'package:notevalult/features/sync/domain/repositories/sync_repository.dart';
import 'package:notevalult/features/tags/domain/repositories/tag_repository.dart';

import 'fake_repositories.dart';

/// Creates a [ProviderContainer] that is disposed when the test ends.
/// Pass fake repositories/data sources through [overrides].
ProviderContainer createContainer({
  List<Override> overrides = const [],
  AppAnalytics? analytics,
}) {
  final container = ProviderContainer(
    overrides: [
      // No real Firebase Analytics in tests.
      appAnalyticsProvider.overrideWithValue(analytics ?? FakeAnalytics()),
      ...overrides,
    ],
    retry: providerRetry,
  );
  addTearDown(container.dispose);
  return container;
}

/// Awaits an (auto-disposed) async provider while keeping it alive, as a
/// screen watching it would. The listener stays until the test ends.
Future<T> readFuture<T>(
  ProviderContainer container,
  ProviderListenable<AsyncValue<T>> provider,
) {
  final completer = Completer<T>();
  container.listen<AsyncValue<T>>(provider, (_, next) {
    if (completer.isCompleted) return;
    switch (next) {
      case AsyncData(:final value):
        completer.complete(value);
      case AsyncError(:final error, :final stackTrace):
        completer.completeError(error, stackTrace);
      default:
    }
  }, fireImmediately: true);
  return completer.future;
}

/// A signed-in session for provider tests that need a user (for example
/// anything built on the user's notes).
Override signedInOverride([AppUser user = testUser]) =>
    authRepositoryProvider.overrideWithValue(FakeAuthRepository.signedIn(user));

const testUser = AppUser(uid: 'test-user', email: 'tester@example.com');

/// Overrides that let the whole app run in widget tests without Firebase,
/// platform plugins or the real database file.
/// The version the app reports in widget tests (no platform metadata).
const testAppVersion = '1.0.0';

List<Override> appTestOverrides({
  FakeAuthRepository? auth,
  NoteRepository? notes,
  FolderRepository? folders,
  TagRepository? tags,
  FakeConnectivityRepository? connectivity,
  SyncRepository? sync,
  SettingsRepository? settings,
  FakeAnalytics? analytics,
}) => [
  settingsRepositoryProvider.overrideWithValue(
    settings ?? FakeSettingsRepository(),
  ),
  syncRepositoryProvider.overrideWithValue(sync ?? FakeSyncRepository()),
  folderRepositoryProvider.overrideWithValue(folders ?? FakeFolderRepository()),
  tagRepositoryProvider.overrideWithValue(tags ?? FakeTagRepository()),
  appLoggerProvider.overrideWithValue(const NoOpLogger()),
  appVersionProvider.overrideWith((_) async => testAppVersion),
  appAnalyticsProvider.overrideWithValue(analytics ?? FakeAnalytics()),
  // Signed in by default, so the router shows the app, not the auth screens.
  authRepositoryProvider.overrideWithValue(
    auth ?? FakeAuthRepository.signedIn(testUser),
  ),
  noteRepositoryProvider.overrideWithValue(notes ?? FakeNoteRepository()),
  connectivityRepositoryProvider.overrideWithValue(
    connectivity ?? FakeConnectivityRepository(),
  ),
];
