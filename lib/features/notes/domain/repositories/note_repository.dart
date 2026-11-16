import '../entities/note.dart';

/// Contract for notes. The implementation is local-first: reads and writes
/// hit the local database, and syncing to the cloud happens behind this
/// interface.
abstract interface class NoteRepository {
  Stream<List<Note>> watchNotes();

  Future<Note?> getNote(String id);

  Future<void> saveNote(Note note);

  Future<void> deleteNote(String id);
}
