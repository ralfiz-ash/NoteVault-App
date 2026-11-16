import '../../../../core/usecase/usecase.dart';
import '../entities/folder.dart';
import '../repositories/folder_repository.dart';

class ObserveFolders implements UseCase<Stream<List<Folder>>, NoParams> {
  const ObserveFolders(this._repository);

  final FolderRepository _repository;

  @override
  Stream<List<Folder>> call(NoParams input) => _repository.watchFolders();
}
