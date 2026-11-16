import '../entities/tag.dart';

/// Tags are created implicitly when a note that uses them is saved. This
/// contract is for listing and removing them.
///
/// Implementations throw `Failure` types from `core/errors`.
abstract interface class TagRepository {
  Stream<List<Tag>> watchTags();

  Future<List<Tag>> getTags();

  /// Removes the tag from every note. Throws `NotFoundFailure` if missing.
  Future<void> deleteTag(String id);
}
