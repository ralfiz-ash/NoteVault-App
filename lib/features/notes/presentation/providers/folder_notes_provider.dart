import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/note.dart';
import 'visible_notes_provider.dart';

part 'folder_notes_provider.g.dart';

/// Notes in one folder ([folderId] == null: notes in no folder), in list
/// order. Filtered from [visibleNotesProvider] (no extra query, and notes
/// being deleted are already hidden), so it updates on every change. One
/// instance per folder id, auto-disposed when unused.
@riverpod
AsyncValue<List<Note>> folderNotes(Ref ref, String? folderId) => ref
    .watch(visibleNotesProvider)
    .whenData(
      (notes) => [
        for (final note in notes)
          if (note.folderId == folderId) note,
      ],
    );
