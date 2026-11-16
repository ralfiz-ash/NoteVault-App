import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/folder_model.dart';
import 'folder_local_data_source.dart';

class DriftFolderLocalDataSource implements FolderLocalDataSource {
  DriftFolderLocalDataSource({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  SimpleSelectStatement<$FoldersTable, FolderRow> _ordered() =>
      _db.select(_db.folders)..orderBy([
        (t) => OrderingTerm.asc(t.name.lower()),
        (t) => OrderingTerm.asc(t.id),
      ]);

  @override
  Stream<List<FolderModel>> watchFolders() =>
      _ordered().watch().map((rows) => rows.map(_toModel).toList());

  @override
  Future<List<FolderModel>> getFolders() async =>
      (await _ordered().get()).map(_toModel).toList();

  @override
  Future<FolderModel?> getFolder(String id) async {
    final row = await (_db.select(
      _db.folders,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toModel(row);
  }

  @override
  Future<void> insertFolder(FolderModel folder) =>
      _db.into(_db.folders).insert(_toCompanion(folder));

  @override
  Future<bool> updateFolder(FolderModel folder) async {
    final changed = await (_db.update(
      _db.folders,
    )..where((t) => t.id.equals(folder.id))).write(_toCompanion(folder));
    return changed > 0;
  }

  @override
  Future<bool> deleteFolder(String id) async {
    // notes.folder_id is ON DELETE SET NULL.
    final removed = await (_db.delete(
      _db.folders,
    )..where((t) => t.id.equals(id))).go();
    return removed > 0;
  }

  FolderModel _toModel(FolderRow row) => FolderModel(
    id: row.id,
    name: row.name,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt, isUtc: true),
  );

  FoldersCompanion _toCompanion(FolderModel model) => FoldersCompanion(
    id: Value(model.id),
    name: Value(model.name),
    createdAt: Value(model.createdAt.millisecondsSinceEpoch),
  );
}
