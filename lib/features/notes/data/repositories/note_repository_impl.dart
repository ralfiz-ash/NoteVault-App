import '../../../../core/database/local_transaction.dart';
import '../../../../core/database/sync_queue_store.dart';
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
///
/// Every change is written to the local database first and, in the same
/// local transaction, recorded in the sync [outbox]: either both are saved
/// or neither is. The cloud is never waited for.
class NoteRepositoryImpl implements NoteRepository {
  const NoteRepositoryImpl({
    required this.local,
    required this.exceptionMapper,
    required this.clock,
    this.logger = const NoOpLogger(),
    this.outbox,
    this.transactions = const NoTransactionRunner(),
  });

  final NoteLocalDataSource local;
  final ExceptionMapper exceptionMapper;
  final Clock clock;
  final AppLogger logger;

  /// Where changes are recorded for upload; `null` disables sync recording.
  final SyncOutbox? outbox;
  final LocalTransactionRunner transactions;

  Future<void> _recordSync(String noteId, SyncOperation op) async =>
      outbox?.record(SyncEntity.note, noteId, op);

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
    await transactions.run(() async {
      await local.insertNote(NoteModel.fromEntity(note));
      await _recordSync(note.id, SyncOperation.create);
    });
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
    await transactions.run(() async {
      final found = await local.updateNote(NoteModel.fromEntity(toSave));
      if (!found) throw _notFound(note.id);
      await _recordSync(note.id, SyncOperation.update);
    });
    return _requireNote(note.id);
  });

  @override
  Future<void> deleteNote(String id) => _guard(() async {
    await transactions.run(() async {
      final removed = await local.deleteNote(id);
      if (!removed) throw _notFound(id);
      // The id stays in the queue after the note row is gone, so the cloud
      // copy can still be deleted later.
      await _recordSync(id, SyncOperation.delete);
    });
  });

  Future<Note> _requireNote(String id) async {
    final model = await local.getNote(id);
    if (model == null) throw _notFound(id);
    return model.toEntity();
  }

  NotFoundFailure _notFound(String id) =>
      NotFoundFailure(message: 'Note not found.', cause: id);
}
