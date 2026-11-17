import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notes_filter_provider.dart';

/// Search box for the notes list. Every keystroke goes to the debounced
/// [NoteSearchController]; this widget does no filtering itself.
class NotesSearchField extends ConsumerStatefulWidget {
  const NotesSearchField({super.key});

  @override
  ConsumerState<NotesSearchField> createState() => _NotesSearchFieldState();
}

class _NotesSearchFieldState extends ConsumerState<NotesSearchField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    ref.read(noteSearchControllerProvider.notifier).setNow('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        key: const Key('notes-search'),
        controller: _controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search notes',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.close),
                  onPressed: _clear,
                ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
          isDense: true,
        ),
        onChanged: (text) {
          ref.read(noteSearchControllerProvider.notifier).onInput(text);
          setState(() {}); // show/hide the clear button
        },
        onSubmitted: (text) =>
            ref.read(noteSearchControllerProvider.notifier).setNow(text),
      ),
    );
  }
}
