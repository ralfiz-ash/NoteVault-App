import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note_model.dart';

/// Firestore document shape for a note, at `users/{userId}/notes/{noteId}`:
///
/// | field     | type              |
/// |-----------|-------------------|
/// | id        | string (= doc id) |
/// | title     | string            |
/// | content   | string            |
/// | folderId  | string or null    |
/// | tags      | `array<string>`   |
/// | createdAt | timestamp (UTC)   |
/// | updatedAt | timestamp (UTC)   |
///
/// Firestore `Timestamp`s exist only here; models and entities get UTC
/// `DateTime`s, matching the local database.
abstract final class NoteFirestoreMapper {
  static const notesCollection = 'notes';
  static const usersCollection = 'users';

  static Map<String, Object?> toDocument(NoteModel note) => {
    'id': note.id,
    'title': note.title,
    'content': note.content,
    'folderId': note.folderId,
    'tags': note.tags,
    'createdAt': Timestamp.fromDate(note.createdAt.toUtc()),
    'updatedAt': Timestamp.fromDate(note.updatedAt.toUtc()),
  };

  static NoteModel fromDocument(String docId, Map<String, Object?> data) {
    return NoteModel(
      id: data['id'] as String? ?? docId,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      folderId: data['folderId'] as String?,
      tags: List<String>.from(data['tags'] as List? ?? const []),
      createdAt: _toUtc(data['createdAt']),
      updatedAt: _toUtc(data['updatedAt']),
    );
  }

  static DateTime _toUtc(Object? value) {
    if (value is Timestamp) return value.toDate().toUtc();
    throw FormatException('Expected a Firestore Timestamp, got $value');
  }
}
