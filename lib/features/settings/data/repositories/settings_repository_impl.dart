import '../../../../core/errors/exception_mapper.dart';
import '../../../../core/errors/guard.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';
import '../models/app_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl({
    required this.local,
    required this.exceptionMapper,
    this.logger = const NoOpLogger(),
  });

  final SettingsLocalDataSource local;
  final ExceptionMapper exceptionMapper;
  final AppLogger logger;

  /// Saved settings, or the defaults if none were saved yet.
  @override
  Future<AppSettings> loadSettings() => guardFailures(
    () async => (await local.read())?.toEntity() ?? const AppSettings(),
    mapper: exceptionMapper,
    logger: logger,
  );

  @override
  Future<void> saveSettings(AppSettings settings) => guardFailures(
    () => local.write(AppSettingsModel.fromEntity(settings)),
    mapper: exceptionMapper,
    logger: logger,
  );
}
