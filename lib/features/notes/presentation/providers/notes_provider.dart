import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/repository_providers.dart';
import '../../domain/entities/note.dart';

part 'notes_provider.g.dart';

/// All notes from the local database (newest edit first), updated live after
/// every change. An empty list is a valid `AsyncData`, not an error.
///
/// keepAlive: this is the shared, local-first cache that `noteProvider`,
/// `folderNotesProvider` and (later) search derive from. Keeping one database
/// watch open avoids re-querying and a loading flash on every navigation.
/// To retry after an error: `ref.invalidate(notesProvider)`.
@Riverpod(keepAlive: true)
Stream<List<Note>> notes(Ref ref) =>
    ref.watch(noteRepositoryProvider).watchNotes();
