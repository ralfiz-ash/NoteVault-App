import '../models/app_settings_model.dart';

/// Local preference storage for the signed-in user.
abstract interface class SettingsLocalDataSource {
  /// `null` when this user has never saved settings.
  Future<AppSettingsModel?> read();

  Future<void> write(AppSettingsModel settings);
}
