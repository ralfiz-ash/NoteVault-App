import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/presentation/content_width.dart';
import '../../../../core/presentation/info_snack_bar.dart';
import '../../../../core/presentation/failure_snack_bar.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/note_draft.dart';
import '../../domain/validation/note_validators.dart';
import '../providers/create_note_controller.dart';
import '../providers/note_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/update_note_controller.dart';
import '../widgets/folder_picker.dart';
import '../widgets/tags_input.dart';

/// Create (no [noteId]) or edit a note.
///
/// All editing state (text controllers, folder, tags, the saved baseline)
/// lives in this screen's State and disappears with it; the notes list is not
/// rebuilt while typing. "Unsaved changes" means the current values differ
/// from the baseline: the empty draft for a new note, or the note as loaded
/// for an edit (so loading it does not count as a change).
class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({this.noteId, super.key});

  final String? noteId;

  bool get isNew => noteId == null;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _content = TextEditingController();
  String? _folderId;
  List<String> _tags = const [];

  /// What "no changes" looks like. `null` until the note being edited loads.
  NoteDraft? _baseline;
  Note? _original;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.isNew) {
      _baseline = const NoteDraft();
    } else {
      // Fill the form once, when the note first arrives (later updates of
      // the note do not overwrite what the user is typing).
      ref.listenManual(noteProvider(widget.noteId!), (_, next) {
        if (_original != null || !mounted) return;
        if (next case AsyncData(:final value)) {
          _load(value);
          if (_initialized) setState(() {});
        }
      }, fireImmediately: true);
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  void _load(Note note) {
    _original = note;
    final draft = NoteDraft.fromNote(note);
    _baseline = draft;
    _title.text = draft.title;
    _content.text = draft.content;
    _folderId = draft.folderId;
    _tags = draft.tags;
  }

  NoteDraft get _draft => NoteDraft(
    title: _title.text,
    content: _content.text,
    folderId: _folderId,
    tags: _tags,
  );

  bool get _hasChanges {
    final baseline = _baseline;
    return baseline != null && _draft.normalized() != baseline.normalized();
  }

  void _changed() => setState(() {});

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final draft = _draft;

    if (widget.isNew) {
      final created = await ref
          .read(createNoteControllerProvider.notifier)
          .create(draft);
      if (created == null || !mounted) return;
      setState(() => _baseline = draft); // saved: nothing to warn about
      showInfoSnackBar(context, 'Note created');
      context.pushReplacement(AppRoutes.note(created.id));
    } else {
      final original = _original;
      if (original == null) return;
      final saved = await ref
          .read(updateNoteControllerProvider.notifier)
          .save(original, draft);
      if (saved == null || !mounted) return;
      setState(() => _baseline = draft);
      showInfoSnackBar(context, 'Changes saved');
      context.pop();
    }
  }

  Future<void> _confirmLeave() async {
    final choice = await showDialog<_LeaveChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved changes'),
        content: const Text(
          'You have unsaved changes. Do you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_LeaveChoice.stay),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_LeaveChoice.discard),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(_LeaveChoice.save),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    switch (choice) {
      case _LeaveChoice.discard:
        setState(() => _baseline = _draft); // allow the pop below
        Navigator.of(context).pop();
      case _LeaveChoice.save:
        await _save(); // leaves on success, stays (with data) on failure
      case _LeaveChoice.stay || null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final saveProvider = widget.isNew
        ? createNoteControllerProvider
        : updateNoteControllerProvider;
    ref.listen(saveProvider, (_, next) {
      if (next case AsyncError(:final error)) {
        showFailureSnackBar(
          context,
          widget.isNew ? 'Unable to create note' : 'Unable to update note',
          error,
        );
      }
    });
    final saving = ref.watch(saveProvider).isLoading;

    Widget? unavailable;
    if (!widget.isNew) {
      switch (ref.watch(noteProvider(widget.noteId!))) {
        case AsyncError(:final error) when _original == null:
          unavailable = Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error is NotFoundFailure
                      ? 'This note no longer exists.'
                      : 'Unable to load this note.',
                ),
                if (error is! NotFoundFailure) ...[
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => ref.invalidate(notesProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ],
            ),
          );
        case AsyncLoading() when _original == null:
          unavailable = const Center(child: CircularProgressIndicator());
        default:
      }
    }

    final hasChanges = _hasChanges;
    return PopScope(
      canPop: !hasChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isNew ? 'New note' : 'Edit note'),
          actions: [
            if (unavailable == null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: saving
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : TextButton(
                        onPressed: widget.isNew || hasChanges ? _save : null,
                        child: const Text('Save'),
                      ),
              ),
          ],
        ),
        body:
            unavailable ??
            ContentWidth(
              child: Form(
                key: _formKey,
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    TextFormField(
                      key: const Key('note-title'),
                      controller: _title,
                      enabled: !saving,
                      autofocus: widget.isNew,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      validator: NoteValidators.title,
                      onChanged: (_) => _changed(),
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FolderPicker(
                      folderId: _folderId,
                      enabled: !saving,
                      onChanged: (id) => setState(() => _folderId = id),
                    ),
                    const SizedBox(height: 16),
                    TagsInput(
                      tags: _tags,
                      enabled: !saving,
                      onChanged: (tags) => setState(() => _tags = tags),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('note-content'),
                      controller: _content,
                      enabled: !saving,
                      minLines: 8,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => _changed(),
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
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

enum _LeaveChoice { stay, discard, save }
