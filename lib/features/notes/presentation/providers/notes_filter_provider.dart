import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/session_providers.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../../tags/presentation/providers/tags_provider.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_query.dart';
import '../state/notes_filter.dart';
import 'folder_notes_provider.dart';
import 'tag_notes_provider.dart';
import 'visible_notes_provider.dart';

part 'notes_filter_provider.g.dart';

/// How long typing must pause before the search is applied.
@riverpod
Duration searchDebounce(Ref ref) => const Duration(milliseconds: 300);

/// The applied (debounced, trimmed) search text.
///
/// [onInput] is called for every keystroke; it restarts a timer and only the
/// last value is applied once typing pauses, so the list is not refiltered
/// per character. The timer is cancelled when the provider is disposed or
/// rebuilt (user change). State only changes when the text really changes.
@riverpod
class NoteSearchController extends _$NoteSearchController {
  Timer? _timer;

  @override
  String build() {
    ref.watch(currentUserIdProvider.select((session) => session.value));
    ref.onDispose(() => _timer?.cancel());
    return '';
  }

  void onInput(String text) {
    _timer?.cancel();
    final delay = ref.read(searchDebounceProvider);
    if (delay <= Duration.zero) return _apply(text);
    _timer = Timer(delay, () => _apply(text));
  }

  /// Applies at once (e.g. the clear button).
  void setNow(String text) {
    _timer?.cancel();
    _apply(text);
  }

  void _apply(String text) {
    final query = text.trim();
    if (ref.mounted && query != state) state = query;
  }
}

/// Folder and tag selection of the notes list. Resets when the user changes.
@riverpod
class NotesFilterController extends _$NotesFilterController {
  @override
  NotesFilterState build() {
    ref.watch(currentUserIdProvider.select((session) => session.value));
    return const NotesFilterState();
  }

  void setFolder(FolderScope folder) => state = state.copyWith(folder: folder);

  void setTag(String? tagId) => state = state.copyWith(tagId: () => tagId);

  void clear() => state = const NotesFilterState();
}

/// The full query (search + folder + tag + sort) built from its sources.
/// Only the pieces it uses are watched (e.g. the sort, not the theme; the
/// selected tag's name, not every tag colour), so unrelated changes do not
/// recompute the list.
@riverpod
NoteQuery noteQuery(Ref ref) {
  final filter = ref.watch(notesFilterControllerProvider);
  final tagId = filter.tagId;
  final tagName = tagId == null
      ? null
      : ref.watch(
          tagsProvider.select(
            (tags) => tags.value
                ?.where((t) => t.id == tagId)
                .map((t) => t.name)
                .firstOrNull,
          ),
        );
  return NoteQuery(
    search: ref.watch(noteSearchControllerProvider),
    folder: filter.folder,
    tagName: tagName,
    sort: ref.watch(noteSortSettingProvider),
  );
}

/// THE list the notes screen shows. Derived only; nothing is stored.
///
/// It starts from the per-folder / per-tag family providers
/// (`folderNotesProvider(folderId)`, `tagNotesProvider(tagId)`, each cached
/// separately) or all visible notes, then [NoteQuery.apply] adds search and
/// the other active filter and sorts, in one pass. All matching rules live in
/// [NoteQuery]. Loading and errors pass through unchanged (an error is never
/// turned into an empty list).
@riverpod
AsyncValue<List<Note>> filteredNotes(Ref ref) {
  final query = ref.watch(noteQueryProvider);
  final filter = ref.watch(notesFilterControllerProvider);
  final tagId = filter.tagId;
  final base = switch (filter.folder) {
    InFolder(:final folderId) => ref.watch(folderNotesProvider(folderId)),
    NoFolder() => ref.watch(folderNotesProvider(null)),
    AnyFolder() when tagId != null => ref.watch(tagNotesProvider(tagId)),
    AnyFolder() => ref.watch(visibleNotesProvider),
  };
  return base.whenData(query.apply);
}
