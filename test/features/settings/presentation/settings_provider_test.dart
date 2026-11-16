import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notevalult/features/settings/domain/entities/app_settings.dart';
import 'package:notevalult/features/settings/presentation/providers/settings_provider.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  test('defaults: system theme, newest edit first', () {
    final settings = createContainer().read(settingsProvider);
    expect(settings.themeMode, ThemeModePreference.system);
    expect(settings.sortOrder, NoteSortOrder.updatedNewest);
  });

  test('setThemeMode and setSortOrder update only their field', () {
    final container = createContainer();
    final notifier = container.read(settingsProvider.notifier);

    notifier.setThemeMode(ThemeModePreference.dark);
    expect(
      container.read(settingsProvider).themeMode,
      ThemeModePreference.dark,
    );
    expect(
      container.read(settingsProvider).sortOrder,
      NoteSortOrder.updatedNewest,
    );

    notifier.setSortOrder(NoteSortOrder.titleAscending);
    expect(
      container.read(settingsProvider).sortOrder,
      NoteSortOrder.titleAscending,
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
      ..setSortOrder(NoteSortOrder.createdNewest) // not a theme change
      ..setThemeMode(ThemeModePreference.dark);

    expect(seen, [ThemeModePreference.light, ThemeModePreference.dark]);
  });
}
