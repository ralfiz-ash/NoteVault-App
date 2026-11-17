import '../models/folder_model.dart';

/// Local persistence boundary for folders. Errors propagate to the
/// repository, which converts them to `Failure`s.
abstract interface class FolderLocalDataSource {
  Stream<List<FolderModel>> watchFolders();

  Future<List<FolderModel>> getFolders();

  Future<FolderModel?> getFolder(String id);

  Future<void> insertFolder(FolderModel folder);

  /// Returns `false` when there is no such folder.
  Future<bool> updateFolder(FolderModel folder);

  /// Ids of the notes in the folder.
  Future<List<String>> noteIdsInFolder(String id);

  /// Notes in the folder lose their folder reference. Returns `false` when
  /// there is no such folder.
  Future<bool> deleteFolder(String id);
}
