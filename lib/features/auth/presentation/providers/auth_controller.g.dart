// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

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
final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, void> {
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
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'd79fc4d7778a3bdd213e2bf2a59ea93c5b37b6ca';

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

abstract class _$AuthController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
