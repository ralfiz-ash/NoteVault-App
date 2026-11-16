import '../../domain/entities/app_settings.dart';

class AppSettingsModel {
  const AppSettingsModel({required this.themeMode, required this.sortOrder});

  /// Stored by enum name so values survive enum reordering.
  final String themeMode;
  final String sortOrder;

  factory AppSettingsModel.fromEntity(AppSettings settings) =>
      AppSettingsModel(
        themeMode: settings.themeMode.name,
        sortOrder: settings.sortOrder.name,
      );

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) =>
      AppSettingsModel(
        themeMode: map['themeMode'] as String? ?? '',
        sortOrder: map['sortOrder'] as String? ?? '',
      );

  Map<String, dynamic> toMap() =>
      {'themeMode': themeMode, 'sortOrder': sortOrder};

  /// Unknown or missing values fall back to the defaults.
  AppSettings toEntity() => AppSettings(
        themeMode: ThemeModePreference.values.firstWhere(
          (v) => v.name == themeMode,
          orElse: () => ThemeModePreference.system,
        ),
        sortOrder: NoteSortOrder.values.firstWhere(
          (v) => v.name == sortOrder,
          orElse: () => NoteSortOrder.updatedNewest,
        ),
      );
}
