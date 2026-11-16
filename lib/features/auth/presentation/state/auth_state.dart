import '../../domain/entities/app_user.dart';

/// Session state for the UI. Loading and errors are expressed by the
/// surrounding `AsyncValue<AuthState>` (see `authStateProvider`).
sealed class AuthState {
  const AuthState();
}

class Authenticated extends AuthState {
  const Authenticated(this.user);

  final AppUser user;

  @override
  bool operator ==(Object other) =>
      other is Authenticated && other.user == user;

  @override
  int get hashCode => user.hashCode;
}

class Unauthenticated extends AuthState {
  const Unauthenticated();

  @override
  bool operator ==(Object other) => other is Unauthenticated;

  @override
  int get hashCode => 0;
}
