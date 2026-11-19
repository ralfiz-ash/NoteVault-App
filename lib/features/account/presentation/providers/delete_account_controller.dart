import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/firebase_providers.dart';
import '../../domain/entities/account_deletion_confirmation.dart';
import '../../domain/usecases/delete_account.dart';

part 'delete_account_controller.g.dart';

@riverpod
DeleteAccount deleteAccount(Ref ref) => DeleteAccount(
  auth: ref.watch(authRepositoryProvider),
  userData: ref.watch(userDataRepositoryProvider),
);

/// Runs account deletion for the "Delete account" screen.
///
/// State: `AsyncData` idle or done, `AsyncLoading` while deleting (the screen
/// disables its buttons), `AsyncError(Failure)` if it failed (a
/// `CancelledFailure` means the user closed the Google sign-in: nothing to
/// show). After success the user is signed out and the router leaves the
/// signed-in screens by itself. The password is never kept in state.
@riverpod
class DeleteAccountController extends _$DeleteAccountController {
  @override
  FutureOr<void> build() {}

  /// Returns `true` once the account has been deleted.
  Future<bool> delete(AccountDeletionConfirmation confirmation) async {
    if (state.isLoading) return false; // no double submit
    // Read before awaiting: this controller may be disposed when the user
    // is signed out at the end.
    final deleteAccount = ref.read(deleteAccountProvider);
    state = const AsyncLoading();
    final result = await AsyncValue.guard<void>(
      () => deleteAccount(confirmation),
    );
    if (ref.mounted) state = result;
    return !result.hasError;
  }
}
