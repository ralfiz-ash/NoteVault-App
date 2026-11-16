import 'package:flutter/material.dart';

/// Read-only tags, e.g. on note cards and the note screen.
class TagChips extends StatelessWidget {
  const TagChips({required this.tags, this.dense = false, super.key});

  final List<String> tags;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final tag in tags)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: dense ? 8 : 10,
              vertical: dense ? 2 : 4,
            ),
            decoration: BoxDecoration(
              color: colors.secondary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '#$tag',
              style: dense
                  ? Theme.of(context).textTheme.labelSmall
                  : Theme.of(context).textTheme.labelMedium,
            ),
          ),
      ],
    );
  }
}
