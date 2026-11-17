import '../../../notes/domain/entities/note_sort.dart';

/// Theme preference. Deliberately not Flutter's `ThemeMode`: the domain stays
/// free of Flutter, and the presentation layer maps this to `ThemeMode`.
enum ThemeModePreference { system, light, dark }

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeModePreference.system,
    this.noteSort = NoteSort.defaultSort,
  });

  final ThemeModePreference themeMode;

  /// The notes list order (field + direction).
  final NoteSort noteSort;

  AppSettings copyWith({ThemeModePreference? themeMode, NoteSort? noteSort}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      noteSort: noteSort ?? this.noteSort,
    );
  }
}
