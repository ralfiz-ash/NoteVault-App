import 'dart:async';

import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/di/connectivity_providers.dart';
import 'package:notevalult/app/di/core_providers.dart';
import 'package:notevalult/app/di/firebase_providers.dart';
import 'package:notevalult/app/di/repository_providers.dart';
import 'package:notevalult/app/provider_retry.dart';
import 'package:notevalult/core/logging/app_logger.dart';
import 'package:notevalult/features/notes/domain/repositories/note_repository.dart';

import 'fake_repositories.dart';

/// Creates a [ProviderContainer] that is disposed when the test ends.
/// Pass fake repositories/data sources through [overrides].
ProviderContainer createContainer({List<Override> overrides = const []}) {
  final container = ProviderContainer(
    overrides: overrides,
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

/// Overrides that let the whole app run in widget tests without Firebase,
/// platform plugins or the real database file.
List<Override> appTestOverrides({
  FakeAuthRepository? auth,
  NoteRepository? notes,
  FakeConnectivityRepository? connectivity,
}) => [
  appLoggerProvider.overrideWithValue(const NoOpLogger()),
  authRepositoryProvider.overrideWithValue(auth ?? FakeAuthRepository()),
  noteRepositoryProvider.overrideWithValue(notes ?? FakeNoteRepository()),
  connectivityRepositoryProvider.overrideWithValue(
    connectivity ?? FakeConnectivityRepository(),
  ),
];
