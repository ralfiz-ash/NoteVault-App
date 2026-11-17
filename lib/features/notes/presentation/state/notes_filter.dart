import '../../domain/entities/note_query.dart';

/// The list's folder and tag selection (search text and sort live in their
/// own providers). Both can be active at once.
class NotesFilterState {
  const NotesFilterState({this.folder = const AnyFolder(), this.tagId});

  final FolderScope folder;
  final String? tagId;

  bool get isActive => folder is! AnyFolder || tagId != null;

  NotesFilterState copyWith({FolderScope? folder, String? Function()? tagId}) =>
      NotesFilterState(
        folder: folder ?? this.folder,
        tagId: tagId != null ? tagId() : this.tagId,
      );

  @override
  bool operator ==(Object other) =>
      other is NotesFilterState &&
      other.folder == folder &&
      other.tagId == tagId;

  @override
  int get hashCode => Object.hash(folder, tagId);
}
