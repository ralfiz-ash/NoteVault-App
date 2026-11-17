import '../entities/app_settings.dart';

/// The signed-in user's settings, stored on this device only (not synced).
/// Implementations throw `Failure`s from `core/errors`.
abstract interface class SettingsRepository {
  /// Saved settings, or the defaults when nothing was saved yet. Invalid
  /// stored values come back as their defaults.
  Future<AppSettings> loadSettings();

  Future<void> saveSettings(AppSettings settings);
}
