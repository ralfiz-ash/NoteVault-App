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

  /// Stable id generated on the device, so it stays the same across storage
  /// and (later) cloud sync.
  final String id;
  final String title;
  final String content;

  /// `null` means the note is not in any folder.
  final String? folderId;

  /// Tag names (case-insensitive: "Work" and "work" are one tag).
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note copyWith({
    String? title,
    String? content,
    String? Function()? folderId,
    List<String>? tags,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      folderId: folderId != null ? folderId() : this.folderId,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Note &&
      other.id == id &&
      other.title == title &&
      other.content == content &&
      other.folderId == folderId &&
      _sameList(other.tags, tags) &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    content,
    folderId,
    Object.hashAll(tags),
    createdAt,
    updatedAt,
  );

  @override
  String toString() => 'Note($id, "$title")';
}

bool _sameList(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
