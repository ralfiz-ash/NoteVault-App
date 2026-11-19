import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/app_info_providers.dart';
import '../../../../app/di/core_providers.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/presentation/content_width.dart';
import '../../../notes/domain/entities/note_sort.dart';
import '../../domain/entities/app_settings.dart';
import '../providers/settings_provider.dart';

/// Theme and notes sort. Thin: shows the settings and calls the notifier;
/// saving and per-user handling live in [Settings].
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _apply(BuildContext context, Future<bool> save) async {
    final saved = await save;
    if (!saved && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Could not save this setting. It applies until the app '
              'restarts.',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(settingsProvider.notifier);
    final theme = ref.watch(themeModePreferenceProvider);
    final sort = ref.watch(noteSortSettingProvider);
    final (ascLabel, descLabel) = switch (sort.field) {
      NoteSortField.title => ('A to Z', 'Z to A'),
      _ => ('Oldest first', 'Newest first'),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const _Section('Appearance'),
            const _Label('Theme'),
            SegmentedButton<ThemeModePreference>(
              key: const Key('theme-mode'),
              segments: const [
                ButtonSegment(
                  value: ThemeModePreference.system,
                  icon: Icon(Icons.brightness_auto),
                  label: Text('System'),
                ),
                ButtonSegment(
                  value: ThemeModePreference.light,
                  icon: Icon(Icons.light_mode_outlined),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeModePreference.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                  label: Text('Dark'),
                ),
              ],
              selected: {theme},
              onSelectionChanged: (s) =>
                  _apply(context, notifier.setThemeMode(s.single)),
            ),
            const SizedBox(height: 24),
            const _Section('Notes'),
            const _Label('Sort by'),
            SegmentedButton<NoteSortField>(
              key: const Key('sort-field'),
              segments: const [
                ButtonSegment(
                  value: NoteSortField.updated,
                  label: Text('Edited'),
                ),
                ButtonSegment(
                  value: NoteSortField.created,
                  label: Text('Created'),
                ),
                ButtonSegment(value: NoteSortField.title, label: Text('Title')),
              ],
              selected: {sort.field},
              onSelectionChanged: (s) => _apply(
                context,
                notifier.setNoteSort(sort.copyWith(field: s.single)),
              ),
            ),
            const SizedBox(height: 16),
            const _Label('Order'),
            SegmentedButton<bool>(
              key: const Key('sort-direction'),
              segments: [
                ButtonSegment(
                  value: false,
                  icon: const Icon(Icons.arrow_downward),
                  label: Text(descLabel),
                ),
                ButtonSegment(
                  value: true,
                  icon: const Icon(Icons.arrow_upward),
                  label: Text(ascLabel),
                ),
              ],
              selected: {sort.ascending},
              onSelectionChanged: (s) => _apply(
                context,
                notifier.setNoteSort(sort.copyWith(ascending: s.single)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Settings are saved on this device for your account.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 32),
            const _Section('Account'),
            ListTile(
              key: const Key('delete-account-tile'),
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.delete_forever_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete account',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              subtitle: const Text(
                'Permanently delete your account and all your notes',
              ),
              onTap: () => context.push(AppRoutes.deleteAccount),
            ),
            const SizedBox(height: 32),
            const _Section('About'),
            const _AboutApp(),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      // Body text colour: the palette gold is too faint for text on cream.
      style: Theme.of(context).textTheme.titleMedium,
    ),
  );
}

/// App name and installed version (from the package metadata).
class _AboutApp extends ConsumerWidget {
  const _AboutApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final name = ref.watch(appConfigProvider.select((c) => c.appName));
    // Static metadata: nothing to show while it is read or if it is
    // unavailable (no spinner or retry needed).
    final version = ref.watch(appVersionProvider).value;
    return Column(
      key: const Key('about-app'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: textTheme.bodyLarge),
        if (version != null)
          Text(
            'Version $version',
            style: textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.labelLarge),
  );
}
