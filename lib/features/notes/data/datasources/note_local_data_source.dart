import '../models/note_model.dart';

/// Local persistence boundary for notes. Speaks only in [NoteModel]s; the
/// concrete implementation hides the database.
///
/// Methods let storage errors propagate; the repository converts them to
/// `Failure`s.
abstract interface class NoteLocalDataSource {
  /// Notes with their tags, newest edit first; re-emits on every change.
  Stream<List<NoteModel>> watchNotes();

  Future<List<NoteModel>> getNotes();

  /// `null` when there is no such note.
  Future<NoteModel?> getNote(String id);

  /// Throws if a note with the same id exists.
  Future<void> insertNote(NoteModel note);

  /// Returns `false` when there is no such note.
  Future<bool> updateNote(NoteModel note);

  /// Returns `false` when there is no such note.
  Future<bool> deleteNote(String id);

  /// Inserts or replaces (used to apply notes received from the cloud).
  Future<void> upsertNote(NoteModel note);
}
