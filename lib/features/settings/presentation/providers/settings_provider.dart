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

/// The signed-in user's settings (theme mode and notes sort): the single
/// source of truth for both. The app theme and the notes list read it with
/// `select`, so a theme change does not refilter notes and a sort change
/// does not rebuild the theme.
///
/// Lifecycle:
/// - signed out: the defaults, nothing stored;
/// - user signs in (or the app starts with a session): that user's saved
///   settings are loaded from their own database (defaults if none or if a
///   stored value is invalid);
/// - sign-out / another user: rebuilt from scratch, so one user's settings
///   never show for another.
///
/// Changes apply at once and are then saved locally (never synced, works
/// offline). Not keepAlive: the app root always watches it.
@riverpod
class Settings extends _$Settings {
  @override
  Future<AppSettings> build() async {
    final userId = ref.watch(
      currentUserIdProvider.select((session) => session.value),
    );
    if (userId == null) return const AppSettings();
    try {
      return await LoadSettings(ref.watch(settingsRepositoryProvider))(
        const NoParams(),
      );
    } on Object catch (error, stackTrace) {
      // A settings problem must never break the app: use the defaults.
      ref
          .read(appLoggerProvider)
          .warning(
            'Could not load settings; using defaults',
            error: error,
            stackTrace: stackTrace,
          );
      return const AppSettings();
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
    final current = state.value ?? const AppSettings();
    final next = change(current);
    if (next == current) return true;
    state = AsyncData(next); // visible immediately

    if (ref.read(currentUserIdProvider).value == null) return false;
    try {
      await SaveSettings(ref.read(settingsRepositoryProvider))(next);
      return true;
    } on Object catch (error, stackTrace) {
      ref
          .read(appLoggerProvider)
          .warning(
            'Could not save settings',
            error: error,
            stackTrace: stackTrace,
          );
      return false;
    }
  }
}

/// The current theme preference (defaults while loading).
@riverpod
ThemeModePreference themeModePreference(Ref ref) => ref.watch(
  settingsProvider.select(
    (s) => s.value?.themeMode ?? const AppSettings().themeMode,
  ),
);

/// The current notes sort (defaults while loading).
@riverpod
NoteSort noteSortSetting(Ref ref) => ref.watch(
  settingsProvider.select(
    (s) => s.value?.noteSort ?? const AppSettings().noteSort,
  ),
);
