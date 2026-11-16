import '../../../../core/usecase/usecase.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class CreateNote implements UseCase<Future<Note>, Note> {
  const CreateNote(this._repository);

  final NoteRepository _repository;

  @override
  Future<Note> call(Note input) => _repository.createNote(input);
}
