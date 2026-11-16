import 'package:flutter/material.dart';

import '../../../../core/presentation/tag_chip.dart';
import '../../domain/entities/tag_colors.dart';

/// Grid of the preset tag colours; the selected one shows a check mark.
class TagColorPicker extends StatelessWidget {
  const TagColorPicker({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.onSurface;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final value in TagColors.palette)
          Semantics(
            button: true,
            selected: value == selected.toUpperCase(),
            label: 'Colour $value',
            child: InkResponse(
              key: ValueKey('tag-color-$value'),
              onTap: () => onChanged(value),
              radius: 22,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: tagColor(value),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: value == selected.toUpperCase()
                        ? outline
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: value == selected.toUpperCase()
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}
