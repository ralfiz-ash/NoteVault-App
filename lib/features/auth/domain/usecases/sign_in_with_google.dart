import '../../../../core/usecase/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Google sign-in. Throws `CancelledFailure` if the user backs out.
class SignInWithGoogle implements UseCase<Future<AppUser>, NoParams> {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  @override
  Future<AppUser> call(NoParams input) => _repository.signInWithGoogle();
}
