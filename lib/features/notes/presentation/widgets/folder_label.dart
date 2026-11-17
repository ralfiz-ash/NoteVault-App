import 'package:flutter/material.dart';

class FolderLabel extends StatelessWidget {
  const FolderLabel({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.folder_outlined,
          size: 16,
          color: theme.colorScheme.tertiary,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}
