import '../models/tag_model.dart';

/// Local persistence boundary for tags. Tags used by notes are also created
/// by the notes data source when a note is saved.
abstract interface class TagLocalDataSource {
  Stream<List<TagModel>> watchTags();

  Future<List<TagModel>> getTags();

  Future<TagModel?> getTag(String id);

  /// Case-insensitive lookup.
  Future<TagModel?> findByName(String name);

  Future<void> insertTag(TagModel tag);

  /// Ids of the notes that use the tag.
  Future<List<String>> noteIdsWithTag(String id);

  /// Returns `false` when there is no such tag.
  Future<bool> updateTag(TagModel tag);

  /// Returns `false` when there is no such tag.
  Future<bool> deleteTag(String id);
}
