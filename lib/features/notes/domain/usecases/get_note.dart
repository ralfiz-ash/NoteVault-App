import '../../../../core/usecase/usecase.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class GetNote implements UseCase<Future<Note>, String> {
  const GetNote(this._repository);

  final NoteRepository _repository;

  @override
  Future<Note> call(String input) => _repository.getNote(input);
}
