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
/// Schema changes go through [migration] and bump [schemaVersion]. Future
/// sync columns (for example a sync state or tombstone) are added by a
/// migration in the sync phase.
@DriftDatabase(tables: [Notes, Folders, Tags, NoteTags])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      // SQLite ignores foreign keys unless enabled per connection.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
