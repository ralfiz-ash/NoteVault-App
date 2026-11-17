import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/database/app_database.dart';
import 'package:notevalult/features/tags/domain/entities/tag_colors.dart';
import 'package:sqlite3/sqlite3.dart';

/// A database created by the previous app version (schema 1, no tag colour)
/// must open, keep its data and give existing tags the default colour.
void main() {
  test('schema 1 -> 3: tag colour default and existing notes queued', () async {
    final dir = Directory.systemTemp.createTempSync('notevault_migration');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/v1.sqlite');

    final raw = sqlite3.open(file.path);
    raw
      ..execute(
        'CREATE TABLE folders (id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL, '
        'created_at INTEGER NOT NULL)',
      )
      ..execute(
        'CREATE TABLE tags (id TEXT NOT NULL PRIMARY KEY, '
        'name TEXT NOT NULL UNIQUE COLLATE NOCASE)',
      )
      ..execute(
        'CREATE TABLE notes (id TEXT NOT NULL PRIMARY KEY, title TEXT NOT NULL, '
        'content TEXT NOT NULL, folder_id TEXT NULL REFERENCES folders (id) '
        'ON DELETE SET NULL, created_at INTEGER NOT NULL, '
        'updated_at INTEGER NOT NULL)',
      )
      ..execute(
        'CREATE TABLE note_tags (note_id TEXT NOT NULL REFERENCES notes (id) '
        'ON DELETE CASCADE, tag_id TEXT NOT NULL REFERENCES tags (id) '
        'ON DELETE CASCADE, PRIMARY KEY (note_id, tag_id))',
      )
      ..execute("INSERT INTO tags VALUES ('t1', 'Work')")
      ..execute("INSERT INTO notes VALUES ('n1', 'T', 'C', NULL, 1, 2)")
      ..execute("INSERT INTO note_tags VALUES ('n1', 't1')")
      ..userVersion = 1;
    raw.close();

    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final tags = await db.select(db.tags).get();
    expect(tags.single.name, 'Work');
    expect(tags.single.color, TagColors.defaultValue);
    expect((await db.select(db.notes).get()).single.title, 'T');
    expect((await db.select(db.noteTags).get()), hasLength(1));
    // Schema 3: notes from before sync existed are queued for upload.
    final queued = await db.select(db.syncQueue).get();
    expect(queued.single.entityId, 'n1');
    expect(queued.single.operation, 'create');
  });
}
