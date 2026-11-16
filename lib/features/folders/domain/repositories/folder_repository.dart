import '../entities/folder.dart';

abstract interface class FolderRepository {
  Stream<List<Folder>> watchFolders();
}
