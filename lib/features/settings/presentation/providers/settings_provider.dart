import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/core_providers.dart';
import '../../../../app/di/repository_providers.dart';
import '../../../../app/di/session_providers.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../notes/domain/entities/note_sort.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/load_settings.dart';
import '../../domain/usecases/save_settings.dart';

part 'settings_provider.g.dart';

/// The signed-in user's settings (theme mode and notes sort): a synchronous
/// `NotifierProvider` and the single source of truth for both. The app theme
/// and the notes list read it with `select`, so a theme change does not
/// refilter notes and a sort change does not rebuild the theme.
///
/// Lifecycle:
/// - signed out: the defaults, nothing stored;
/// - user signs in (or the app starts with a session): the state is the
///   defaults at once and that user's saved settings replace it as soon as
///   they are read from their own database;
/// - sign-out / another user: [build] runs again and resets to the defaults,
///   so one user's settings never show for another; a late load started for
///   the previous user is ignored (generation check).
///
/// Changes apply at once and are then saved locally (never synced, works
/// offline). Not keepAlive: the app root always watches it.
@riverpod
class Settings extends _$Settings {
  /// Bumped on every build (user change) and every local change, so a load
  /// that finishes late never overwrites newer state.
  int _generation = 0;

  @override
  AppSettings build() {
    final userId = ref.watch(
      currentUserIdProvider.select((session) => session.value),
    );
    final generation = ++_generation;
    if (userId != null) unawaited(_load(generation));
    return const AppSettings();
  }

  Future<void> _load(int generation) async {
    try {
      final saved = await LoadSettings(ref.read(settingsRepositoryProvider))(
        const NoParams(),
      );
      // Ignore if the user changed or already picked something newer.
      if (ref.mounted && generation == _generation) state = saved;
    } on Object catch (error, stackTrace) {
      // A settings problem must never break the app: keep the defaults.
      if (ref.mounted) {
        ref
            .read(appLoggerProvider)
            .warning(
              'Could not load settings; using defaults',
              error: error,
              stackTrace: stackTrace,
            );
      }
    }
  }

  /// Returns `false` if the change is shown but could not be saved (it then
  /// lasts until the app restarts).
  Future<bool> setThemeMode(ThemeModePreference mode) =>
      _update((s) => s.copyWith(themeMode: mode));

  /// The notes list order (also used by the list's sort menu).
  Future<bool> setNoteSort(NoteSort sort) =>
      _update((s) => s.copyWith(noteSort: sort));

  Future<bool> _update(AppSettings Function(AppSettings) change) async {
    final next = change(state);
    if (next == state) return true;
    _generation++;
    state = next; // visible immediately

    if (ref.read(currentUserIdProvider).value == null) return false;
    try {
      await SaveSettings(ref.read(settingsRepositoryProvider))(next);
      return true;
    } on Object catch (error, stackTrace) {
      if (ref.mounted) {
        ref
            .read(appLoggerProvider)
            .warning(
              'Could not save settings',
              error: error,
              stackTrace: stackTrace,
            );
      }
      return false;
    }
  }
}

/// The current theme preference.
@riverpod
ThemeModePreference themeModePreference(Ref ref) =>
    ref.watch(settingsProvider.select((s) => s.themeMode));

/// The current notes sort.
@riverpod
NoteSort noteSortSetting(Ref ref) =>
    ref.watch(settingsProvider.select((s) => s.noteSort));
