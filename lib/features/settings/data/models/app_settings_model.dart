import '../../../notes/domain/entities/note_sort.dart';
import '../../domain/entities/app_settings.dart';

class AppSettingsModel {
  const AppSettingsModel({
    required this.themeMode,
    required this.sortField,
    required this.sortAscending,
  });

  /// Stored by enum name so values survive enum reordering.
  final String themeMode;
  final String sortField;
  final bool sortAscending;

  factory AppSettingsModel.fromEntity(AppSettings settings) => AppSettingsModel(
    themeMode: settings.themeMode.name,
    sortField: settings.noteSort.field.name,
    sortAscending: settings.noteSort.ascending,
  );

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) =>
      AppSettingsModel(
        themeMode: map['themeMode'] as String? ?? '',
        sortField: map['sortField'] as String? ?? '',
        sortAscending: map['sortAscending'] as bool? ?? false,
      );

  Map<String, dynamic> toMap() => {
    'themeMode': themeMode,
    'sortField': sortField,
    'sortAscending': sortAscending,
  };

  /// Unknown or missing values fall back to the defaults.
  AppSettings toEntity() => AppSettings(
    themeMode: ThemeModePreference.values.firstWhere(
      (v) => v.name == themeMode,
      orElse: () => ThemeModePreference.system,
    ),
    noteSort: NoteSort(
      field: NoteSortField.values.firstWhere(
        (v) => v.name == sortField,
        orElse: () => NoteSort.defaultSort.field,
      ),
      ascending: sortAscending,
    ),
  );
}
