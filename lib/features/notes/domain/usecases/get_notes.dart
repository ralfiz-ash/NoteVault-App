import '../../../../core/usecase/usecase.dart';
import '../entities/note.dart';
import '../repositories/note_repository.dart';

/// All of the user's notes once (newest edit first). For a live list use
/// [ObserveNotes].
class GetNotes implements UseCase<Future<List<Note>>, NoParams> {
  const GetNotes(this._repository);

  final NoteRepository _repository;

  @override
  Future<List<Note>> call(NoParams input) => _repository.getNotes();
}
