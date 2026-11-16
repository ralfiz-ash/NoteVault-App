import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import 'di/core_providers.dart';
import 'router/app_router.dart';

class NoteVaultApp extends ConsumerWidget {
  const NoteVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final config = ref.watch(appConfigProvider);

    return MaterialApp.router(
      title: config.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Becomes user-selectable when the settings feature is built.
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
