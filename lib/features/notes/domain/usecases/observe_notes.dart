import '../../../../core/usecase/usecase.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

class ObserveNotes implements UseCase<Stream<List<Note>>, NoParams> {
  const ObserveNotes(this._repository);

  final NoteRepository _repository;

  @override
  Stream<List<Note>> call(NoParams input) => _repository.watchNotes();
}
