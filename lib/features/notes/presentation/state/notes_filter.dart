/// Which notes the list shows.
sealed class NotesFilter {
  const NotesFilter();
}

class AllNotes extends NotesFilter {
  const AllNotes();

  @override
  bool operator ==(Object other) => other is AllNotes;

  @override
  int get hashCode => 0;
}

/// Notes in one folder, or ([folderId] == null) notes in no folder.
class FolderFilter extends NotesFilter {
  const FolderFilter(this.folderId);

  final String? folderId;

  @override
  bool operator ==(Object other) =>
      other is FolderFilter && other.folderId == folderId;

  @override
  int get hashCode => Object.hash('folder', folderId);
}

class TagFilter extends NotesFilter {
  const TagFilter(this.tagId);

  final String tagId;

  @override
  bool operator ==(Object other) => other is TagFilter && other.tagId == tagId;

  @override
  int get hashCode => Object.hash('tag', tagId);
}
