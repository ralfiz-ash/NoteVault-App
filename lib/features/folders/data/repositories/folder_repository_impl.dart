import '../../domain/entities/folder.dart';
import '../../domain/repositories/folder_repository.dart';
import '../datasources/folder_local_data_source.dart';

class FolderRepositoryImpl implements FolderRepository {
  const FolderRepositoryImpl(this.local);

  final FolderLocalDataSource local;

  @override
  Stream<List<Folder>> watchFolders() =>
      throw UnimplementedError('Implemented in the Folders phase.');
}
