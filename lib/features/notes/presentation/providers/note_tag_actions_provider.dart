import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/repository_providers.dart';
import '../../domain/usecases/note_tag_usecases.dart';

part 'note_tag_actions_provider.g.dart';

@riverpod
AddTagToNote addTagToNote(Ref ref) =>
    AddTagToNote(ref.watch(noteRepositoryProvider));

@riverpod
RemoveTagFromNote removeTagFromNote(Ref ref) =>
    RemoveTagFromNote(ref.watch(noteRepositoryProvider));

/// Adds/removes a tag on the open note (note screen). Removing only unlinks
/// it; the tag stays available. State: idle/done, loading, or
/// `AsyncError(Failure)`.
@riverpod
class NoteTagActions extends _$NoteTagActions {
  @override
  FutureOr<void> build() {}

  Future<void> add(String noteId, String tagName) => _run(
    () => ref.read(addTagToNoteProvider)(
      NoteTagParams(noteId: noteId, tagName: tagName),
    ),
  );

  Future<void> remove(String noteId, String tagName) => _run(
    () => ref.read(removeTagFromNoteProvider)(
      NoteTagParams(noteId: noteId, tagName: tagName),
    ),
  );

  Future<void> _run(Future<Object?> Function() action) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard<void>(action);
    if (ref.mounted) state = result;
  }
}
