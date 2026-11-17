import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/presentation/confirm_dialog.dart';
import '../../../../core/presentation/failure_snack_bar.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../folders/presentation/providers/folders_provider.dart';
import '../../domain/entities/note.dart';
import '../providers/delete_note_controller.dart';
import '../providers/notes_provider.dart';
import '../providers/notes_filter_provider.dart';
import '../../domain/entities/note_query.dart';
import '../providers/visible_notes_provider.dart';
import '../widgets/active_filters_bar.dart';
import '../widgets/note_sort_sheet.dart';
import '../widgets/notes_drawer.dart';
import '../widgets/notes_search_field.dart';
import '../widgets/note_card.dart';

class NotesListScreen extends ConsumerWidget {
  const NotesListScreen({super.key});

  Future<bool> _confirmDelete(BuildContext context, Note note) =>
      showConfirmDialog(
        context,
        title: 'Delete note?',
        message: '"${note.title}" will be deleted. This cannot be undone.',
        confirmLabel: 'Delete',
        destructive: true,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Deletes (from here or from the note screen) report failures here; the
    // note has already reappeared in the list (rollback).
    ref.listen(deleteNoteControllerProvider, (_, next) {
      if (next case AsyncError(:final error)) {
        showFailureSnackBar(context, 'Unable to delete note', error);
      }
    });
    ref.listen(authControllerProvider, (_, next) {
      if (next case AsyncError(:final error) when error is! CancelledFailure) {
        showFailureSnackBar(context, 'Unable to sign out', error);
      }
    });

    final notes = ref.watch(filteredNotesProvider);
    final folderNames = ref.watch(folderNamesProvider);

    return Scaffold(
      drawer: const NotesDrawer(),
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            tooltip: 'Sort',
            icon: const Icon(Icons.sort),
            onPressed: () => showNoteSortSheet(context),
          ),
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.newNote),
        icon: const Icon(Icons.add),
        label: const Text('New note'),
      ),
      body: Column(
        children: [
          const NotesSearchField(),
          const ActiveFiltersBar(),
          Expanded(
            child: switch (notes) {
              AsyncError(:final error) => _ErrorView(
                error: error,
                onRetry: () => ref.invalidate(notesProvider),
              ),
              AsyncValue(:final value?) when value.isEmpty =>
                const _EmptyView(),
              AsyncValue(:final value?) => ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 96),
                itemCount: value.length,
                itemBuilder: (context, index) {
                  final note = value[index];
                  return Dismissible(
                    key: ValueKey(note.id),
                    direction: DismissDirection.endToStart,
                    background: const _DeleteBackground(),
                    confirmDismiss: (_) => _confirmDelete(context, note),
                    onDismissed: (_) => ref
                        .read(deleteNoteControllerProvider.notifier)
                        .delete(note.id),
                    child: NoteCard(
                      note: note,
                      folderName: folderNames[note.folderId],
                      onTap: () => context.push(AppRoutes.note(note.id)),
                    ),
                  );
                },
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}

/// Tells "you have no notes" apart from "nothing matches the filters".
class _EmptyView extends ConsumerWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hasNotes = ref.watch(
      visibleNotesProvider.select((n) => n.value?.isNotEmpty ?? false),
    );
    final query = ref.watch(noteQueryProvider);

    final (title, message) = !hasNotes
        ? ('No notes yet', 'Tap "New note" to write your first one.')
        : ('No notes found', _noMatchMessage(query));

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasNotes ? Icons.search_off : Icons.sticky_note_2_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (hasNotes && query.folder is! AnyFolder ||
                hasNotes && query.tagName != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () =>
                    ref.read(notesFilterControllerProvider.notifier).clear(),
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _noMatchMessage(NoteQuery query) {
  final onlySearch =
      query.hasSearch && query.folder is AnyFolder && query.tagName == null;
  if (onlySearch) return 'No notes match "${query.search}".';
  if (!query.hasSearch && query.tagName == null) {
    return query.folder is NoFolder
        ? 'Every note is in a folder.'
        : 'No notes in this folder.';
  }
  if (!query.hasSearch && query.folder is AnyFolder) {
    return 'No notes with this tag.';
  }
  return query.hasSearch
      ? 'No notes match "${query.search}" with the current filters.'
      : 'No notes match the current filters.';
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Unable to load notes.', style: theme.textTheme.titleMedium),
            if (error is Failure) ...[
              const SizedBox(height: 8),
              Text((error as Failure).message, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      color: colors.error,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(Icons.delete_outline, color: colors.onError),
    );
  }
}
