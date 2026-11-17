import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/database_providers.dart';
import '../../../../app/di/repository_providers.dart';
import '../../domain/usecases/create_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/observe_notes.dart';
import '../../domain/usecases/update_note.dart';

part 'note_use_case_providers.g.dart';

/// Note use cases on top of the injected [NoteRepository] (the signed-in
/// user's local database). Stateless, so auto-disposed when unused.

/// keepAlive because the long-lived `notesProvider` depends on it.
@Riverpod(keepAlive: true)
ObserveNotes observeNotes(Ref ref) =>
    ObserveNotes(ref.watch(noteRepositoryProvider));

@riverpod
CreateNote createNote(Ref ref) => CreateNote(
  ref.watch(noteRepositoryProvider),
  ref.watch(idGeneratorProvider),
  ref.watch(clockProvider),
);

@riverpod
UpdateNote updateNote(Ref ref) => UpdateNote(ref.watch(noteRepositoryProvider));

@riverpod
DeleteNote deleteNote(Ref ref) => DeleteNote(ref.watch(noteRepositoryProvider));
