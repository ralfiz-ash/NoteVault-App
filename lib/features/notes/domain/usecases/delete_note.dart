import '../../../../core/usecase/usecase.dart';
import '../repositories/note_repository.dart';

class DeleteNote implements UseCase<Future<void>, String> {
  const DeleteNote(this._repository);

  final NoteRepository _repository;

  @override
  Future<void> call(String input) => _repository.deleteNote(input);
}
