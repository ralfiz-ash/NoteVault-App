class Note {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.folderId,
    this.tags = const [],
    this.version = 1,
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

  /// Revision counter used for sync: 1 when created, +1 for every local
  /// change. The same number means the same revision on every device and in
  /// the cloud (see `NoteVersioning`).
  final int version;

  Note copyWith({
    String? title,
    String? content,
    String? Function()? folderId,
    List<String>? tags,
    DateTime? updatedAt,
    int? version,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      folderId: folderId != null ? folderId() : this.folderId,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
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
      other.updatedAt == updatedAt &&
      other.version == version;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    content,
    folderId,
    Object.hashAll(tags),
    createdAt,
    updatedAt,
    version,
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
