import '../models/app_settings_model.dart';

/// Placeholder boundary for local preference storage.
abstract interface class SettingsLocalDataSource {
  Future<AppSettingsModel?> read();

  Future<void> write(AppSettingsModel settings);
}
