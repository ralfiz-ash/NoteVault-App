import 'package:drift/drift.dart';

import 'tables/folders.dart';
import 'tables/notes.dart';
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
@DriftDatabase(tables: [Notes, Folders, Tags, NoteTags])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// 1: notes, folders, tags, note_tags. 2: tags.color.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Existing tags get the column's default colour.
        await m.addColumn(tags, tags.color);
      }
    },
    beforeOpen: (details) async {
      // SQLite ignores foreign keys unless enabled per connection.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
