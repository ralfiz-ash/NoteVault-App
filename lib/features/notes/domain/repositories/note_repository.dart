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
  /// kept, the update date is set to now and the version goes up by one. Returns the saved note. Throws
  /// `NotFoundFailure` if the note does not exist.
  Future<Note> updateNote(Note note);

  /// Throws `NotFoundFailure` if there is no note with [id].
  Future<void> deleteNote(String id);

  /// Sync only: stores a note received from the cloud exactly as given
  /// (including its version and dates), WITHOUT recording it as a local
  /// change to upload. This is what keeps cloud -> local updates from
  /// bouncing back to the cloud.
  Future<void> applyRemoteNote(Note note);

  /// Sync only: removes a note deleted in the cloud, without recording a
  /// local change. No error if it does not exist.
  Future<void> applyRemoteDelete(String id);
}
