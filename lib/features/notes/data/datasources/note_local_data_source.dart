import '../models/note_model.dart';

/// Placeholder boundary for the local database (source of truth).
abstract interface class NoteLocalDataSource {
  Stream<List<NoteModel>> watchNotes();

  Future<NoteModel?> getNote(String id);

  Future<void> upsertNote(NoteModel note);

  Future<void> deleteNote(String id);
}
