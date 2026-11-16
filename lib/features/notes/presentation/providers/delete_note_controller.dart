import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'note_use_case_providers.dart';
import 'pending_note_deletions_provider.dart';

part 'delete_note_controller.g.dart';

/// Deletes notes optimistically.
///
/// 1. The note is hidden from the list immediately ([PendingNoteDeletions]).
/// 2. The delete runs.
/// 3. Success: the database no longer has it, so it stays gone.
///    Failure: it is shown again (rollback) and the state becomes
///    `AsyncError(Failure)` so the list can say "Unable to delete note".
///
/// The notes list listens to this provider, so a delete started from the
/// note screen keeps running (and reports errors) after that screen closes.
@riverpod
class DeleteNoteController extends _$DeleteNoteController {
  @override
  FutureOr<String?> build() => null;

  /// Returns `true` if the note was deleted.
  Future<bool> delete(String noteId) async {
    final pending = ref.read(pendingNoteDeletionsProvider.notifier)
      ..add(noteId);
    final deleteNote = ref.read(deleteNoteProvider);
    state = const AsyncLoading();

    final result = await AsyncValue.guard<String?>(() async {
      await deleteNote(noteId);
      return noteId;
    });
    // Success or failure, the note is no longer "being deleted": either the
    // database removed it, or it comes back (rollback).
    pending.remove(noteId);
    if (ref.mounted) state = result;
    return !result.hasError;
  }
}
