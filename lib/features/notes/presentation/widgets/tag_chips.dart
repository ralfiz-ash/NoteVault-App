import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/tag_chip.dart';
import '../../../tags/domain/entities/tag_colors.dart';
import '../../../tags/presentation/providers/tags_provider.dart';

/// A note's tags, each in its own colour (looked up from the tags list, the
/// single source of tag colours). [onRemove] adds a remove button.
class TagChips extends ConsumerWidget {
  const TagChips({
    required this.tags,
    this.dense = false,
    this.onRemove,
    super.key,
  });

  final List<String> tags;
  final bool dense;
  final ValueChanged<String>? onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final byName = ref.watch(tagsByNameProvider);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final name in tags)
          TagChip(
            label: byName[name.toLowerCase()]?.name ?? name,
            colorValue:
                byName[name.toLowerCase()]?.colorValue ??
                TagColors.defaultValue,
            dense: dense,
            onDeleted: onRemove == null ? null : () => onRemove!(name),
          ),
      ],
    );
  }
}
