import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/utils/id_generator.dart';
import '../models/note_model.dart';
import 'note_local_data_source.dart';
import 'note_row_mapper.dart';

/// SQLite (Drift) implementation of [NoteLocalDataSource].
class DriftNoteLocalDataSource implements NoteLocalDataSource {
  DriftNoteLocalDataSource({
    required AppDatabase database,
    required IdGenerator idGenerator,
  }) : _db = database,
       _ids = idGenerator;

  final AppDatabase _db;
  final IdGenerator _ids;

  @override
  Stream<List<NoteModel>> watchNotes() {
    return _db
        .customSelect(
          'SELECT 1',
          readsFrom: {_db.notes, _db.noteTags, _db.tags},
        )
        .watch()
        .asyncMap((_) => getNotes());
  }

  @override
  Future<List<NoteModel>> getNotes() async {
    final rows =
        await (_db.select(_db.notes)..orderBy([
              (t) => OrderingTerm.desc(t.updatedAt),
              (t) => OrderingTerm.asc(t.id),
            ]))
            .get();
    final tagsByNote = await _tagNamesByNote();
    return [
      for (final row in rows) row.toModel(tagsByNote[row.id] ?? const []),
    ];
  }

  @override
  Future<NoteModel?> getNote(String id) async {
    final row = await (_db.select(
      _db.notes,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final tagsByNote = await _tagNamesByNote(noteId: id);
    return row.toModel(tagsByNote[id] ?? const []);
  }

  @override
  Future<void> insertNote(NoteModel note) {
    return _db.transaction(() async {
      await _db.into(_db.notes).insert(note.toCompanion());
      await _replaceTags(note.id, note.tags);
    });
  }

  @override
  Future<bool> updateNote(NoteModel note) {
    return _db.transaction(() async {
      final changed = await (_db.update(
        _db.notes,
      )..where((t) => t.id.equals(note.id))).write(note.toCompanion());
      if (changed == 0) return false;
      await _replaceTags(note.id, note.tags);
      return true;
    });
  }

  @override
  Future<void> upsertNote(NoteModel note) {
    return _db.transaction(() async {
      await _db.into(_db.notes).insertOnConflictUpdate(note.toCompanion());
      await _replaceTags(note.id, note.tags);
    });
  }

  @override
  Future<bool> deleteNote(String id) async {
    // Links in note_tags are removed by ON DELETE CASCADE.
    final removed = await (_db.delete(
      _db.notes,
    )..where((t) => t.id.equals(id))).go();
    return removed > 0;
  }

  /// Tag names per note id, sorted by name (case-insensitive).
  Future<Map<String, List<String>>> _tagNamesByNote({String? noteId}) async {
    final query = _db.select(_db.noteTags).join([
      innerJoin(_db.tags, _db.tags.id.equalsExp(_db.noteTags.tagId)),
    ]);
    if (noteId != null) query.where(_db.noteTags.noteId.equals(noteId));
    final result = <String, List<String>>{};
    for (final row in await query.get()) {
      result
          .putIfAbsent(row.readTable(_db.noteTags).noteId, () => [])
          .add(row.readTable(_db.tags).name);
    }
    for (final names in result.values) {
      names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }
    return result;
  }

  /// Makes the note's tag links match [names], creating tags that do not
  /// exist yet. Names are trimmed and de-duplicated ignoring case.
  Future<void> _replaceTags(String noteId, List<String> names) async {
    await (_db.delete(
      _db.noteTags,
    )..where((t) => t.noteId.equals(noteId))).go();

    final seen = <String>{};
    for (final raw in names) {
      final name = raw.trim();
      if (name.isEmpty || !seen.add(name.toLowerCase())) continue;

      // The name column is NOCASE, so this matches regardless of casing.
      final existing = await (_db.select(
        _db.tags,
      )..where((t) => t.name.equals(name))).getSingleOrNull();
      final tagId = existing?.id ?? _ids.newId();
      if (existing == null) {
        await _db
            .into(_db.tags)
            .insert(TagsCompanion(id: Value(tagId), name: Value(name)));
      }
      await _db
          .into(_db.noteTags)
          .insert(
            NoteTagsCompanion(noteId: Value(noteId), tagId: Value(tagId)),
          );
    }
  }
}
