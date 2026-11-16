class Note {
  const Note({
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

  /// `null` means the note is not in any folder.
  final String? folderId;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
}
