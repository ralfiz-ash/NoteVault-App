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
  });

  final FolderLocalDataSource local;
  final ExceptionMapper exceptionMapper;
  final AppLogger logger;

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
    final found = await local.updateFolder(FolderModel.fromEntity(toSave));
    if (!found) throw _notFound(folder.id);
    return _require(folder.id);
  });

  @override
  Future<void> deleteFolder(String id) => _guard(() async {
    if (!await local.deleteFolder(id)) throw _notFound(id);
  });

  Future<Folder> _require(String id) async {
    final model = await local.getFolder(id);
    if (model == null) throw _notFound(id);
    return model.toEntity();
  }

  NotFoundFailure _notFound(String id) =>
      NotFoundFailure(message: 'Folder not found.', cause: id);
}
