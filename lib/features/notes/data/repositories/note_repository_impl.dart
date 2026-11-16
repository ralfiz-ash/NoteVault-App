import '../../../../core/errors/exception_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/guard.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../../core/utils/clock.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_local_data_source.dart';
import '../models/note_model.dart';

/// Local-first note repository. Maps between domain entities and data models
/// and converts storage errors into `Failure`s.
class NoteRepositoryImpl implements NoteRepository {
  const NoteRepositoryImpl({
    required this.local,
    required this.exceptionMapper,
    required this.clock,
    this.logger = const NoOpLogger(),
  });

  final NoteLocalDataSource local;
  final ExceptionMapper exceptionMapper;
  final Clock clock;
  final AppLogger logger;

  Future<T> _guard<T>(Future<T> Function() action) =>
      guardFailures(action, mapper: exceptionMapper, logger: logger);

  @override
  Stream<List<Note>> watchNotes() => guardFailureStream(
    local.watchNotes().map((models) => [for (final m in models) m.toEntity()]),
    mapper: exceptionMapper,
    logger: logger,
  );

  @override
  Future<List<Note>> getNotes() => _guard(() async {
    final models = await local.getNotes();
    return [for (final m in models) m.toEntity()];
  });

  @override
  Future<Note> getNote(String id) => _guard(() => _requireNote(id));

  @override
  Future<Note> createNote(Note note) => _guard(() async {
    await local.insertNote(NoteModel.fromEntity(note));
    return _requireNote(note.id);
  });

  @override
  Future<Note> updateNote(Note note) => _guard(() async {
    final existing = await _requireNote(note.id);
    final toSave = Note(
      id: existing.id,
      title: note.title,
      content: note.content,
      folderId: note.folderId,
      tags: note.tags,
      createdAt: existing.createdAt,
      updatedAt: clock(),
    );
    final found = await local.updateNote(NoteModel.fromEntity(toSave));
    if (!found) throw _notFound(note.id);
    return _requireNote(note.id);
  });

  @override
  Future<void> deleteNote(String id) => _guard(() async {
    final removed = await local.deleteNote(id);
    if (!removed) throw _notFound(id);
  });

  Future<Note> _requireNote(String id) async {
    final model = await local.getNote(id);
    if (model == null) throw _notFound(id);
    return model.toEntity();
  }

  NotFoundFailure _notFound(String id) =>
      NotFoundFailure(message: 'Note not found.', cause: id);
}
