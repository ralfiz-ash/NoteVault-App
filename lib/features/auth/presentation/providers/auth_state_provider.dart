import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/firebase_providers.dart';
import '../state/auth_state.dart';

part 'auth_state_provider.g.dart';

/// The current session as `AsyncValue<AuthState>`:
/// - `AsyncLoading`: Firebase has not reported the session yet (startup)
/// - `AsyncData(Authenticated(user))` / `AsyncData(Unauthenticated())`
/// - `AsyncError(Failure)`: the auth stream failed
///
/// keepAlive: the session is app-wide state read by many screens and (later)
/// by the router and user-dependent providers. Re-subscribing every time the
/// last listener goes away would briefly show a loading state again.
@Riverpod(keepAlive: true)
Stream<AuthState> authState(Ref ref) {
  return ref
      .watch(authRepositoryProvider)
      .authStateChanges()
      .map<AuthState>(
        (user) => user == null ? const Unauthenticated() : Authenticated(user),
      );
}
