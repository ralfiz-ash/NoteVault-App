import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this.local);

  final SettingsLocalDataSource local;

  @override
  Future<AppSettings> loadSettings() =>
      throw UnimplementedError('Implemented in the Settings phase.');

  @override
  Future<void> saveSettings(AppSettings settings) =>
      throw UnimplementedError('Implemented in the Settings phase.');
}
