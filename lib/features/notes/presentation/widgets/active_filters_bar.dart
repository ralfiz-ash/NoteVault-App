import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/tag_chip.dart';
import '../../../folders/presentation/providers/folders_provider.dart';
import '../../../tags/presentation/providers/tags_provider.dart';
import '../../domain/entities/note_query.dart';
import '../providers/notes_filter_provider.dart';

/// The active folder/tag filters as removable chips, plus "Clear all".
/// Hidden when no folder or tag filter is set.
class ActiveFiltersBar extends ConsumerWidget {
  const ActiveFiltersBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(notesFilterControllerProvider);
    if (!filter.isActive) return const SizedBox.shrink();
    final controller = ref.read(notesFilterControllerProvider.notifier);
    final folderNames = ref.watch(folderNamesProvider);
    final tag = filter.tagId == null
        ? null
        : ref
              .watch(tagsProvider)
              .value
              ?.where((t) => t.id == filter.tagId)
              .firstOrNull;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                switch (filter.folder) {
                  AnyFolder() => const SizedBox.shrink(),
                  NoFolder() => InputChip(
                    avatar: const Icon(Icons.folder_off_outlined, size: 16),
                    label: const Text('No folder'),
                    onDeleted: () => controller.setFolder(const AnyFolder()),
                    deleteButtonTooltipMessage: 'Remove folder filter',
                  ),
                  InFolder(:final folderId) => InputChip(
                    avatar: const Icon(Icons.folder_outlined, size: 16),
                    label: Text(folderNames[folderId] ?? 'Folder'),
                    onDeleted: () => controller.setFolder(const AnyFolder()),
                    deleteButtonTooltipMessage: 'Remove folder filter',
                  ),
                },
                if (tag != null)
                  TagChip(
                    label: tag.name,
                    colorValue: tag.colorValue,
                    onDeleted: () => controller.setTag(null),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: controller.clear,
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
  }
}
