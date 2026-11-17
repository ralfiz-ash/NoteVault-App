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
/// | version   | int (sync revision) |
/// | folderName| string or null (so other devices can recreate the folder) |
///
/// Firestore `Timestamp`s exist only here; models and entities get UTC
/// `DateTime`s, matching the local database.
abstract final class NoteFirestoreMapper {
  static const notesCollection = 'notes';
  static const usersCollection = 'users';

  static Map<String, Object?> toDocument(
    NoteModel note, {
    String? folderName,
  }) => {
    'id': note.id,
    'title': note.title,
    'content': note.content,
    'folderId': note.folderId,
    'tags': note.tags,
    'createdAt': Timestamp.fromDate(note.createdAt.toUtc()),
    'updatedAt': Timestamp.fromDate(note.updatedAt.toUtc()),
    'version': note.version,
    'folderName': note.folderId == null ? null : folderName,
  };

  static String? folderNameOf(Map<String, Object?> data) =>
      data['folderName'] as String?;

  static NoteModel fromDocument(String docId, Map<String, Object?> data) {
    return NoteModel(
      id: data['id'] as String? ?? docId,
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      folderId: data['folderId'] as String?,
      tags: List<String>.from(data['tags'] as List? ?? const []),
      createdAt: _toUtc(data['createdAt']),
      updatedAt: _toUtc(data['updatedAt']),
      // Documents written before versions existed count as revision 1.
      version: (data['version'] as num?)?.toInt() ?? 1,
    );
  }

  static DateTime _toUtc(Object? value) {
    if (value is Timestamp) return value.toDate().toUtc();
    throw FormatException('Expected a Firestore Timestamp, got $value');
  }
}
