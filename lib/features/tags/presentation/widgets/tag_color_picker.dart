import 'package:flutter/material.dart';

import '../../../../core/presentation/tag_chip.dart';
import '../../domain/entities/tag_colors.dart';

/// Spoken/tooltip names for the palette (screen readers, long-press).
const _colorNames = {
  '#BDB76B': 'Olive',
  '#D4AF37': 'Gold',
  '#CE8946': 'Bronze',
  '#C0392B': 'Red',
  '#E67E22': 'Orange',
  '#F1C40F': 'Yellow',
  '#27AE60': 'Green',
  '#16A085': 'Teal',
  '#2980B9': 'Blue',
  '#8E44AD': 'Purple',
  '#D35400': 'Rust',
  '#7F8C8D': 'Grey',
};

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
          Tooltip(
            message: _colorNames[value] ?? value,
            child: Semantics(
              button: true,
              selected: value == selected.toUpperCase(),
              label: '${_colorNames[value] ?? value} colour',
              child: InkResponse(
                key: ValueKey('tag-color-$value'),
                onTap: () => onChanged(value),
                radius: 22,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 40,
                  height: 40,
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
          ),
      ],
    );
  }
}
