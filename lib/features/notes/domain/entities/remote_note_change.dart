import 'note.dart';

enum RemoteChangeType { added, modified, removed }

/// One change to a note in the cloud, as seen by this device.
class RemoteNoteChange {
  RemoteNoteChange.upsert(this.type, Note this.note, {this.folderName})
    : noteId = note.id;

  const RemoteNoteChange.removed(this.noteId)
    : type = RemoteChangeType.removed,
      note = null,
      folderName = null;

  final RemoteChangeType type;
  final String noteId;

  /// The cloud note (null when removed).
  final Note? note;

  /// Name of the note's folder, so this device can create it if missing.
  final String? folderName;
}
