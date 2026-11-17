import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/presentation/tag_chip.dart';
import '../../../folders/presentation/providers/folders_provider.dart';
import '../../../tags/presentation/providers/tags_provider.dart';
import '../providers/notes_filter_provider.dart';
import '../../domain/entities/note_query.dart';
import '../providers/visible_notes_provider.dart';

/// Navigation for the notes list: all notes, folders (with counts), "No
/// folder", tags (coloured, with counts), and links to manage folders/tags.
class NotesDrawer extends ConsumerWidget {
  const NotesDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(notesFilterControllerProvider);
    final folders = ref.watch(foldersProvider).value ?? const [];
    final folderCounts = ref.watch(folderNoteCountsProvider);
    final tags = ref.watch(tagsProvider).value ?? const [];
    final tagCounts = ref.watch(tagNoteCountsProvider);
    final total = ref.watch(
      visibleNotesProvider.select((notes) => notes.value?.length ?? 0),
    );
    final theme = Theme.of(context);
    final controller = ref.read(notesFilterControllerProvider.notifier);

    // Folder and tag filters combine; tapping the selected one again clears
    // it.
    void selectFolder(FolderScope scope) {
      controller.setFolder(filter.folder == scope ? const AnyFolder() : scope);
      Navigator.of(context).pop();
    }

    void selectTag(String tagId) {
      controller.setTag(filter.tagId == tagId ? null : tagId);
      Navigator.of(context).pop();
    }

    Widget section(String title, VoidCallback onManage, String tooltip) =>
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
          child: Row(
            children: [
              Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
              IconButton(
                tooltip: tooltip,
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () {
                  Navigator.of(context).pop();
                  onManage();
                },
              ),
            ],
          ),
        );

    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('NoteVault', style: theme.textTheme.titleLarge),
            ),
            _CountTile(
              icon: Icons.notes,
              label: 'All notes',
              count: total,
              selected: !filter.isActive,
              onTap: () {
                controller.clear();
                Navigator.of(context).pop();
              },
            ),
            section(
              'Folders',
              () => context.push(AppRoutes.folders),
              'Manage folders',
            ),
            for (final folder in folders)
              _CountTile(
                icon: Icons.folder_outlined,
                label: folder.name,
                count: folderCounts[folder.id] ?? 0,
                selected: filter.folder == InFolder(folder.id),
                onTap: () => selectFolder(InFolder(folder.id)),
              ),
            _CountTile(
              icon: Icons.folder_off_outlined,
              label: 'No folder',
              count: folderCounts[null] ?? 0,
              selected: filter.folder == const NoFolder(),
              onTap: () => selectFolder(const NoFolder()),
            ),
            section('Tags', () => context.push(AppRoutes.tags), 'Manage tags'),
            if (tags.isEmpty)
              const ListTile(dense: true, title: Text('No tags yet')),
            for (final tag in tags)
              ListTile(
                selected: filter.tagId == tag.id,
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: TagChip(label: tag.name, colorValue: tag.colorValue),
                ),
                trailing: Text('${tagCounts[tag.name.toLowerCase()] ?? 0}'),
                onTap: () => selectTag(tag.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.icon,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(label, overflow: TextOverflow.ellipsis),
    trailing: Text('$count'),
    selected: selected,
    onTap: onTap,
  );
}
