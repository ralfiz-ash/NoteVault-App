import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'firebase_providers.dart';

part 'session_providers.g.dart';

/// The signed-in user's id, or `null` when signed out. This is the boundary
/// for everything user-specific: providers holding a user's data `watch` it,
/// so they are rebuilt (and the previous user's state is dropped) whenever
/// the user signs out or a different user signs in.
///
/// Firebase Authentication is the only source of truth (it also restores the
/// session after an app restart); nothing is stored by the app itself.
///
/// keepAlive: it is the root of the user-scoped dependency graph and must not
/// be re-created while the app runs.
@Riverpod(keepAlive: true)
Stream<String?> currentUserId(Ref ref) => ref
    .watch(authRepositoryProvider)
    .authStateChanges()
    .map((user) => user?.uid)
    .distinct();
