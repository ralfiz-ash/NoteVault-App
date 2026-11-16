/// Route paths in one place so screens never hard-code strings.
abstract final class AppRoutes {
  static const home = '/';

  /// Shown while Firebase restores the session at startup.
  static const splash = '/splash';

  static const login = '/login';
  static const register = '/login/register';
  static const forgotPassword = '/login/forgot-password';

  /// Routes a signed-out user may see.
  static bool isAuthRoute(String location) =>
      location == login || location.startsWith('$login/');
}
