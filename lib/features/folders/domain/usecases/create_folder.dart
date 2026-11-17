import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/clock.dart';
import '../../../../core/utils/id_generator.dart';
import '../entities/folder.dart';
import '../repositories/folder_repository.dart';

/// Creates a folder with the given name (trimmed, required).
class CreateFolder implements UseCase<Future<Folder>, String> {
  const CreateFolder(this._repository, this._ids, this._clock);

  static const maxNameLength = 60;

  final FolderRepository _repository;
  final IdGenerator _ids;
  final Clock _clock;

  static String? validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Folder name is required';
    if (name.length > maxNameLength) {
      return 'Folder name must be at most $maxNameLength characters';
    }
    return null;
  }

  @override
  Future<Folder> call(String input) async {
    final error = validateName(input);
    if (error != null) {
      throw ValidationFailure(message: error, fieldErrors: {'name': error});
    }
    return _repository.createFolder(
      Folder(id: _ids.newId(), name: input.trim(), createdAt: _clock().toUtc()),
    );
  }
}
