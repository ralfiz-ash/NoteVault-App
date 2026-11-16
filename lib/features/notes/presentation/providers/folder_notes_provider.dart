import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/note.dart';
import 'notes_provider.dart';

part 'folder_notes_provider.g.dart';

/// Notes in one folder, in the same order as [notesProvider].
///
/// Derived (filtered) from [notesProvider], so it reacts to every change
/// without duplicating note data. One cached instance per folder id,
/// auto-disposed when no longer used.
@riverpod
Future<List<Note>> folderNotes(Ref ref, String folderId) async {
  final notes = await ref.watch(notesProvider.future);
  return [
    for (final note in notes)
      if (note.folderId == folderId) note,
  ];
}
