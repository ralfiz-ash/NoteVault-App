import 'package:drift/drift.dart';

@DataClassName('TagRow')
class Tags extends Table {
  TextColumn get id => text()();

  /// Unique ignoring case, so "Work" and "work" are the same tag.
  TextColumn get name =>
      text().customConstraint('NOT NULL UNIQUE COLLATE NOCASE')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
