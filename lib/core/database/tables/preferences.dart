import 'package:drift/drift.dart';

/// The signed-in user's settings as text key/value pairs (schema version 5).
/// Lives in the user's own database file, so each account keeps its own
/// settings.
@DataClassName('PreferenceRow')
class Preferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
