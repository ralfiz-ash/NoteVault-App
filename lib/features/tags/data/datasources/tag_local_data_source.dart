import '../models/tag_model.dart';

/// Local persistence boundary for tags. Tags are created through notes (see
/// the notes data source); this only lists and deletes them.
abstract interface class TagLocalDataSource {
  Stream<List<TagModel>> watchTags();

  Future<List<TagModel>> getTags();

  /// Returns `false` when there is no such tag.
  Future<bool> deleteTag(String id);
}
