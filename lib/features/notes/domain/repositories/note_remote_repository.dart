import '../entities/note.dart';

/// Cloud copy of a user's notes. Knows nothing about Firestore.
///
/// This is the remote side only. The app keeps reading and writing notes
/// through the local-first [NoteRepository]; a later sync phase moves changes
/// between the two. Values are stored exactly as given (no timestamps are
/// changed here).
///
/// Implementations throw `Failure`s from `core/errors` (`NotFoundFailure`,
/// `NetworkFailure`, `AuthFailure`, `RemoteFailure`, ...).
abstract interface class NoteRemoteRepository {
  Stream<List<Note>> watchNotes(String userId);

  Future<List<Note>> getNotes(String userId);

  /// Throws `NotFoundFailure` if missing.
  Future<Note> getNote(String userId, String noteId);

  /// Throws `RemoteFailure` if a note with the same id already exists.
  Future<Note> createNote(String userId, Note note);

  /// Throws `NotFoundFailure` if missing.
  Future<Note> updateNote(String userId, Note note);

  /// Throws `NotFoundFailure` if missing.
  Future<void> deleteNote(String userId, String noteId);

  /// Makes the cloud copy equal to [note] (creates or replaces). Idempotent:
  /// the document id is the note id, so retries never duplicate it.
  Future<void> upsertNote(String userId, Note note);

  /// Removes the cloud copy; succeeds if it is already gone. Idempotent.
  Future<void> deleteNoteIfExists(String userId, String noteId);
}
