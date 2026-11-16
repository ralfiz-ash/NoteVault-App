import '../../../../core/usecase/usecase.dart';
import '../entities/tag.dart';
import '../repositories/tag_repository.dart';

/// All tags (sorted by name), live. Includes tags no note uses any more:
/// tags are independent and stay available for reuse.
class ObserveTags implements UseCase<Stream<List<Tag>>, NoParams> {
  const ObserveTags(this._repository);

  final TagRepository _repository;

  @override
  Stream<List<Tag>> call(NoParams input) => _repository.watchTags();
}
