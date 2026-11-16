import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/presentation/confirm_dialog.dart';
import '../../../../core/presentation/date_formatting.dart';
import '../../../folders/presentation/providers/folders_provider.dart';
import '../../domain/entities/note.dart';
import '../providers/delete_note_controller.dart';
import '../providers/note_provider.dart';
import '../widgets/folder_label.dart';
import '../widgets/tag_chips.dart';

/// Shows one note, looked up by id with `noteProvider(id)` (so it stays up to
/// date after edits and notices when the note is deleted).
class NoteViewScreen extends ConsumerWidget {
  const NoteViewScreen({required this.noteId, super.key});

  final String noteId;

  Future<void> _delete(BuildContext context, WidgetRef ref, Note note) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete note?',
      message: '"${note.title}" will be deleted. This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    // Optimistic: leave now; the list hides the note immediately and shows
    // it again with an error if the delete fails.
    unawaited(ref.read(deleteNoteControllerProvider.notifier).delete(note.id));
    context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(noteProvider(noteId));

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (note case AsyncData(:final value)) ...[
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(AppRoutes.editNote(noteId)),
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _delete(context, ref, value),
            ),
          ],
        ],
      ),
      body: switch (note) {
        AsyncData(:final value) => _NoteDetails(note: value),
        AsyncError(:final error) => _Unavailable(
          message: error is NotFoundFailure
              ? 'This note no longer exists.'
              : 'Unable to load this note.',
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _NoteDetails extends ConsumerWidget {
  const _NoteDetails({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final folderName = ref.watch(folderNamesProvider)[note.folderId];
    final meta = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        SelectableText(note.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        if (folderName != null) ...[
          FolderLabel(name: folderName),
          const SizedBox(height: 8),
        ],
        if (note.tags.isNotEmpty) ...[
          TagChips(tags: note.tags),
          const SizedBox(height: 8),
        ],
        Text('Created ${formatDateTime(context, note.createdAt)}', style: meta),
        Text('Edited ${formatDateTime(context, note.updatedAt)}', style: meta),
        const Divider(height: 32),
        if (note.content.isEmpty)
          Text('No content', style: meta)
        else
          SelectableText(note.content, style: theme.textTheme.bodyLarge),
      ],
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Back to notes'),
          ),
        ],
      ),
    );
  }
}
