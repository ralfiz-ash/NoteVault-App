import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/folder.dart';
import '../repositories/folder_repository.dart';
import 'create_folder.dart';

/// Renames a folder (same name rules as creating one).
class RenameFolder implements UseCase<Future<Folder>, Folder> {
  const RenameFolder(this._repository);

  final FolderRepository _repository;

  @override
  Future<Folder> call(Folder input) async {
    final error = CreateFolder.validateName(input.name);
    if (error != null) {
      throw ValidationFailure(message: error, fieldErrors: {'name': error});
    }
    return _repository.updateFolder(input.copyWith(name: input.name.trim()));
  }
}

/// Deletes a folder. Its notes are kept and become "No folder"; nothing else
/// about them changes.
class DeleteFolder implements UseCase<Future<void>, String> {
  const DeleteFolder(this._repository);

  final FolderRepository _repository;

  @override
  Future<void> call(String input) => _repository.deleteFolder(input);
}
