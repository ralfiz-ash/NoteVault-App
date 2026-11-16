import 'package:notevalult/features/folders/domain/entities/folder.dart';
import 'package:notevalult/features/notes/domain/entities/note.dart';

final fixedNow = DateTime.utc(2026, 11, 16, 12);

Note buildNote({
  String id = 'note-1',
  String title = 'Title',
  String content = 'Content',
  String? folderId,
  List<String> tags = const [],
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final created = createdAt ?? DateTime.utc(2026, 1, 1);
  return Note(
    id: id,
    title: title,
    content: content,
    folderId: folderId,
    tags: tags,
    createdAt: created,
    updatedAt: updatedAt ?? created,
  );
}

Folder buildFolder({String id = 'folder-1', String name = 'Work'}) =>
    Folder(id: id, name: name, createdAt: DateTime.utc(2026, 1, 1));
