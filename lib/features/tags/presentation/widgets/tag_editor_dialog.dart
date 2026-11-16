import 'package:flutter/material.dart';

import '../../../../core/presentation/tag_chip.dart';
import '../../domain/entities/tag_colors.dart';
import '../../domain/validation/tag_validators.dart';
import 'tag_color_picker.dart';

/// Result of [showTagEditorDialog].
class TagEditorResult {
  const TagEditorResult(this.name, this.colorValue);

  final String name;
  final String colorValue;
}

/// Name + colour form for creating or editing a tag. Returns `null` when
/// cancelled.
Future<TagEditorResult?> showTagEditorDialog(
  BuildContext context, {
  String? initialName,
  String initialColor = TagColors.defaultValue,
}) => showDialog<TagEditorResult>(
  context: context,
  builder: (_) =>
      _TagEditorDialog(initialName: initialName, initialColor: initialColor),
);

class _TagEditorDialog extends StatefulWidget {
  const _TagEditorDialog({this.initialName, required this.initialColor});

  final String? initialName;
  final String initialColor;

  @override
  State<_TagEditorDialog> createState() => _TagEditorDialogState();
}

class _TagEditorDialogState extends State<_TagEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initialName);
  late String _color = TagColors.normalize(widget.initialColor);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(TagEditorResult(_name.text.trim(), _color));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialName == null ? 'New tag' : 'Edit tag'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                key: const Key('tag-name'),
                controller: _name,
                autofocus: widget.initialName == null,
                decoration: const InputDecoration(labelText: 'Tag name'),
                validator: TagValidators.name,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              Text('Colour', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 12),
              TagColorPicker(
                selected: _color,
                onChanged: (value) => setState(() => _color = value),
              ),
              const SizedBox(height: 20),
              TagChip(
                label: _name.text.trim().isEmpty
                    ? 'Preview'
                    : _name.text.trim(),
                colorValue: _color,
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
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
