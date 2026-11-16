import '../../domain/entities/note.dart';

/// Serializable form of [Note]. Dates are stored as epoch milliseconds so the
/// same map works for the local database and the cloud without SDK types.
class NoteModel {
  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.folderId,
    this.tags = const [],
  });

  final String id;
  final String title;
  final String content;
  final String? folderId;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory NoteModel.fromEntity(Note note) => NoteModel(
    id: note.id,
    title: note.title,
    content: note.content,
    folderId: note.folderId,
    tags: note.tags,
    createdAt: note.createdAt,
    updatedAt: note.updatedAt,
  );

  factory NoteModel.fromMap(Map<String, dynamic> map) => NoteModel(
    id: map['id'] as String,
    title: map['title'] as String,
    content: map['content'] as String,
    folderId: map['folderId'] as String?,
    tags: List<String>.from(map['tags'] as List? ?? const []),
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      map['createdAt'] as int,
      isUtc: true,
    ),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      map['updatedAt'] as int,
      isUtc: true,
    ),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'folderId': folderId,
    'tags': tags,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
  };

  Note toEntity() => Note(
    id: id,
    title: title,
    content: content,
    folderId: folderId,
    tags: tags,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
