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
}
