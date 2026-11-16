import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/app/router/app_routes.dart';
import 'package:notevalult/app/router/auth_redirect.dart';
import 'package:notevalult/core/errors/failure.dart';
import 'package:notevalult/features/auth/domain/entities/app_user.dart';
import 'package:notevalult/features/auth/presentation/state/auth_state.dart';

void main() {
  const loading = AsyncLoading<AuthState>();
  const signedOut = AsyncData<AuthState>(Unauthenticated());
  const signedIn = AsyncData<AuthState>(Authenticated(AppUser(uid: 'u')));
  final failed = AsyncError<AuthState>(
    const NetworkFailure(),
    StackTrace.empty,
  );

  test('while restoring the session everything goes to splash', () {
    expect(authRedirect(loading, AppRoutes.home), AppRoutes.splash);
    expect(authRedirect(loading, AppRoutes.login), AppRoutes.splash);
    expect(authRedirect(loading, AppRoutes.splash), isNull);
  });

  test('signed out: app routes go to login, auth routes are allowed', () {
    expect(authRedirect(signedOut, AppRoutes.home), AppRoutes.login);
    expect(authRedirect(signedOut, AppRoutes.splash), AppRoutes.login);
    expect(authRedirect(signedOut, AppRoutes.login), isNull);
    expect(authRedirect(signedOut, AppRoutes.register), isNull);
    expect(authRedirect(signedOut, AppRoutes.forgotPassword), isNull);
  });

  test('signed in: auth routes and splash go to the app', () {
    expect(authRedirect(signedIn, AppRoutes.login), AppRoutes.home);
    expect(authRedirect(signedIn, AppRoutes.register), AppRoutes.home);
    expect(authRedirect(signedIn, AppRoutes.splash), AppRoutes.home);
    expect(authRedirect(signedIn, AppRoutes.home), isNull);
  });

  test('an auth error is treated as signed out', () {
    expect(authRedirect(failed, AppRoutes.home), AppRoutes.login);
  });

  test('no loops: every redirect target is accepted as-is', () {
    for (final auth in [loading, signedOut, signedIn, failed]) {
      for (final location in [
        AppRoutes.home,
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
      ]) {
        final target = authRedirect(auth, location);
        if (target != null) expect(authRedirect(auth, target), isNull);
      }
    }
  });
}
