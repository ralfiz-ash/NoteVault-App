// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_reset_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Forgot-password request. State: `AsyncData(false)` nothing sent yet,
/// `AsyncLoading` sending, `AsyncData(true)` sent, `AsyncError(Failure)`.

@ProviderFor(PasswordResetController)
final passwordResetControllerProvider = PasswordResetControllerProvider._();

/// Forgot-password request. State: `AsyncData(false)` nothing sent yet,
/// `AsyncLoading` sending, `AsyncData(true)` sent, `AsyncError(Failure)`.
final class PasswordResetControllerProvider
    extends $AsyncNotifierProvider<PasswordResetController, bool> {
  /// Forgot-password request. State: `AsyncData(false)` nothing sent yet,
  /// `AsyncLoading` sending, `AsyncData(true)` sent, `AsyncError(Failure)`.
  PasswordResetControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'passwordResetControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$passwordResetControllerHash();

  @$internal
  @override
  PasswordResetController create() => PasswordResetController();
}

String _$passwordResetControllerHash() =>
    r'9bf2553f99858325f15eb4b92af325b9f5c88159';

/// Forgot-password request. State: `AsyncData(false)` nothing sent yet,
/// `AsyncLoading` sending, `AsyncData(true)` sent, `AsyncError(Failure)`.

abstract class _$PasswordResetController extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
