import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/note_model.dart';

/// Conversions between the database row types and [NoteModel].
/// Dates are stored as epoch milliseconds (UTC).
extension NoteRowMapper on NoteRow {
  NoteModel toModel(List<String> tags) => NoteModel(
    id: id,
    title: title,
    content: content,
    folderId: folderId,
    tags: tags,
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt, isUtc: true),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt, isUtc: true),
    version: version,
  );
}

extension NoteModelRowMapper on NoteModel {
  NotesCompanion toCompanion() => NotesCompanion(
    id: Value(id),
    title: Value(title),
    content: Value(content),
    folderId: Value(folderId),
    createdAt: Value(createdAt.millisecondsSinceEpoch),
    updatedAt: Value(updatedAt.millisecondsSinceEpoch),
    version: Value(version),
  );
}
