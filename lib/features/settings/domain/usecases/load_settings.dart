import '../../../../core/usecase/usecase.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class LoadSettings implements UseCase<Future<AppSettings>, NoParams> {
  const LoadSettings(this._repository);

  final SettingsRepository _repository;

  @override
  Future<AppSettings> call(NoParams input) => _repository.loadSettings();
}
