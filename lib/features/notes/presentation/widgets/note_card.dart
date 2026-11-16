import 'package:flutter/material.dart';

import '../../../../core/presentation/date_formatting.dart';
import '../../domain/entities/note.dart';
import 'folder_label.dart';
import 'tag_chips.dart';

/// One note in the list: title, content preview, folder, tags, update date.
class NoteCard extends StatelessWidget {
  const NoteCard({
    required this.note,
    required this.folderName,
    required this.onTap,
    super.key,
  });

  final Note note;
  final String? folderName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = note.content.trim().replaceAll(RegExp(r'\s+'), ' ');
    // Full width even inside Dismissible (its Stack gives loose constraints).
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                if (preview.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (folderName != null || note.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (folderName != null) FolderLabel(name: folderName!),
                      if (note.tags.isNotEmpty)
                        TagChips(tags: note.tags, dense: true),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  'Edited ${formatDateTime(context, note.updatedAt)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
