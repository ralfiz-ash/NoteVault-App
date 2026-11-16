import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/session_providers.dart';
import '../../domain/entities/note.dart';
import '../state/notes_filter.dart';
import 'folder_notes_provider.dart';
import 'tag_notes_provider.dart';
import 'visible_notes_provider.dart';

part 'notes_filter_provider.g.dart';

/// The list's current filter (all / folder / no folder / tag). Screen state
/// of the notes list, so it is auto-disposed with it; it resets when the
/// user changes.
@riverpod
class NotesFilterController extends _$NotesFilterController {
  @override
  NotesFilter build() {
    ref.watch(currentUserIdProvider.select((session) => session.value));
    return const AllNotes();
  }

  void show(NotesFilter filter) => state = filter;
}

/// The notes the list shows for the current filter. Delegates to the
/// per-folder / per-tag family providers, so each filter is its own cached,
/// independent instance.
@riverpod
AsyncValue<List<Note>> filteredNotes(Ref ref) =>
    switch (ref.watch(notesFilterControllerProvider)) {
      AllNotes() => ref.watch(visibleNotesProvider),
      FolderFilter(:final folderId) => ref.watch(folderNotesProvider(folderId)),
      TagFilter(:final tagId) => ref.watch(tagNotesProvider(tagId)),
    };
