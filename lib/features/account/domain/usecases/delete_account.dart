import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../entities/account_deletion_confirmation.dart';
import '../repositories/user_data_repository.dart';

/// Permanently deletes the signed-in user's account and all their data, in
/// the cloud and on this device.
///
/// Order matters:
/// 1. confirm the user's identity (also fails fast when offline);
/// 2. stop pending uploads, so deleted notes are not uploaded again;
/// 3. delete the cloud data (while still allowed to: the security rules
///    require the signed-in owner);
/// 4. delete the data on this device;
/// 5. delete the account, which signs the user out.
///
/// If a step fails, the later steps do not run and the account still exists,
/// so the user can simply try again.
class DeleteAccount
    implements UseCase<Future<void>, AccountDeletionConfirmation> {
  const DeleteAccount({required this.auth, required this.userData});

  final AuthRepository auth;
  final UserDataRepository userData;

  @override
  Future<void> call(AccountDeletionConfirmation confirmation) async {
    final user = auth.currentUser;
    if (user == null) {
      throw const AuthFailure(message: 'You are not signed in.');
    }

    switch (confirmation) {
      case ConfirmWithPassword(:final password):
        if (password.isEmpty) {
          throw const ValidationFailure(
            message: 'Please enter your password.',
            fieldErrors: {'password': 'Password is required.'},
          );
        }
        await auth.reauthenticateWithPassword(password);
      case ConfirmWithGoogle():
        await auth.reauthenticateWithGoogle();
    }

    await userData.discardPendingSync();
    await userData.deleteCloudData(user.uid);
    await userData.deleteLocalData();
    await auth.deleteCurrentUser();
  }
}
