import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/note_sort.dart';

Future<void> showNoteSortSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _NoteSortSheet(),
    );

/// Sort field + direction; changes apply immediately (the list re-sorts via
/// its derived provider).
class _NoteSortSheet extends ConsumerWidget {
  const _NoteSortSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(settingsProvider.select((s) => s.noteSort));
    void set(NoteSort value) =>
        ref.read(settingsProvider.notifier).setNoteSort(value);

    final (ascLabel, descLabel) = switch (sort.field) {
      NoteSortField.title => ('A to Z', 'Z to A'),
      _ => ('Oldest first', 'Newest first'),
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Sort by', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SegmentedButton<NoteSortField>(
              segments: const [
                ButtonSegment(
                  value: NoteSortField.updated,
                  label: Text('Edited'),
                ),
                ButtonSegment(
                  value: NoteSortField.created,
                  label: Text('Created'),
                ),
                ButtonSegment(value: NoteSortField.title, label: Text('Title')),
              ],
              selected: {sort.field},
              onSelectionChanged: (s) => set(sort.copyWith(field: s.single)),
            ),
            const SizedBox(height: 16),
            Text('Order', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  icon: const Icon(Icons.arrow_downward),
                  label: Text(descLabel),
                ),
                ButtonSegment(
                  value: true,
                  icon: const Icon(Icons.arrow_upward),
                  label: Text(ascLabel),
                ),
              ],
              selected: {sort.ascending},
              onSelectionChanged: (s) =>
                  set(sort.copyWith(ascending: s.single)),
            ),
          ],
        ),
      ),
    );
  }
}
