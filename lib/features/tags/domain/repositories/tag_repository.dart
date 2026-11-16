import '../entities/tag.dart';

/// Tags are independent: they are created explicitly here or implicitly when
/// a note uses a new name, and only removed by [deleteTag].
///
/// Implementations throw `Failure` types from `core/errors`.
abstract interface class TagRepository {
  Stream<List<Tag>> watchTags();

  Future<List<Tag>> getTags();

  /// Throws `ValidationFailure` if a tag with the same name (ignoring case)
  /// exists.
  Future<Tag> createTag(Tag tag);

  /// Renames and/or recolours. Throws `NotFoundFailure` if missing and
  /// `ValidationFailure` if the new name belongs to another tag.
  Future<Tag> updateTag(Tag tag);

  /// Removes the tag from every note. Throws `NotFoundFailure` if missing.
  Future<void> deleteTag(String id);
}
