import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/email_password_params.dart';
import 'auth_use_case_providers.dart';

part 'auth_controller.g.dart';

/// Runs sign-in, registration, Google sign-in and sign-out for the screens.
///
/// State: `AsyncData(null)` idle or done, `AsyncLoading` while a request runs
/// (screens disable their buttons), `AsyncError(Failure)` when it failed
/// (screens show `failure.message`; a `CancelledFailure` is not an error to
/// show). Navigation after success is not done here: the router reacts to
/// the auth state.
///
/// Passwords are passed straight through to the use case; they are never
/// kept in this provider's state.
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  Future<bool> signIn({required String email, required String password}) =>
      _run(
        () => ref.read(signInWithEmailProvider)(
          EmailPasswordParams(email: email, password: password),
        ),
      );

  Future<bool> register({required String email, required String password}) =>
      _run(
        () => ref.read(registerWithEmailProvider)(
          EmailPasswordParams(email: email, password: password),
        ),
      );

  Future<bool> signInWithGoogle() =>
      _run(() => ref.read(signInWithGoogleProvider)(const NoParams()));

  Future<bool> signOut() =>
      _run(() => ref.read(signOutProvider)(const NoParams()));

  /// Ignores a second request while one is running (no double submit).
  Future<bool> _run(Future<Object?> Function() action) async {
    if (state.isLoading) return false;
    state = const AsyncLoading();
    final result = await AsyncValue.guard<void>(action);
    if (ref.mounted) state = result;
    return !result.hasError;
  }
}
