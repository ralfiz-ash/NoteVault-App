import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/core/database/app_database.dart';

/// A fresh in-memory SQLite database, closed when the test ends. Never touches
/// the app's real database file.
AppDatabase createTestDatabase() {
  final db = AppDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return db;
}
