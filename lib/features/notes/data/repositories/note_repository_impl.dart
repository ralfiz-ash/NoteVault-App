import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_local_data_source.dart';
import '../datasources/note_remote_data_source.dart';

/// Local-first repository: the local data source is the source of truth and
/// the remote data source is synced in the background.
class NoteRepositoryImpl implements NoteRepository {
  const NoteRepositoryImpl({required this.local, required this.remote});

  final NoteLocalDataSource local;
  final NoteRemoteDataSource remote;

  @override
  Stream<List<Note>> watchNotes() =>
      throw UnimplementedError('Implemented in the Notes phase.');

  @override
  Future<Note?> getNote(String id) =>
      throw UnimplementedError('Implemented in the Notes phase.');

  @override
  Future<void> saveNote(Note note) =>
      throw UnimplementedError('Implemented in the Notes phase.');

  @override
  Future<void> deleteNote(String id) =>
      throw UnimplementedError('Implemented in the Notes phase.');
}
