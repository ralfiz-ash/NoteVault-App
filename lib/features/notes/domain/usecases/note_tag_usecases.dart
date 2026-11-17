import '../../../../core/usecase/usecase.dart';
import '../entities/note.dart';
import '../entities/note_draft.dart';
import '../repositories/note_repository.dart';
import 'update_note.dart';

class NoteTagParams {
  const NoteTagParams({required this.noteId, required this.tagName});

  final String noteId;
  final String tagName;
}

/// Adds a tag (by name) to a note. An existing tag is reused (ignoring
/// case); a new name creates a tag with the default colour.
class AddTagToNote implements UseCase<Future<Note>, NoteTagParams> {
  const AddTagToNote(this._repository);

  final NoteRepository _repository;

  @override
  Future<Note> call(NoteTagParams input) async {
    final note = await _repository.getNote(input.noteId);
    final draft = NoteDraft.fromNote(note);
    return UpdateNote(_repository)(
      draft.copyWith(tags: [...draft.tags, input.tagName]).applyTo(note),
    );
  }
}

/// Removes a tag from one note. Only the link is removed: the tag itself
/// stays available for other notes.
class RemoveTagFromNote implements UseCase<Future<Note>, NoteTagParams> {
  const RemoveTagFromNote(this._repository);

  final NoteRepository _repository;

  @override
  Future<Note> call(NoteTagParams input) async {
    final note = await _repository.getNote(input.noteId);
    final name = input.tagName.trim().toLowerCase();
    return UpdateNote(_repository)(
      note.copyWith(
        tags: [
          for (final tag in note.tags)
            if (tag.toLowerCase() != name) tag,
        ],
      ),
    );
  }
}
