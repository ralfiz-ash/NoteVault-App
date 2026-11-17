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
  Future<TagModel?> getTag(String id) async {
    final row = await (_db.select(
      _db.tags,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  @override
  Future<TagModel?> findByName(String name) async {
    // The name column is NOCASE, so this matches regardless of casing.
    final row = await (_db.select(
      _db.tags,
    )..where((t) => t.name.equals(name.trim()))).getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  @override
  Future<List<String>> noteIdsWithTag(String id) async {
    final query = _db.selectOnly(_db.noteTags)
      ..addColumns([_db.noteTags.noteId])
      ..where(_db.noteTags.tagId.equals(id));
    return [
      for (final row in await query.get()) row.read(_db.noteTags.noteId)!,
    ];
  }

  @override
  Future<void> bumpNoteVersions(String tagId) => _db.customUpdate(
    'UPDATE notes SET version = version + 1 WHERE id IN '
    '(SELECT note_id FROM note_tags WHERE tag_id = ?)',
    variables: [Variable.withString(tagId)],
    updates: {_db.notes},
  );

  @override
  Future<void> insertTag(TagModel tag) => _db
      .into(_db.tags)
      .insert(
        TagsCompanion(
          id: Value(tag.id),
          name: Value(tag.name),
          color: Value(tag.colorValue),
        ),
      );

  @override
  Future<bool> updateTag(TagModel tag) async {
    final changed =
        await (_db.update(_db.tags)..where((t) => t.id.equals(tag.id))).write(
          TagsCompanion(name: Value(tag.name), color: Value(tag.colorValue)),
        );
    return changed > 0;
  }

  @override
  Future<bool> deleteTag(String id) {
    return _db.transaction(() async {
      // Unlink first in a tracked statement (one statement, not one per
      // note), so watchers of notes refresh; ON DELETE CASCADE would do it
      // silently.
      await (_db.delete(_db.noteTags)..where((t) => t.tagId.equals(id))).go();
      final removed = await (_db.delete(
        _db.tags,
      )..where((t) => t.id.equals(id))).go();
      return removed > 0;
    });
  }

  TagModel _toModel(TagRow row) =>
      TagModel(id: row.id, name: row.name, colorValue: row.color);
}
