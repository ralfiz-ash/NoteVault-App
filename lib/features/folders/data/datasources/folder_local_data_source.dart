import '../models/folder_model.dart';

/// Placeholder boundary for the local database.
abstract interface class FolderLocalDataSource {
  Stream<List<FolderModel>> watchFolders();
}
