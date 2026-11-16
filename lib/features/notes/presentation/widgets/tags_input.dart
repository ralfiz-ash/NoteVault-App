import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/tag_chip.dart';
import '../../../tags/domain/entities/tag_colors.dart';
import '../../../tags/presentation/providers/tags_provider.dart';
import '../../domain/validation/note_validators.dart';

/// Edits a note's tags: type a tag and press enter (or comma) to add it,
/// tap x to remove it, or pick one of the existing tags suggested below.
/// Existing tags are reused (matched ignoring case), never duplicated.
class TagsInput extends ConsumerStatefulWidget {
  const TagsInput({
    required this.tags,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final List<String> tags;
  final ValueChanged<List<String>> onChanged;
  final bool enabled;

  @override
  ConsumerState<TagsInput> createState() => _TagsInputState();
}

class _TagsInputState extends ConsumerState<TagsInput> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _has(String tag) =>
      widget.tags.any((t) => t.toLowerCase() == tag.toLowerCase());

  void _add(String raw) {
    final tag = raw.replaceAll(',', '').trim();
    if (tag.isEmpty) {
      _controller.clear();
      return;
    }
    final error =
        NoteValidators.tag(tag) ??
        NoteValidators.tagCount([...widget.tags, tag]);
    setState(() => _error = error);
    if (error != null) return;
    _controller.clear();
    if (!_has(tag)) widget.onChanged([...widget.tags, tag]);
  }

  void _remove(String tag) => widget.onChanged([...widget.tags]..remove(tag));

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim().toLowerCase();
    final byName = ref.watch(tagsByNameProvider);
    final suggestions = [
      for (final tag in byName.values)
        if (!_has(tag.name) &&
            (query.isEmpty || tag.name.toLowerCase().contains(query)))
          tag,
    ].take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const Key('tag-input'),
          controller: _controller,
          enabled: widget.enabled,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Add tag',
            hintText: 'Type a tag and press enter',
            errorText: _error,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.sell_outlined),
          ),
          onChanged: (value) {
            if (value.endsWith(',')) {
              _add(value);
            } else {
              setState(() => _error = null);
            }
          },
          onSubmitted: _add,
        ),
        if (widget.tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in widget.tags)
                TagChip(
                  label: tag,
                  // New names get the default colour until edited.
                  colorValue:
                      byName[tag.toLowerCase()]?.colorValue ??
                      TagColors.defaultValue,
                  onDeleted: widget.enabled ? () => _remove(tag) : null,
                ),
            ],
          ),
        ],
        if (widget.enabled && suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in suggestions)
                TagChip(
                  label: tag.name,
                  colorValue: tag.colorValue,
                  leadingIcon: Icons.add,
                  onTap: () => _add(tag.name),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
