import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note_model.dart';
import 'note_firestore_mapper.dart';
import 'note_remote_data_source.dart';

/// [NoteRemoteDataSource] backed by Cloud Firestore.
class FirestoreNoteRemoteDataSource implements NoteRemoteDataSource {
  FirestoreNoteRemoteDataSource({
    required FirebaseFirestore firestore,
    this.writeTimeout = const Duration(seconds: 20),
  }) : _db = firestore;

  final FirebaseFirestore _db;

  /// Sync writes give up after this (and are retried later) instead of
  /// waiting forever on a poor connection.
  final Duration writeTimeout;

  CollectionReference<Map<String, Object?>> _notes(String userId) => _db
      .collection(NoteFirestoreMapper.usersCollection)
      .doc(userId)
      .collection(NoteFirestoreMapper.notesCollection);

  Query<Map<String, Object?>> _ordered(String userId) =>
      _notes(userId).orderBy('updatedAt', descending: true);

  List<NoteModel> _toModels(QuerySnapshot<Map<String, Object?>> snapshot) => [
    for (final doc in snapshot.docs)
      NoteFirestoreMapper.fromDocument(doc.id, doc.data()),
  ];

  @override
  Stream<List<NoteModel>> watchNotes(String userId) =>
      _ordered(userId).snapshots().map(_toModels);

  @override
  Future<List<NoteModel>> getNotes(String userId) async =>
      _toModels(await _ordered(userId).get());

  @override
  Future<NoteModel?> getNote(String userId, String noteId) async {
    final doc = await _notes(userId).doc(noteId).get();
    final data = doc.data();
    return data == null ? null : NoteFirestoreMapper.fromDocument(doc.id, data);
  }

  @override
  Future<bool> createNote(String userId, NoteModel note) {
    final ref = _notes(userId).doc(note.id);
    return _db.runTransaction((tx) async {
      if ((await tx.get(ref)).exists) return false;
      tx.set(ref, NoteFirestoreMapper.toDocument(note));
      return true;
    });
  }

  @override
  Future<bool> updateNote(String userId, NoteModel note) {
    final ref = _notes(userId).doc(note.id);
    return _db.runTransaction((tx) async {
      if (!(await tx.get(ref)).exists) return false;
      tx.set(ref, NoteFirestoreMapper.toDocument(note));
      return true;
    });
  }

  @override
  Future<bool> deleteNote(String userId, String noteId) {
    final ref = _notes(userId).doc(noteId);
    return _db.runTransaction((tx) async {
      if (!(await tx.get(ref)).exists) return false;
      tx.delete(ref);
      return true;
    });
  }

  @override
  Future<void> upsertNote(String userId, NoteModel note) =>
      _notes(userId)
          .doc(note.id)
          .set(NoteFirestoreMapper.toDocument(note))
          .timeout(writeTimeout);

  @override
  Future<void> deleteNoteIfExists(String userId, String noteId) =>
      _notes(userId).doc(noteId).delete().timeout(writeTimeout);
}
