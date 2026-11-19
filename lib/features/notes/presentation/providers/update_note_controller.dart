import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/firebase_providers.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_draft.dart';
import 'note_use_case_providers.dart';

part 'update_note_controller.g.dart';

/// Saves edits for the "edit note" editor.
///
/// State: `AsyncData(null)` idle, `AsyncLoading` saving, `AsyncData(note)`
/// saved, `AsyncError(Failure)` failed. Not optimistic (same reason as
/// creating): the list and `noteProvider(id)` update from the database as
/// soon as the save is stored, and a failure leaves them untouched.
@riverpod
class UpdateNoteController extends _$UpdateNoteController {
  @override
  FutureOr<Note?> build() => null;

  /// Applies [draft] to [original] and saves it. Returns the saved note, or
  /// `null` if it failed.
  Future<Note?> save(Note original, NoteDraft draft) async {
    if (state.isLoading) return null;
    final analytics = ref.read(appAnalyticsProvider);
    state = const AsyncLoading();
    final result = await AsyncValue.guard<Note?>(
      () => ref.read(updateNoteProvider)(draft.applyTo(original)),
    );
    // Only after the note is stored (locally; works offline). No note data.
    if (!result.hasError) analytics.logNoteSaved();
    if (ref.mounted) state = result;
    return result.value;
  }
}
