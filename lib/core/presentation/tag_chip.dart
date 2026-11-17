import 'package:flutter/material.dart';

/// Turns a stored "#RRGGBB" tag colour into a Flutter [Color]. The only place
/// the string becomes a UI colour; invalid values fall back to grey.
Color tagColor(String colorValue) {
  final hex = colorValue.replaceFirst('#', '');
  final value = int.tryParse(hex, radix: 16);
  if (hex.length != 6 || value == null) return const Color(0xFF9E9E9E);
  return Color(0xFF000000 | value);
}

/// A tag shown with its colour: tinted background, coloured border and dot.
/// Readable in light and dark themes because the text uses the theme colour.
class TagChip extends StatelessWidget {
  const TagChip({
    required this.label,
    required this.colorValue,
    this.dense = false,
    this.onTap,
    this.onDeleted,
    this.leadingIcon,
    super.key,
  });

  final String label;
  final String colorValue;
  final bool dense;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = tagColor(colorValue);
    final textStyle = dense
        ? theme.textTheme.labelSmall
        : theme.textTheme.labelMedium;

    final chip = Container(
      padding: EdgeInsets.fromLTRB(
        dense ? 6 : 8,
        dense ? 2 : 4,
        onDeleted == null ? (dense ? 8 : 10) : 2,
        dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        border: Border.all(color: color.withValues(alpha: 0.8)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingIcon != null)
            Icon(leadingIcon, size: dense ? 12 : 14, color: color)
          else
            Container(
              width: dense ? 6 : 8,
              height: dense ? 6 : 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          SizedBox(width: dense ? 4 : 6),
          Flexible(
            child: Text(
              label,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onDeleted != null)
            Tooltip(
              message: 'Remove $label',
              child: InkResponse(
                onTap: onDeleted,
                radius: 20,
                // 40 x 40 touch target around a small icon.
                child: const SizedBox.square(
                  dimension: 40,
                  child: Icon(Icons.close, size: 16),
                ),
              ),
            ),
        ],
      ),
    );

    if (onTap == null) return chip;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: chip,
    );
  }
}
