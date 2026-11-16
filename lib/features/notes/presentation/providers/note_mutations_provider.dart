import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/database_providers.dart';
import '../../../../app/di/repository_providers.dart';
import '../../domain/entities/note.dart';
import '../state/note_mutation_result.dart';

part 'note_mutations_provider.g.dart';

/// Create / update / delete notes through [NoteRepository].
///
/// State (`AsyncValue<NoteMutationResult?>`):
/// - `AsyncData(null)`: idle, nothing done yet
/// - `AsyncLoading`: a mutation is running
/// - `AsyncData(result)`: the last mutation succeeded
/// - `AsyncError(Failure)`: the last mutation failed
///
/// Call from callbacks with `ref.read(noteMutationsProvider.notifier)`, and
/// keep a `ref.watch` / `ref.listen` on the provider while the screen is open
/// (it is auto-disposed with the screen). The notes list updates by itself
/// because [notesProvider] watches the database.
@riverpod
class NoteMutations extends _$NoteMutations {
  @override
  FutureOr<NoteMutationResult?> build() => null;

  /// Creates a note with a new id; both timestamps are "now".
  Future<Note?> createNote({
    required String title,
    required String content,
    String? folderId,
    List<String> tags = const [],
  }) {
    final now = ref.read(clockProvider)();
    final note = Note(
      id: ref.read(idGeneratorProvider).newId(),
      title: title,
      content: content,
      folderId: folderId,
      tags: tags,
      createdAt: now,
      updatedAt: now,
    );
    return _run(
      NoteMutationKind.created,
      note.id,
      () => ref.read(noteRepositoryProvider).createNote(note),
    );
  }

  /// Saves changes; the repository keeps the creation date and stamps the
  /// update date.
  Future<Note?> updateNote(Note note) => _run(
    NoteMutationKind.updated,
    note.id,
    () => ref.read(noteRepositoryProvider).updateNote(note),
  );

  Future<void> deleteNote(String id) =>
      _run(NoteMutationKind.deleted, id, () async {
        await ref.read(noteRepositoryProvider).deleteNote(id);
        return null;
      });

  /// Runs [action] and records loading / success / error. Returns the saved
  /// note, or `null` on failure (the failure is in [state]).
  Future<Note?> _run(
    NoteMutationKind kind,
    String noteId,
    Future<Note?> Function() action,
  ) async {
    state = const AsyncLoading();
    Note? saved;
    final result = await AsyncValue.guard(() async {
      saved = await action();
      return NoteMutationResult(kind, noteId);
    });
    if (ref.mounted) state = result;
    return result.hasError ? null : saved;
  }
}
