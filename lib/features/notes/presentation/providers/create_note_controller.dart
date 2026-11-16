import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/note.dart';
import '../../domain/entities/note_draft.dart';
import 'note_use_case_providers.dart';

part 'create_note_controller.g.dart';

/// Creates a note for the "new note" editor.
///
/// State: `AsyncData(null)` idle, `AsyncLoading` saving, `AsyncData(note)`
/// created, `AsyncError(Failure)` failed. Not optimistic: the local database
/// answers in milliseconds and the list updates from it by itself, so there
/// is no temporary note that could be shown and then turn out not to exist.
@riverpod
class CreateNoteController extends _$CreateNoteController {
  @override
  FutureOr<Note?> build() => null;

  /// Returns the created note, or `null` if it failed (see [state]).
  Future<Note?> create(NoteDraft draft) async {
    if (state.isLoading) return null;
    state = const AsyncLoading();
    final result = await AsyncValue.guard<Note?>(
      () => ref.read(createNoteProvider)(draft),
    );
    if (ref.mounted) state = result;
    return result.value;
  }
}
