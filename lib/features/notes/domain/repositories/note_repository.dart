import '../entities/note.dart';

/// Contract for notes. Storage is local-first; cloud sync (a later phase)
/// happens behind this interface without changing it.
///
/// Implementations throw `Failure` types from `core/errors` (for example
/// `NotFoundFailure`, `LocalDatabaseFailure`), never storage-specific errors.
abstract interface class NoteRepository {
  /// Emits the current notes (newest edit first) and again after every change.
  Stream<List<Note>> watchNotes();

  /// All notes, newest edit first.
  Future<List<Note>> getNotes();

  /// Throws `NotFoundFailure` if there is no note with [id].
  Future<Note> getNote(String id);

  /// Stores a new note exactly as given. Fails if the id already exists.
  Future<Note> createNote(Note note);

  /// Saves changes to an existing note. The stored creation date and id are
  /// kept and the update date is set to now. Returns the saved note. Throws
  /// `NotFoundFailure` if the note does not exist.
  Future<Note> updateNote(Note note);

  /// Throws `NotFoundFailure` if there is no note with [id].
  Future<void> deleteNote(String id);
}
