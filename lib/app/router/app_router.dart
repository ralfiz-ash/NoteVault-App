import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../placeholder_home_screen.dart';
import 'app_routes.dart';
import 'route_error_screen.dart';

part 'app_router.g.dart';

/// The app's single [GoRouter].
///
/// Only the routing foundation exists for now. Feature routes (auth, notes,
/// settings, ...) are added here in their own phases, and auth-based
/// redirects will watch the auth state provider once it exists.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const PlaceholderHomeScreen(),
      ),
    ],
    errorBuilder: (context, state) => RouteErrorScreen(location: state.uri),
  );
  ref.onDispose(router.dispose);
  return router;
}
