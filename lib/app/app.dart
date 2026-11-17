import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/settings/domain/entities/app_settings.dart';
import '../features/settings/presentation/providers/settings_provider.dart';
import '../features/sync/presentation/providers/sync_providers.dart';
import 'di/core_providers.dart';
import 'router/app_router.dart';

class NoteVaultApp extends ConsumerWidget {
  const NoteVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Start the sync engine for the app's lifetime. listen (not watch): its
    // state changes never rebuild the whole app.
    ref.listen(syncControllerProvider, (_, _) {});
    final router = ref.watch(appRouterProvider);
    final config = ref.watch(appConfigProvider);
    final themeMode = ref.watch(
      settingsProvider.select((settings) => settings.themeMode),
    );

    return MaterialApp.router(
      title: config.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _toThemeMode(themeMode),
      routerConfig: router,
    );
  }
}

/// Maps the domain preference to Flutter's [ThemeMode] (presentation concern).
ThemeMode _toThemeMode(ThemeModePreference preference) => switch (preference) {
  ThemeModePreference.system => ThemeMode.system,
  ThemeModePreference.light => ThemeMode.light,
  ThemeModePreference.dark => ThemeMode.dark,
};
