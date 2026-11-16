import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/id_generator.dart';
import '../entities/tag.dart';
import '../repositories/tag_repository.dart';
import '../validation/tag_validators.dart';

class CreateTagParams {
  const CreateTagParams({required this.name, required this.colorValue});

  final String name;
  final String colorValue;
}

/// Creates an independent tag with a colour. Fails with `ValidationFailure`
/// for an invalid name/colour or a name that already exists (ignoring case).
class CreateTag implements UseCase<Future<Tag>, CreateTagParams> {
  const CreateTag(this._repository, this._ids);

  final TagRepository _repository;
  final IdGenerator _ids;

  @override
  Future<Tag> call(CreateTagParams input) async {
    _validate(input.name, input.colorValue);
    return _repository.createTag(
      Tag(
        id: _ids.newId(),
        name: input.name.trim(),
        colorValue: input.colorValue.toUpperCase(),
      ),
    );
  }
}

/// Changes a tag's name and/or colour; notes using it follow automatically.
class UpdateTag implements UseCase<Future<Tag>, Tag> {
  const UpdateTag(this._repository);

  final TagRepository _repository;

  @override
  Future<Tag> call(Tag input) async {
    _validate(input.name, input.colorValue);
    return _repository.updateTag(
      input.copyWith(
        name: input.name.trim(),
        colorValue: input.colorValue.toUpperCase(),
      ),
    );
  }
}

/// Deletes a tag and removes it from every note (the notes are kept).
class DeleteTag implements UseCase<Future<void>, String> {
  const DeleteTag(this._repository);

  final TagRepository _repository;

  @override
  Future<void> call(String input) => _repository.deleteTag(input);
}

void _validate(String name, String colorValue) {
  final errors = <String, String>{
    'name': ?TagValidators.name(name),
    'color': ?TagValidators.color(colorValue),
  };
  if (errors.isNotEmpty) {
    throw ValidationFailure(message: errors.values.first, fieldErrors: errors);
  }
}
