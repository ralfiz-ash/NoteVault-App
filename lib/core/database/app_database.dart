import 'package:drift/drift.dart';

import 'tables/folders.dart';
import 'tables/notes.dart';
import 'tables/sync_queue.dart';
import 'tables/tags.dart';

part 'app_database.g.dart';

/// The single local SQLite database (source of truth for notes, folders and
/// tags). Only data sources in the data layer touch this class; domain and
/// presentation never see it.
///
/// The executor is injected: production uses a file on disk (see
/// `lib/app/di/database_providers.dart`), tests pass an in-memory database.
///
/// Schema changes go through [migration] and bump [schemaVersion]; existing
/// data is kept. Future sync columns are added the same way.
@DriftDatabase(tables: [Notes, Folders, Tags, NoteTags, SyncQueue])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// 1: notes, folders, tags, note_tags. 2: tags.color. 3: sync_queue.
  /// 4: notes.version, sync_queue.entity_version.
  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Existing tags get the column's default colour.
        await m.addColumn(tags, tags.color);
      }
      if (from < 3) {
        await m.createTable(syncQueue);
        // Notes created before sync existed have never been uploaded: queue
        // them all once so they reach the cloud.
        await customStatement(
          'INSERT INTO sync_queue (entity_type, entity_id, operation, status, '
          'version, retry_count, created_at, updated_at) '
          "SELECT 'note', id, 'create', 'pending', 1, 0, updated_at, "
          'updated_at FROM notes',
        );
      }
      if (from < 4) {
        // Existing notes start at revision 1 (the column default).
        await m.addColumn(notes, notes.version);
        if (from >= 3) await m.addColumn(syncQueue, syncQueue.entityVersion);
      }
    },
    beforeOpen: (details) async {
      // SQLite ignores foreign keys unless enabled per connection.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
