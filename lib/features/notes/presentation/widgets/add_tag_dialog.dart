import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/tag_chip.dart';
import '../../../tags/presentation/providers/tags_provider.dart';
import '../../domain/validation/note_validators.dart';

/// Pick an existing tag or type a new name. Returns the tag name, or `null`.
Future<String?> showAddTagDialog(BuildContext context, List<String> current) =>
    showDialog<String>(
      context: context,
      builder: (_) => _AddTagDialog(current: current),
    );

class _AddTagDialog extends ConsumerStatefulWidget {
  const _AddTagDialog({required this.current});

  final List<String> current;

  @override
  ConsumerState<_AddTagDialog> createState() => _AddTagDialogState();
}

class _AddTagDialogState extends ConsumerState<_AddTagDialog> {
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
    final used = {for (final t in widget.current) t.toLowerCase()};
    final available = [
      for (final tag in ref.watch(tagsByNameProvider).values)
        if (!used.contains(tag.name.toLowerCase())) tag,
    ];
    return AlertDialog(
      title: const Text('Add tag'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (available.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final tag in available)
                      TagChip(
                        label: tag.name,
                        colorValue: tag.colorValue,
                        leadingIcon: Icons.add,
                        onTap: () => Navigator.of(context).pop(tag.name),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                key: const Key('add-tag-name'),
                controller: _name,
                decoration: const InputDecoration(labelText: 'New tag'),
                validator: NoteValidators.tag,
                onFieldSubmitted: (_) => _submit(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}
