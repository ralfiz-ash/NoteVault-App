import '../../../../core/errors/exception_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/guard.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_remote_repository.dart';
import '../datasources/note_remote_data_source.dart';
import '../models/note_model.dart';

class NoteRemoteRepositoryImpl implements NoteRemoteRepository {
  const NoteRemoteRepositoryImpl({
    required this.remote,
    required this.exceptionMapper,
    this.logger = const NoOpLogger(),
  });

  final NoteRemoteDataSource remote;
  final ExceptionMapper exceptionMapper;
  final AppLogger logger;

  Future<T> _guard<T>(Future<T> Function() action) =>
      guardFailures(action, mapper: exceptionMapper, logger: logger);

  @override
  Stream<List<Note>> watchNotes(String userId) => guardFailureStream(
    remote.watchNotes(userId).map((m) => [for (final n in m) n.toEntity()]),
    mapper: exceptionMapper,
    logger: logger,
  );

  @override
  Future<List<Note>> getNotes(String userId) => _guard(() async {
    final models = await remote.getNotes(userId);
    return [for (final m in models) m.toEntity()];
  });

  @override
  Future<Note> getNote(String userId, String noteId) =>
      _guard(() => _require(userId, noteId));

  @override
  Future<Note> createNote(String userId, Note note) => _guard(() async {
    final created = await remote.createNote(userId, NoteModel.fromEntity(note));
    if (!created) {
      throw RemoteFailure(
        message: 'This note already exists in the cloud.',
        cause: note.id,
      );
    }
    return _require(userId, note.id);
  });

  @override
  Future<Note> updateNote(String userId, Note note) => _guard(() async {
    final found = await remote.updateNote(userId, NoteModel.fromEntity(note));
    if (!found) throw _notFound(note.id);
    return _require(userId, note.id);
  });

  @override
  Future<void> deleteNote(String userId, String noteId) => _guard(() async {
    if (!await remote.deleteNote(userId, noteId)) throw _notFound(noteId);
  });

  Future<Note> _require(String userId, String noteId) async {
    final model = await remote.getNote(userId, noteId);
    if (model == null) throw _notFound(noteId);
    return model.toEntity();
  }

  NotFoundFailure _notFound(String id) =>
      NotFoundFailure(message: 'Note not found in the cloud.', cause: id);
}
