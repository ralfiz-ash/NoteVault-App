// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_account_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deleteAccount)
final deleteAccountProvider = DeleteAccountProvider._();

final class DeleteAccountProvider
    extends $FunctionalProvider<DeleteAccount, DeleteAccount, DeleteAccount>
    with $Provider<DeleteAccount> {
  DeleteAccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteAccountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteAccountHash();

  @$internal
  @override
  $ProviderElement<DeleteAccount> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteAccount create(Ref ref) {
    return deleteAccount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteAccount value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteAccount>(value),
    );
  }
}

String _$deleteAccountHash() => r'86c6560ea823716a6c898377c2777559ce0b6bf6';

/// Runs account deletion for the "Delete account" screen.
///
/// State: `AsyncData` idle or done, `AsyncLoading` while deleting (the screen
/// disables its buttons), `AsyncError(Failure)` if it failed (a
/// `CancelledFailure` means the user closed the Google sign-in: nothing to
/// show). After success the user is signed out and the router leaves the
/// signed-in screens by itself. The password is never kept in state.

@ProviderFor(DeleteAccountController)
final deleteAccountControllerProvider = DeleteAccountControllerProvider._();

/// Runs account deletion for the "Delete account" screen.
///
/// State: `AsyncData` idle or done, `AsyncLoading` while deleting (the screen
/// disables its buttons), `AsyncError(Failure)` if it failed (a
/// `CancelledFailure` means the user closed the Google sign-in: nothing to
/// show). After success the user is signed out and the router leaves the
/// signed-in screens by itself. The password is never kept in state.
final class DeleteAccountControllerProvider
    extends $AsyncNotifierProvider<DeleteAccountController, void> {
  /// Runs account deletion for the "Delete account" screen.
  ///
  /// State: `AsyncData` idle or done, `AsyncLoading` while deleting (the screen
  /// disables its buttons), `AsyncError(Failure)` if it failed (a
  /// `CancelledFailure` means the user closed the Google sign-in: nothing to
  /// show). After success the user is signed out and the router leaves the
  /// signed-in screens by itself. The password is never kept in state.
  DeleteAccountControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteAccountControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteAccountControllerHash();

  @$internal
  @override
  DeleteAccountController create() => DeleteAccountController();
}

String _$deleteAccountControllerHash() =>
    r'09358c9720df802e8efa6125a51e9c83163ab471';

/// Runs account deletion for the "Delete account" screen.
///
/// State: `AsyncData` idle or done, `AsyncLoading` while deleting (the screen
/// disables its buttons), `AsyncError(Failure)` if it failed (a
/// `CancelledFailure` means the user closed the Google sign-in: nothing to
/// show). After success the user is signed out and the router leaves the
/// signed-in screens by itself. The password is never kept in state.

abstract class _$DeleteAccountController extends $AsyncNotifier<void> {
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
