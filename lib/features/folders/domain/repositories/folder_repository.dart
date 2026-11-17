import '../entities/folder.dart';

/// Implementations throw `Failure` types from `core/errors`.
abstract interface class FolderRepository {
  Stream<List<Folder>> watchFolders();

  Future<List<Folder>> getFolders();

  /// Throws `NotFoundFailure` if there is no folder with [id].
  Future<Folder> getFolder(String id);

  Future<Folder> createFolder(Folder folder);

  /// Throws `NotFoundFailure` if the folder does not exist. The creation date
  /// is kept.
  Future<Folder> updateFolder(Folder folder);

  /// Notes in the folder are kept and become folder-less. Throws
  /// `NotFoundFailure` if the folder does not exist.
  Future<void> deleteFolder(String id);

  /// Sync only: makes sure a folder used by a note from the cloud exists
  /// here with that name (creates or renames it), without touching notes or
  /// recording anything to upload.
  Future<void> applyRemoteFolder(Folder folder);
}
