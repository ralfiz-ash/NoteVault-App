/// Theme preference. Deliberately not Flutter's `ThemeMode`: the domain stays
/// free of Flutter, and the presentation layer maps this to `ThemeMode`.
enum ThemeModePreference { system, light, dark }

enum NoteSortOrder { updatedNewest, createdNewest, titleAscending }

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeModePreference.system,
    this.sortOrder = NoteSortOrder.updatedNewest,
  });

  final ThemeModePreference themeMode;
  final NoteSortOrder sortOrder;

  AppSettings copyWith({
    ThemeModePreference? themeMode,
    NoteSortOrder? sortOrder,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
