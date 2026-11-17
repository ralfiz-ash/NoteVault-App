import 'note.dart';
import 'note_sort.dart';

/// Which folder(s) a query covers.
sealed class FolderScope {
  const FolderScope();
}

/// No folder restriction.
class AnyFolder extends FolderScope {
  const AnyFolder();

  @override
  bool operator ==(Object other) => other is AnyFolder;

  @override
  int get hashCode => 1;
}

/// Only notes that are not in a folder.
class NoFolder extends FolderScope {
  const NoFolder();

  @override
  bool operator ==(Object other) => other is NoFolder;

  @override
  int get hashCode => 2;
}

class InFolder extends FolderScope {
  const InFolder(this.folderId);

  final String folderId;

  @override
  bool operator ==(Object other) =>
      other is InFolder && other.folderId == folderId;

  @override
  int get hashCode => folderId.hashCode;
}

/// Search + folder + tag + sort for the notes list: the single place that
/// decides which notes match and in what order (pure Dart, no I/O).
///
/// Active conditions are combined with AND; inactive ones (empty search,
/// [AnyFolder], no tag) do not restrict anything.
class NoteQuery {
  const NoteQuery({
    this.search = '',
    this.folder = const AnyFolder(),
    this.tagName,
    this.sort = NoteSort.defaultSort,
  });

  /// Matched case-insensitively against title and content (substring).
  final String search;
  final FolderScope folder;

  /// Tag name, matched ignoring case (notes store tag names).
  final String? tagName;
  final NoteSort sort;

  bool get hasSearch => search.trim().isNotEmpty;
  bool get hasFilters => hasSearch || folder is! AnyFolder || tagName != null;

  bool matches(Note note) {
    final folderOk = switch (folder) {
      AnyFolder() => true,
      NoFolder() => note.folderId == null,
      InFolder(:final folderId) => note.folderId == folderId,
    };
    if (!folderOk) return false;

    final tag = tagName?.toLowerCase();
    if (tag != null && !note.tags.any((t) => t.toLowerCase() == tag)) {
      return false;
    }

    final needle = search.trim().toLowerCase();
    return needle.isEmpty ||
        note.title.toLowerCase().contains(needle) ||
        note.content.toLowerCase().contains(needle);
  }

  /// One pass: filter, then sort (the input list is not modified).
  List<Note> apply(Iterable<Note> notes) =>
      notes.where(matches).toList()..sort(sort.compare);
}
