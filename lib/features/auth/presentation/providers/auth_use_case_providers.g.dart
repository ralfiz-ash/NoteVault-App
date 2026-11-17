// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_use_case_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Authentication use cases, built on the injected [AuthRepository]. They are
/// stateless, so they are simply auto-disposed when unused.

@ProviderFor(signInWithEmail)
final signInWithEmailProvider = SignInWithEmailProvider._();

/// Authentication use cases, built on the injected [AuthRepository]. They are
/// stateless, so they are simply auto-disposed when unused.

final class SignInWithEmailProvider
    extends
        $FunctionalProvider<SignInWithEmail, SignInWithEmail, SignInWithEmail>
    with $Provider<SignInWithEmail> {
  /// Authentication use cases, built on the injected [AuthRepository]. They are
  /// stateless, so they are simply auto-disposed when unused.
  SignInWithEmailProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInWithEmailProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInWithEmailHash();

  @$internal
  @override
  $ProviderElement<SignInWithEmail> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignInWithEmail create(Ref ref) {
    return signInWithEmail(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignInWithEmail value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignInWithEmail>(value),
    );
  }
}

String _$signInWithEmailHash() => r'4ce4afb4f843f8e3e1d0e2a7c64345b0a845bd76';

@ProviderFor(registerWithEmail)
final registerWithEmailProvider = RegisterWithEmailProvider._();

final class RegisterWithEmailProvider
    extends
        $FunctionalProvider<
          RegisterWithEmail,
          RegisterWithEmail,
          RegisterWithEmail
        >
    with $Provider<RegisterWithEmail> {
  RegisterWithEmailProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'registerWithEmailProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$registerWithEmailHash();

  @$internal
  @override
  $ProviderElement<RegisterWithEmail> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RegisterWithEmail create(Ref ref) {
    return registerWithEmail(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RegisterWithEmail value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RegisterWithEmail>(value),
    );
  }
}

String _$registerWithEmailHash() => r'3ce8f1844987d6fccdf0ea762bb8996a7bf5c866';

@ProviderFor(signInWithGoogle)
final signInWithGoogleProvider = SignInWithGoogleProvider._();

final class SignInWithGoogleProvider
    extends
        $FunctionalProvider<
          SignInWithGoogle,
          SignInWithGoogle,
          SignInWithGoogle
        >
    with $Provider<SignInWithGoogle> {
  SignInWithGoogleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInWithGoogleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInWithGoogleHash();

  @$internal
  @override
  $ProviderElement<SignInWithGoogle> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignInWithGoogle create(Ref ref) {
    return signInWithGoogle(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignInWithGoogle value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignInWithGoogle>(value),
    );
  }
}

String _$signInWithGoogleHash() => r'449e7ae94b09d4294147d50db06f723d357561b9';

@ProviderFor(sendPasswordReset)
final sendPasswordResetProvider = SendPasswordResetProvider._();

final class SendPasswordResetProvider
    extends
        $FunctionalProvider<
          SendPasswordReset,
          SendPasswordReset,
          SendPasswordReset
        >
    with $Provider<SendPasswordReset> {
  SendPasswordResetProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sendPasswordResetProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sendPasswordResetHash();

  @$internal
  @override
  $ProviderElement<SendPasswordReset> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SendPasswordReset create(Ref ref) {
    return sendPasswordReset(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SendPasswordReset value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SendPasswordReset>(value),
    );
  }
}

String _$sendPasswordResetHash() => r'4e6395ac82738ca54e5e7fd9c8ee64d8577175bc';

@ProviderFor(signOut)
final signOutProvider = SignOutProvider._();

final class SignOutProvider
    extends $FunctionalProvider<SignOut, SignOut, SignOut>
    with $Provider<SignOut> {
  SignOutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signOutProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signOutHash();

  @$internal
  @override
  $ProviderElement<SignOut> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SignOut create(Ref ref) {
    return signOut(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignOut value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignOut>(value),
    );
  }
}

String _$signOutHash() => r'bef58c5e48a93d3444f1f1815f4d5983b58dbaee';
