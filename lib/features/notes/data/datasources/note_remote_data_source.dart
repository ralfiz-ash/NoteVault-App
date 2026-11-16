import '../models/note_model.dart';

/// Placeholder boundary for Cloud Firestore (sync target).
abstract interface class NoteRemoteDataSource {
  Stream<List<NoteModel>> watchNotes();

  Future<void> upsertNote(NoteModel note);

  Future<void> deleteNote(String id);
}
