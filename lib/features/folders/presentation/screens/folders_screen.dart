import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/confirm_dialog.dart';
import '../../../../core/presentation/content_width.dart';
import '../../../../core/presentation/info_snack_bar.dart';
import '../../../../core/presentation/failure_snack_bar.dart';
import '../../domain/entities/folder.dart';
import '../../domain/usecases/create_folder.dart';
import '../providers/folders_provider.dart';

/// Lists folders with their note counts; create, rename and delete them.
class FoldersScreen extends ConsumerWidget {
  const FoldersScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final name = await showFolderNameDialog(context, title: 'New folder');
    if (name == null) return;
    final created = await ref.read(folderActionsProvider.notifier).create(name);
    if (created != null && context.mounted) {
      showInfoSnackBar(context, 'Folder "${created.name}" created');
    }
  }

  Future<void> _rename(BuildContext context, WidgetRef ref, Folder f) async {
    final name = await showFolderNameDialog(
      context,
      title: 'Rename folder',
      initialName: f.name,
    );
    if (name == null) return;
    final renamed = await ref
        .read(folderActionsProvider.notifier)
        .rename(f, name);
    if (renamed != null && context.mounted) {
      showInfoSnackBar(context, 'Folder renamed to "${renamed.name}"');
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Folder f) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete folder?',
      message:
          '"${f.name}" will be deleted. Its notes are kept and move to '
          '"No folder".',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) return;
    final deleted = await ref.read(folderActionsProvider.notifier).delete(f.id);
    if (deleted && context.mounted) {
      showInfoSnackBar(context, 'Folder deleted. Its notes are kept.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(folderActionsProvider, (_, next) {
      if (next case AsyncError(:final error)) {
        showFailureSnackBar(context, 'Unable to save folder', error);
      }
    });
    final folders = ref.watch(foldersProvider);
    final counts = ref.watch(folderNoteCountsProvider);
    final busy = ref.watch(folderActionsProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
        bottom: busy ? const _Progress() : null,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: busy ? null : () => _create(context, ref),
        icon: const Icon(Icons.create_new_folder_outlined),
        label: const Text('New folder'),
      ),
      body: ContentWidth(
        child: switch (folders) {
          AsyncValue(:final value?) => ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              if (value.isEmpty)
                const _Hint(
                  icon: Icons.folder_outlined,
                  text:
                      'No folders yet. Tap "New folder" to create one, then pick '
                      'it when editing a note.',
                ),
              for (final folder in value)
                ListTile(
                  key: ValueKey(folder.id),
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(folder.name),
                  subtitle: Text(_notesLabel(counts[folder.id] ?? 0)),
                  onTap: () => _rename(context, ref, folder),
                  trailing: PopupMenuButton<String>(
                    tooltip: 'Folder actions',
                    onSelected: (action) => action == 'rename'
                        ? _rename(context, ref, folder)
                        : _delete(context, ref, folder),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'rename', child: Text('Rename')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              ListTile(
                leading: const Icon(Icons.folder_off_outlined),
                title: const Text('No folder'),
                subtitle: Text(_notesLabel(counts[null] ?? 0)),
              ),
            ],
          ),
          AsyncError() => _LoadError(
            message: 'Unable to load folders.',
            onRetry: () => ref.invalidate(foldersProvider),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

String _notesLabel(int count) => count == 1 ? '1 note' : '$count notes';

class _Progress extends StatelessWidget implements PreferredSizeWidget {
  const _Progress();

  @override
  Size get preferredSize => const Size.fromHeight(2);

  @override
  Widget build(BuildContext context) =>
      const LinearProgressIndicator(minHeight: 2);
}

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message),
        const SizedBox(height: 12),
        FilledButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}

/// Asks for a folder name (validated). Returns `null` when cancelled.
Future<String?> showFolderNameDialog(
  BuildContext context, {
  required String title,
  String? initialName,
}) => showDialog<String>(
  context: context,
  builder: (_) => _FolderNameDialog(title: title, initialName: initialName),
);

class _FolderNameDialog extends StatefulWidget {
  const _FolderNameDialog({required this.title, this.initialName});

  final String title;
  final String? initialName;

  @override
  State<_FolderNameDialog> createState() => _FolderNameDialogState();
}

class _FolderNameDialogState extends State<_FolderNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_name.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          key: const Key('folder-name'),
          controller: _name,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Folder name'),
          validator: CreateFolder.validateName,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
