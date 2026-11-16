import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/utils/id_generator.dart';
import '../entities/note.dart';
import '../entities/note_draft.dart';
import '../repositories/note_repository.dart';
import '../validation/note_validators.dart';

/// Creates a note from a draft: validates it, gives it a new id and sets both
/// timestamps to now (UTC).
class CreateNote implements UseCase<Future<Note>, NoteDraft> {
  const CreateNote(this._repository, this._ids, this._clock);

  final NoteRepository _repository;
  final IdGenerator _ids;
  final Clock _clock;

  @override
  Future<Note> call(NoteDraft input) async {
    final draft = input.normalized();
    NoteValidators.check(draft);
    final now = _clock().toUtc();
    return _repository.createNote(
      Note(
        id: _ids.newId(),
        title: draft.title,
        content: draft.content,
        folderId: draft.folderId,
        tags: draft.tags,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}
