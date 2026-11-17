import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/note.dart';
import 'notes_provider.dart';

part 'note_provider.g.dart';

/// One note by id, e.g. for the editor: `ref.watch(noteProvider(id))`.
///
/// Derived from [notesProvider], so it updates when the note changes and
/// does not run its own query. Each id gets its own cached instance, and it
/// is auto-disposed when no screen uses that id any more.
///
/// Errors with `NotFoundFailure` if the note does not exist (or was deleted).
@riverpod
Future<Note> note(Ref ref, String id) async {
  final notes = await ref.watch(notesProvider.future);
  for (final note in notes) {
    if (note.id == id) return note;
  }
  throw NotFoundFailure(message: 'Note not found.', cause: id);
}
