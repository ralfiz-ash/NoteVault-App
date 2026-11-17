import '../../../notes/domain/entities/note_sort.dart';
import '../../domain/entities/app_settings.dart';

/// Settings as stored: plain text values only (never Flutter types).
///
/// | key           | values                       |
/// |---------------|------------------------------|
/// | themeMode     | system / light / dark        |
/// | sortField     | updated / created / title    |
/// | sortDirection | ascending / descending       |
class AppSettingsModel {
  const AppSettingsModel({
    required this.themeMode,
    required this.sortField,
    required this.sortDirection,
  });

  static const themeModeKey = 'themeMode';
  static const sortFieldKey = 'sortField';
  static const sortDirectionKey = 'sortDirection';

  final String themeMode;
  final String sortField;
  final String sortDirection;

  factory AppSettingsModel.fromEntity(AppSettings settings) => AppSettingsModel(
    themeMode: settings.themeMode.name,
    sortField: settings.noteSort.field.name,
    sortDirection: settings.noteSort.ascending ? 'ascending' : 'descending',
  );

  factory AppSettingsModel.fromMap(Map<String, String?> map) =>
      AppSettingsModel(
        themeMode: map[themeModeKey] ?? '',
        sortField: map[sortFieldKey] ?? '',
        sortDirection: map[sortDirectionKey] ?? '',
      );

  Map<String, String> toMap() => {
    themeModeKey: themeMode,
    sortFieldKey: sortField,
    sortDirectionKey: sortDirection,
  };

  /// Missing, unknown or malformed values fall back to the defaults, so a
  /// bad stored value can never break the app.
  AppSettings toEntity() {
    const defaults = AppSettings();
    return AppSettings(
      themeMode: ThemeModePreference.values.firstWhere(
        (v) => v.name == themeMode,
        orElse: () => defaults.themeMode,
      ),
      noteSort: NoteSort(
        field: NoteSortField.values.firstWhere(
          (v) => v.name == sortField,
          orElse: () => defaults.noteSort.field,
        ),
        ascending: switch (sortDirection) {
          'ascending' => true,
          'descending' => false,
          _ => defaults.noteSort.ascending,
        },
      ),
    );
  }
}
