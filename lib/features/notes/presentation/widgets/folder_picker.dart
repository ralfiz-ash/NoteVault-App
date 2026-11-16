import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/failure_snack_bar.dart';
import '../../../folders/domain/entities/folder.dart';
import '../../../folders/domain/usecases/create_folder.dart';
import '../../../folders/presentation/providers/folders_provider.dart';

/// Chooses the note's folder (or none). "New folder…" creates one on the spot;
/// renaming/deleting folders belongs to the folders feature.
class FolderPicker extends ConsumerWidget {
  const FolderPicker({
    required this.folderId,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final String? folderId;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  static const _newFolder = '\u0000new-folder';

  Future<void> _createFolder(BuildContext context, WidgetRef ref) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _NewFolderDialog(),
    );
    if (name == null || !context.mounted) return;
    try {
      final folder = await ref.read(createFolderProvider)(name);
      onChanged(folder.id);
    } on Object catch (error) {
      if (context.mounted) {
        showFailureSnackBar(context, 'Unable to create folder', error);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = ref.watch(foldersProvider).value ?? const <Folder>[];
    final known = folders.any((f) => f.id == folderId);

    return DropdownButtonFormField<String?>(
      key: ValueKey('folder-$folderId-${folders.length}'),
      initialValue: folderId,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Folder',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.folder_outlined),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('No folder')),
        for (final folder in folders)
          DropdownMenuItem(value: folder.id, child: Text(folder.name)),
        // Folders still loading: keep the current value valid.
        if (folderId != null && !known)
          DropdownMenuItem(value: folderId, child: const Text('…')),
        const DropdownMenuItem(
          value: _newFolder,
          child: Row(
            children: [
              Icon(Icons.create_new_folder_outlined, size: 18),
              SizedBox(width: 8),
              Text('New folder…'),
            ],
          ),
        ),
      ],
      onChanged: enabled
          ? (value) {
              if (value == _newFolder) {
                _createFolder(context, ref);
              } else {
                onChanged(value);
              }
            }
          : null,
    );
  }
}

class _NewFolderDialog extends StatefulWidget {
  const _NewFolderDialog();

  @override
  State<_NewFolderDialog> createState() => _NewFolderDialogState();
}

class _NewFolderDialogState extends State<_NewFolderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

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
      title: const Text('New folder'),
      content: Form(
        key: _formKey,
        child: TextFormField(
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
        TextButton(onPressed: _submit, child: const Text('Create')),
      ],
    );
  }
}
