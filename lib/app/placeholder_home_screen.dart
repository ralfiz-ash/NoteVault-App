import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/providers/auth_controller.dart';
import '../features/auth/presentation/providers/auth_state_provider.dart';
import '../features/auth/presentation/widgets/auth_error_snack_bar.dart';
import '../features/auth/presentation/state/auth_state.dart';
import '../features/notes/presentation/providers/notes_provider.dart';
import '../features/settings/presentation/providers/settings_provider.dart';
import '../features/sync/domain/entities/connectivity_status.dart';
import '../features/sync/presentation/providers/connection_status_provider.dart';

/// Temporary start screen. Shows that the core providers resolve and update
/// (a developer check, not a product screen). Replaced by the real notes
/// screen in a later phase.
class PlaceholderHomeScreen extends ConsumerWidget {
  const PlaceholderHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Side effect only: tell the user when the network state changes.
    ref.listen(connectionStatusProvider, (previous, next) {
      final was = previous?.value;
      final now = next.value;
      if (was == null || now == null || was == now) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(now.isConnected ? 'Back online' : 'You are offline'),
        ),
      );
    });

    ref.listen(authControllerProvider, (_, next) {
      if (next case AsyncError(:final error)) showAuthError(context, error);
    });

    final auth = ref.watch(authStateProvider);
    final signingOut = ref.watch(authControllerProvider).isLoading;
    final notes = ref.watch(notesProvider);
    final connection = ref.watch(connectionStatusProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NoteVault'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: signingOut
                ? null
                : () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Foundation ready'),
          const SizedBox(height: 16),
          _StatusTile(
            label: 'Session',
            value: switch (auth) {
              AsyncData(value: Authenticated(:final user)) =>
                'Signed in as ${user.email ?? user.displayName ?? user.uid}',
              AsyncData(value: Unauthenticated()) => 'Signed out',
              AsyncError() => 'Unavailable',
              _ => 'Checking…',
            },
          ),
          _StatusTile(
            label: 'Notes',
            value: switch (notes) {
              AsyncData(:final value) when value.isEmpty => 'No notes yet',
              AsyncData(:final value) => '${value.length} notes',
              AsyncError() => 'Could not load notes',
              _ => 'Loading…',
            },
            action: notes.hasError
                ? TextButton(
                    onPressed: () => ref.invalidate(notesProvider),
                    child: const Text('Retry'),
                  )
                : null,
          ),
          _StatusTile(
            label: 'Network',
            value: switch (connection) {
              AsyncData(value: ConnectivityStatus.connected) => 'Connected',
              AsyncData(value: ConnectivityStatus.disconnected) => 'Offline',
              AsyncData(value: ConnectivityStatus.unknown) => 'Unknown',
              AsyncError() => 'Unknown',
              _ => 'Checking…',
            },
          ),
          _StatusTile(label: 'Theme', value: settings.themeMode.name),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.label, required this.value, this.action});

  final String label;
  final String value;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value),
      trailing: action,
    );
  }
}
