import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';
import '../validation/auth_validators.dart';

/// Forgot password: emails a reset link. Takes the email address.
class SendPasswordReset implements UseCase<Future<void>, String> {
  const SendPasswordReset(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(String input) async {
    final error = AuthValidators.email(input);
    if (error != null) {
      throw ValidationFailure(message: error, fieldErrors: {'email': error});
    }
    await _repository.sendPasswordResetEmail(input.trim());
  }
}
