import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/state/auth_state.dart';
import 'app_routes.dart';

/// The single authentication guard for every route.
///
/// - Session not known yet (startup) -> splash, so the wrong screen never
///   flashes while Firebase restores the session.
/// - Signed out (or the auth stream failed) -> login (auth routes allowed).
/// - Signed in -> away from splash/auth routes to the app.
///
/// Returns the location to redirect to, or `null` to stay. Every branch
/// leaves the user on a route that the next call accepts, so there are no
/// redirect loops.
String? authRedirect(AsyncValue<AuthState> auth, String location) {
  final onSplash = location == AppRoutes.splash;
  final onAuthRoute = AppRoutes.isAuthRoute(location);

  if (!auth.hasValue && !auth.hasError) {
    return onSplash ? null : AppRoutes.splash;
  }

  final signedIn = auth.value is Authenticated && !auth.hasError;
  if (!signedIn) return onAuthRoute ? null : AppRoutes.login;
  if (onAuthRoute || onSplash) return AppRoutes.home;
  return null;
}
