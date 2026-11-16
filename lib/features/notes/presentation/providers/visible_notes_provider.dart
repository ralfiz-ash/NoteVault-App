import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/note.dart';
import 'notes_provider.dart';
import 'pending_note_deletions_provider.dart';

part 'visible_notes_provider.g.dart';

/// What the notes list shows: [notesProvider] minus notes whose deletion is
/// in progress. Keeps the loading / error / data state of [notesProvider].
@riverpod
AsyncValue<List<Note>> visibleNotes(Ref ref) {
  final notes = ref.watch(notesProvider);
  final deleting = ref.watch(pendingNoteDeletionsProvider);
  if (deleting.isEmpty) return notes;
  return notes.whenData(
    (list) => [
      for (final note in list)
        if (!deleting.contains(note.id)) note,
    ],
  );
}
