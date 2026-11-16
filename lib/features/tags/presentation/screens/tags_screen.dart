import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/confirm_dialog.dart';
import '../../../../core/presentation/failure_snack_bar.dart';
import '../../../../core/presentation/tag_chip.dart';
import '../../domain/entities/tag.dart';
import '../providers/tags_provider.dart';
import '../widgets/tag_editor_dialog.dart';

/// Lists every tag (with colour and note count); create, edit (name and
/// colour) and delete tags.
class TagsScreen extends ConsumerWidget {
  const TagsScreen({super.key});

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final result = await showTagEditorDialog(context);
    if (result == null) return;
    await ref
        .read(tagActionsProvider.notifier)
        .create(name: result.name, colorValue: result.colorValue);
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Tag tag) async {
    final result = await showTagEditorDialog(
      context,
      initialName: tag.name,
      initialColor: tag.colorValue,
    );
    if (result == null) return;
    await ref
        .read(tagActionsProvider.notifier)
        .edit(tag.copyWith(name: result.name, colorValue: result.colorValue));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Tag tag) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete tag?',
      message:
          '"${tag.name}" will be removed from all notes. The notes are kept.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (confirmed) await ref.read(tagActionsProvider.notifier).delete(tag.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(tagActionsProvider, (_, next) {
      if (next case AsyncError(:final error)) {
        showFailureSnackBar(context, 'Unable to save tag', error);
      }
    });
    final tags = ref.watch(tagsProvider);
    final counts = ref.watch(tagNoteCountsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tags')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New tag'),
      ),
      body: switch (tags) {
        AsyncValue(:final value?) when value.isEmpty => const Center(
          child: Text('No tags yet'),
        ),
        AsyncValue(:final value?) => ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            for (final tag in value)
              ListTile(
                key: ValueKey(tag.id),
                leading: CircleAvatar(
                  radius: 10,
                  backgroundColor: tagColor(tag.colorValue),
                ),
                title: TagChip(
                  label: tag.name,
                  colorValue: tag.colorValue,
                ).alignLeft(),
                subtitle: Text(
                  _notesLabel(counts[tag.name.toLowerCase()] ?? 0),
                ),
                onTap: () => _edit(context, ref, tag),
                trailing: IconButton(
                  tooltip: 'Delete ${tag.name}',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(context, ref, tag),
                ),
              ),
          ],
        ),
        AsyncError() => const Center(child: Text('Unable to load tags.')),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

String _notesLabel(int count) => count == 1 ? '1 note' : '$count notes';

extension on Widget {
  Widget alignLeft() => Align(alignment: Alignment.centerLeft, child: this);
}
