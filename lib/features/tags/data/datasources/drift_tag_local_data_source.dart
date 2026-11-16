import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/tag_model.dart';
import 'tag_local_data_source.dart';

class DriftTagLocalDataSource implements TagLocalDataSource {
  DriftTagLocalDataSource({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  SimpleSelectStatement<$TagsTable, TagRow> _ordered() => _db.select(_db.tags)
    ..orderBy([
      (t) => OrderingTerm.asc(t.name.lower()),
      (t) => OrderingTerm.asc(t.id),
    ]);

  @override
  Stream<List<TagModel>> watchTags() =>
      _ordered().watch().map((rows) => rows.map(_toModel).toList());

  @override
  Future<List<TagModel>> getTags() async =>
      (await _ordered().get()).map(_toModel).toList();

  @override
  Future<bool> deleteTag(String id) async {
    // note_tags links are removed by ON DELETE CASCADE.
    final removed = await (_db.delete(
      _db.tags,
    )..where((t) => t.id.equals(id))).go();
    return removed > 0;
  }

  TagModel _toModel(TagRow row) => TagModel(id: row.id, name: row.name);
}
