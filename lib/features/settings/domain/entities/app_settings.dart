import '../../../notes/domain/entities/note_sort.dart';

/// Theme preference. Deliberately not Flutter's `ThemeMode`: the domain stays
/// free of Flutter, and the presentation layer maps this to `ThemeMode`.
enum ThemeModePreference { system, light, dark }

/// One user's preferences. Defaults: follow the system theme, notes sorted
/// by last edit, newest first.
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeModePreference.system,
    this.noteSort = NoteSort.defaultSort,
  });

  final ThemeModePreference themeMode;

  /// The notes list order (field + direction).
  final NoteSort noteSort;

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeMode == themeMode &&
      other.noteSort == noteSort;

  @override
  int get hashCode => Object.hash(themeMode, noteSort);

  AppSettings copyWith({ThemeModePreference? themeMode, NoteSort? noteSort}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      noteSort: noteSort ?? this.noteSort,
    );
  }
}
