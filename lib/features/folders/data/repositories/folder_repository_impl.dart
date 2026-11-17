import '../../../../core/database/local_transaction.dart';
import '../../../../core/database/sync_queue_store.dart';
import '../../../../core/errors/exception_mapper.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/guard.dart';
import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/folder.dart';
import '../../domain/repositories/folder_repository.dart';
import '../datasources/folder_local_data_source.dart';
import '../models/folder_model.dart';

class FolderRepositoryImpl implements FolderRepository {
  const FolderRepositoryImpl({
    required this.local,
    required this.exceptionMapper,
    this.logger = const NoOpLogger(),
    this.outbox,
    this.transactions = const NoTransactionRunner(),
  });

  final FolderLocalDataSource local;
  final ExceptionMapper exceptionMapper;
  final AppLogger logger;

  /// Folders themselves are not synced yet, but deleting one changes its
  /// notes (they lose the folder), so those notes are queued for upload.
  final SyncOutbox? outbox;
  final LocalTransactionRunner transactions;

  Future<T> _guard<T>(Future<T> Function() action) =>
      guardFailures(action, mapper: exceptionMapper, logger: logger);

  @override
  Stream<List<Folder>> watchFolders() => guardFailureStream(
    local.watchFolders().map((m) => [for (final f in m) f.toEntity()]),
    mapper: exceptionMapper,
    logger: logger,
  );

  @override
  Future<List<Folder>> getFolders() => _guard(() async {
    final models = await local.getFolders();
    return [for (final m in models) m.toEntity()];
  });

  @override
  Future<Folder> getFolder(String id) => _guard(() => _require(id));

  @override
  Future<Folder> createFolder(Folder folder) => _guard(() async {
    await local.insertFolder(FolderModel.fromEntity(folder));
    return _require(folder.id);
  });

  @override
  Future<Folder> updateFolder(Folder folder) => _guard(() async {
    final existing = await _require(folder.id);
    final toSave = Folder(
      id: existing.id,
      name: folder.name,
      createdAt: existing.createdAt,
    );
    await transactions.run(() async {
      final found = await local.updateFolder(FolderModel.fromEntity(toSave));
      if (!found) throw _notFound(folder.id);
      // Cloud copies of its notes carry the folder name: re-upload them.
      if (existing.name != toSave.name) {
        await local.bumpNoteVersions(folder.id);
        for (final noteId in await local.noteIdsInFolder(folder.id)) {
          await outbox?.record(SyncEntity.note, noteId, SyncOperation.update);
        }
      }
    });
    return _require(folder.id);
  });

  @override
  Future<void> deleteFolder(String id) => _guard(() async {
    await transactions.run(() async {
      final affected = await local.noteIdsInFolder(id);
      if (!await local.deleteFolder(id)) throw _notFound(id);
      for (final noteId in affected) {
        await outbox?.record(SyncEntity.note, noteId, SyncOperation.update);
      }
    });
  });

  @override
  Future<void> applyRemoteFolder(Folder folder) => _guard(() async {
    final existing = await local.getFolder(folder.id);
    if (existing != null && existing.name == folder.name) return;
    await local.upsertFolder(
      FolderModel(
        id: folder.id,
        name: folder.name,
        createdAt: existing?.createdAt ?? folder.createdAt,
      ),
    );
  });

  Future<Folder> _require(String id) async {
    final model = await local.getFolder(id);
    if (model == null) throw _notFound(id);
    return model.toEntity();
  }

  NotFoundFailure _notFound(String id) =>
      NotFoundFailure(message: 'Folder not found.', cause: id);
}
