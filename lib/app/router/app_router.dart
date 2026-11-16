import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_state_provider.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/state/auth_state.dart';
import '../../features/folders/presentation/screens/folders_screen.dart';
import '../../features/notes/presentation/screens/note_editor_screen.dart';
import '../../features/notes/presentation/screens/note_view_screen.dart';
import '../../features/notes/presentation/screens/notes_list_screen.dart';
import '../../features/tags/presentation/screens/tags_screen.dart';
import '../splash_screen.dart';
import 'app_routes.dart';
import 'auth_redirect.dart';
import 'route_error_screen.dart';

part 'app_router.g.dart';

/// The app's single [GoRouter], guarded by the auth state ([authRedirect]).
///
/// The router is created once; auth changes only re-run the redirect (via
/// [GoRouter.refreshListenable]) instead of rebuilding the router.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final auth = ValueNotifier<AsyncValue<AuthState>>(
    ref.read(authStateProvider),
  );
  ref.listen(authStateProvider, (_, next) => auth.value = next);

  final router = GoRouter(
    initialLocation: AppRoutes.home,
    refreshListenable: auth,
    redirect: (context, state) =>
        authRedirect(auth.value, state.matchedLocation),
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const NotesListScreen(),
        routes: [
          GoRoute(
            path: 'folders',
            builder: (context, state) => const FoldersScreen(),
          ),
          GoRoute(
            path: 'tags',
            builder: (context, state) => const TagsScreen(),
          ),
          // Declared before 'notes/:id' so "new" is not taken as an id.
          GoRoute(
            path: 'notes/new',
            builder: (context, state) => const NoteEditorScreen(),
          ),
          GoRoute(
            path: 'notes/:id',
            builder: (context, state) =>
                NoteViewScreen(noteId: state.pathParameters['id']!),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) =>
                    NoteEditorScreen(noteId: state.pathParameters['id']),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'register',
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            path: 'forgot-password',
            builder: (context, state) => const ForgotPasswordScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => RouteErrorScreen(location: state.uri),
  );
  ref.onDispose(() {
    router.dispose();
    auth.dispose();
  });
  return router;
}
