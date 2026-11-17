import 'package:drift/drift.dart';

@DataClassName('TagRow')
class Tags extends Table {
  TextColumn get id => text()();

  /// Unique ignoring case, so "Work" and "work" are the same tag.
  TextColumn get name =>
      text().customConstraint('NOT NULL UNIQUE COLLATE NOCASE')();

  /// Colour as "#RRGGBB" (added in schema version 2). Tags created before
  /// that, or without a chosen colour, get the default. Must match
  /// `TagColors.defaultValue` in the tags domain.
  TextColumn get color => text().withDefault(const Constant('#BDB76B'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
