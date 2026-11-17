import '../entities/note.dart';
import '../entities/remote_note_change.dart';

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

  /// Writes [note] unless the cloud already has a newer revision (checked
  /// atomically, see `NoteVersioning`). Returns `null` when written, or the
  /// newer cloud note (a conflict) without writing.
  Future<Note?> upsertUnlessNewer(
    String userId,
    Note note, {
    String? folderName,
  });

  /// Deletes the cloud note unless it was edited after [deletedVersion] on
  /// another device ("edits win over deletes"). Returns `null` when deleted
  /// (or already gone), or the newer cloud note without deleting.
  Future<Note?> deleteUnlessEdited(
    String userId,
    String noteId,
    int deletedVersion,
  );

  /// Live changes to [userId]'s notes in the cloud. The first event lists
  /// every note as added (initial sync); later events only what changed.
  /// Cancel the subscription to stop listening.
  Stream<List<RemoteNoteChange>> watchChanges(String userId);
}
