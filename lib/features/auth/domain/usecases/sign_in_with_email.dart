import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';
import '../validation/auth_validators.dart';
import 'email_password_params.dart';

/// Login with email and password.
class SignInWithEmail implements UseCase<Future<AppUser>, EmailPasswordParams> {
  const SignInWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<AppUser> call(EmailPasswordParams input) async {
    final errors = {
      'email': AuthValidators.email(input.email),
      'password': AuthValidators.loginPassword(input.password),
    }..removeWhere((_, message) => message == null);
    if (errors.isNotEmpty) {
      throw ValidationFailure(fieldErrors: errors.cast<String, String>());
    }
    return _repository.signInWithEmailAndPassword(
      email: input.email.trim(),
      password: input.password,
    );
  }
}
