import 'note.dart';

/// The user-editable part of a note (what the editor changes). Used to create
/// notes and to tell whether the editor has unsaved changes (value equality).
class NoteDraft {
  const NoteDraft({
    this.title = '',
    this.content = '',
    this.folderId,
    this.tags = const [],
  });

  factory NoteDraft.fromNote(Note note) => NoteDraft(
    title: note.title,
    content: note.content,
    folderId: note.folderId,
    tags: note.tags,
  );

  final String title;
  final String content;
  final String? folderId;
  final List<String> tags;

  NoteDraft copyWith({
    String? title,
    String? content,
    String? Function()? folderId,
    List<String>? tags,
  }) => NoteDraft(
    title: title ?? this.title,
    content: content ?? this.content,
    folderId: folderId != null ? folderId() : this.folderId,
    tags: tags ?? this.tags,
  );

  /// Trimmed title and tags, empty and duplicate (case-insensitive) tags
  /// removed. Content is kept as typed.
  NoteDraft normalized() {
    final seen = <String>{};
    final cleanTags = [
      for (final tag in tags.map((t) => t.trim()))
        if (tag.isNotEmpty && seen.add(tag.toLowerCase())) tag,
    ];
    return NoteDraft(
      title: title.trim(),
      content: content,
      folderId: folderId,
      tags: cleanTags,
    );
  }

  /// [note] with this draft's editable fields (id and dates unchanged).
  Note applyTo(Note note) => Note(
    id: note.id,
    title: title,
    content: content,
    folderId: folderId,
    tags: tags,
    createdAt: note.createdAt,
    updatedAt: note.updatedAt,
    version: note.version,
  );

  @override
  bool operator ==(Object other) =>
      other is NoteDraft &&
      other.title == title &&
      other.content == content &&
      other.folderId == folderId &&
      _sameTags(other.tags, tags);

  @override
  int get hashCode =>
      Object.hash(title, content, folderId, Object.hashAll(tags));
}

bool _sameTags(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
