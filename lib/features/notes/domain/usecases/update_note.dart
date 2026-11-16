import '../../../../core/usecase/usecase.dart';
import '../entities/note.dart';
import '../entities/note_draft.dart';
import '../repositories/note_repository.dart';
import '../validation/note_validators.dart';

/// Saves edits to an existing note. The id and creation date are kept; the
/// repository sets the update date.
class UpdateNote implements UseCase<Future<Note>, Note> {
  const UpdateNote(this._repository);

  final NoteRepository _repository;

  @override
  Future<Note> call(Note input) async {
    final draft = NoteDraft.fromNote(input).normalized();
    NoteValidators.check(draft);
    return _repository.updateNote(draft.applyTo(input));
  }
}
