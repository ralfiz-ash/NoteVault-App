import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/features/notes/domain/entities/note_sort.dart';
import 'package:notevalult/features/settings/domain/entities/app_settings.dart';
import 'package:notevalult/features/settings/presentation/providers/settings_provider.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  test('defaults: system theme, newest edit first', () {
    final settings = createContainer().read(settingsProvider);
    expect(settings.themeMode, ThemeModePreference.system);
    expect(settings.noteSort, NoteSort.defaultSort);
  });

  test('setThemeMode and setSortOrder update only their field', () {
    final container = createContainer();
    final notifier = container.read(settingsProvider.notifier);

    notifier.setThemeMode(ThemeModePreference.dark);
    expect(
      container.read(settingsProvider).themeMode,
      ThemeModePreference.dark,
    );
    expect(container.read(settingsProvider).noteSort, NoteSort.defaultSort);

    notifier.setNoteSort(
      const NoteSort(field: NoteSortField.title, ascending: true),
    );
    expect(
      container.read(settingsProvider).noteSort,
      const NoteSort(field: NoteSortField.title, ascending: true),
    );
    expect(
      container.read(settingsProvider).themeMode,
      ThemeModePreference.dark,
    );
  });

  test('listeners are notified of changes', () {
    final container = createContainer();
    final seen = <ThemeModePreference>[];
    container.listen(
      settingsProvider.select((s) => s.themeMode),
      (_, next) => seen.add(next),
    );

    container.read(settingsProvider.notifier)
      ..setThemeMode(ThemeModePreference.light)
      ..setNoteSort(
        const NoteSort(field: NoteSortField.created),
      ) // not a theme change
      ..setThemeMode(ThemeModePreference.dark);

    expect(seen, [ThemeModePreference.light, ThemeModePreference.dark]);
  });
}
