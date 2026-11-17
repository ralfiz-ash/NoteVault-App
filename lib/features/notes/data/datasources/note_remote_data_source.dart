import '../../domain/entities/remote_note_change.dart';
import '../models/note_model.dart';

/// Boundary to the remote note store (Cloud Firestore). Notes are owned by a
/// user, so every call takes the owner's [userId].
///
/// Values are stored exactly as given (the local database decides
/// timestamps). Not yet connected to the local database: syncing is a later
/// phase. SDK errors propagate to the repository, which maps them.
abstract interface class NoteRemoteDataSource {
  Stream<List<NoteModel>> watchNotes(String userId);

  Future<List<NoteModel>> getNotes(String userId);

  /// `null` when there is no such note.
  Future<NoteModel?> getNote(String userId, String noteId);

  /// Returns `false` (and writes nothing) if a note with this id exists.
  Future<bool> createNote(String userId, NoteModel note);

  /// Returns `false` when there is no such note.
  Future<bool> updateNote(String userId, NoteModel note);

  /// Returns `false` when there is no such note.
  Future<bool> deleteNote(String userId, String noteId);

  /// Writes [note] as it is (creates or replaces). Idempotent: repeating it
  /// leaves exactly one document, named by the note id. Used by sync.
  Future<void> upsertNote(String userId, NoteModel note);

  /// Deletes the note if it exists; succeeds if it is already gone.
  /// Idempotent. Used by sync.
  Future<void> deleteNoteIfExists(String userId, String noteId);

  /// Transaction: reads the cloud note, asks [shouldWrite] (given the cloud
  /// copy, or null if absent) and writes [note] only if it agrees. Returns
  /// the cloud copy that blocked the write, or `null` if written.
  Future<NoteModel?> upsertIf(
    String userId,
    NoteModel note, {
    String? folderName,
    required bool Function(NoteModel? cloud) shouldWrite,
  });

  /// Transaction: deletes unless [keep] returns true for the cloud copy.
  /// Returns the kept cloud copy, or `null` if deleted / already gone.
  Future<NoteModel?> deleteUnless(
    String userId,
    String noteId, {
    required bool Function(NoteModel cloud) keep,
  });

  /// Live document changes (added / modified / removed) with folder names.
  Stream<List<RemoteModelChange>> watchChanges(String userId);
}

class RemoteModelChange {
  const RemoteModelChange(this.type, this.noteId, this.model, this.folderName);

  final RemoteChangeType type;
  final String noteId;
  final NoteModel? model;
  final String? folderName;
}
