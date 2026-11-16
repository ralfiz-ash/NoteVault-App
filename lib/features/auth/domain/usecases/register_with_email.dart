import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';
import '../validation/auth_validators.dart';
import 'email_password_params.dart';

/// Creates an account and signs the user in.
class RegisterWithEmail
    implements UseCase<Future<AppUser>, EmailPasswordParams> {
  const RegisterWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<AppUser> call(EmailPasswordParams input) async {
    final errors = {
      'email': AuthValidators.email(input.email),
      'password': AuthValidators.newPassword(input.password),
    }..removeWhere((_, message) => message == null);
    if (errors.isNotEmpty) {
      throw ValidationFailure(fieldErrors: errors.cast<String, String>());
    }
    return _repository.registerWithEmailAndPassword(
      email: input.email.trim(),
      password: input.password,
    );
  }
}
