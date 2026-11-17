import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../sync/domain/entities/connectivity_status.dart';
import '../../../sync/presentation/providers/connection_status_provider.dart';
import '../../../sync/presentation/providers/sync_providers.dart';
import '../../../sync/presentation/state/sync_state.dart';

/// Offline / syncing / failed / pending indicator above the notes list.
/// Display only: it reads Riverpod state, and Retry asks the sync
/// controller. Never blocks editing.
class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline =
        ref.watch(connectionStatusProvider).value ==
        ConnectivityStatus.disconnected;
    final pending = ref.watch(
      pendingChangesProvider.select((p) => p.value?.pending ?? 0),
    );
    final sync = ref.watch(syncControllerProvider);
    final colors = Theme.of(context).colorScheme;
    String changes(int n) => n == 1 ? '1 change' : '$n changes';

    if (offline) {
      return _Banner(
        key: const Key('offline-banner'),
        icon: Icons.cloud_off_outlined,
        color: colors.tertiary,
        title: "You're offline",
        message: pending == 0
            ? 'You can keep working. Changes will sync when you are back online.'
            : '${changes(pending)} will sync when you are back online.',
      );
    }
    if (sync.phase == SyncPhase.syncing && pending > 0) {
      return _Banner(
        key: const Key('syncing-banner'),
        icon: Icons.sync,
        color: colors.primary,
        title: 'Syncing ${changes(pending)}…',
        progress: true,
      );
    }
    if (sync.phase == SyncPhase.failed && pending > 0) {
      return _Banner(
        key: const Key('sync-failed-banner'),
        icon: Icons.sync_problem_outlined,
        color: colors.error,
        title: 'Sync failed',
        message:
            '${changes(pending)} not synced yet. They are safe on this device.',
        action: TextButton(
          onPressed: () => ref.read(syncControllerProvider.notifier).syncNow(),
          child: const Text('Retry'),
        ),
      );
    }
    if (pending > 0) {
      return _Banner(
        key: const Key('pending-banner'),
        icon: Icons.cloud_upload_outlined,
        color: colors.secondary,
        title: '${changes(pending)} waiting to sync',
      );
    }
    return const SizedBox.shrink();
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.icon,
    required this.color,
    required this.title,
    this.message,
    this.action,
    this.progress = false,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? message;
  final Widget? action;
  final bool progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleSmall),
                      if (message != null)
                        Text(message!, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                ?action,
              ],
            ),
          ),
          if (progress) LinearProgressIndicator(minHeight: 2, color: color),
        ],
      ),
    );
  }
}
