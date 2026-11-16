import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/app_settings.dart';

part 'settings_provider.g.dart';

/// App settings (theme mode and note sort order) and how to change them.
///
/// Held in memory for now; loading/saving through `SettingsRepository` is
/// added in the Settings phase without changing this provider's API.
///
/// keepAlive: settings are app-wide and must not reset to defaults when no
/// screen happens to be listening.
@Riverpod(keepAlive: true)
class Settings extends _$Settings {
  @override
  AppSettings build() => const AppSettings();

  void setThemeMode(ThemeModePreference mode) =>
      state = state.copyWith(themeMode: mode);

  void setSortOrder(NoteSortOrder order) =>
      state = state.copyWith(sortOrder: order);
}
