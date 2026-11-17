import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/app_settings_model.dart';
import 'settings_local_data_source.dart';

/// Settings in the `preferences` table of the user's own database.
class DriftSettingsLocalDataSource implements SettingsLocalDataSource {
  DriftSettingsLocalDataSource({required AppDatabase database})
    : _db = database;

  final AppDatabase _db;

  @override
  Future<AppSettingsModel?> read() async {
    final rows = await _db.select(_db.preferences).get();
    if (rows.isEmpty) return null;
    return AppSettingsModel.fromMap({for (final r in rows) r.key: r.value});
  }

  @override
  Future<void> write(AppSettingsModel settings) => _db.batch((batch) {
    batch.insertAllOnConflictUpdate(_db.preferences, [
      for (final entry in settings.toMap().entries)
        PreferencesCompanion(key: Value(entry.key), value: Value(entry.value)),
    ]);
  });
}
