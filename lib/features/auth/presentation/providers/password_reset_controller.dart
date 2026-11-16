import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'auth_use_case_providers.dart';

part 'password_reset_controller.g.dart';

/// Forgot-password request. State: `AsyncData(false)` nothing sent yet,
/// `AsyncLoading` sending, `AsyncData(true)` sent, `AsyncError(Failure)`.
@riverpod
class PasswordResetController extends _$PasswordResetController {
  @override
  FutureOr<bool> build() => false;

  Future<void> send(String email) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref.read(sendPasswordResetProvider)(email);
      return true;
    });
    if (ref.mounted) state = result;
  }
}
