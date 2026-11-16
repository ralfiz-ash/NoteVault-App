import '../../../../core/usecase/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class ObserveAuthState implements UseCase<Stream<AppUser?>, NoParams> {
  const ObserveAuthState(this._repository);

  final AuthRepository _repository;

  @override
  Stream<AppUser?> call(NoParams input) => _repository.authStateChanges();
}
