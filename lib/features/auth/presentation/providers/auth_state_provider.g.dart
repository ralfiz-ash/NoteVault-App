// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The current session as `AsyncValue<AuthState>`:
/// - `AsyncLoading`: Firebase has not reported the session yet (startup)
/// - `AsyncData(Authenticated(user))` / `AsyncData(Unauthenticated())`
/// - `AsyncError(Failure)`: the auth stream failed
///
/// keepAlive: the session is app-wide state read by many screens and (later)
/// by the router and user-dependent providers. Re-subscribing every time the
/// last listener goes away would briefly show a loading state again.

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// The current session as `AsyncValue<AuthState>`:
/// - `AsyncLoading`: Firebase has not reported the session yet (startup)
/// - `AsyncData(Authenticated(user))` / `AsyncData(Unauthenticated())`
/// - `AsyncError(Failure)`: the auth stream failed
///
/// keepAlive: the session is app-wide state read by many screens and (later)
/// by the router and user-dependent providers. Re-subscribing every time the
/// last listener goes away would briefly show a loading state again.

final class AuthStateProvider
    extends
        $FunctionalProvider<AsyncValue<AuthState>, AuthState, Stream<AuthState>>
    with $FutureModifier<AuthState>, $StreamProvider<AuthState> {
  /// The current session as `AsyncValue<AuthState>`:
  /// - `AsyncLoading`: Firebase has not reported the session yet (startup)
  /// - `AsyncData(Authenticated(user))` / `AsyncData(Unauthenticated())`
  /// - `AsyncError(Failure)`: the auth stream failed
  ///
  /// keepAlive: the session is app-wide state read by many screens and (later)
  /// by the router and user-dependent providers. Re-subscribing every time the
  /// last listener goes away would briefly show a loading state again.
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<AuthState> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AuthState> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'136e05a2fa00c237a4cf7c835b77e3d643849b29';
