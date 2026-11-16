import '../../../../core/usecase/usecase.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class SaveNote implements UseCase<Future<void>, Note> {
  const SaveNote(this._repository);

  final NoteRepository _repository;

  @override
  Future<void> call(Note input) => _repository.saveNote(input);
}
