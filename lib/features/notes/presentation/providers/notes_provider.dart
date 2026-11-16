import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../app/di/session_providers.dart';
import '../../domain/entities/note.dart';
import 'note_use_case_providers.dart';

part 'notes_provider.g.dart';

/// All notes from the local database (newest edit first), updated live after
/// every change. An empty list is a valid `AsyncData`, not an error.
///
/// keepAlive: this is the shared, local-first cache that `noteProvider`,
/// `folderNotesProvider` and (later) search derive from. Keeping one database
/// watch open avoids re-querying and a loading flash on every navigation.
/// To retry after an error: `ref.invalidate(notesProvider)`.
///
/// User isolation: the notes are the signed-in user's (their own database).
/// When nobody is signed in this is an empty list. That matters because
/// Riverpod keeps a provider's previous value while it reloads; going through
/// an empty list on sign-out means the previous user's notes are never what
/// a reloading screen could show to the next user.
@Riverpod(keepAlive: true)
Stream<List<Note>> notes(Ref ref) {
  final userId = ref.watch(
    currentUserIdProvider.select((session) => session.value),
  );
  if (userId == null) return Stream.value(const <Note>[]);
  return ref.watch(observeNotesProvider)(const NoParams());
}
