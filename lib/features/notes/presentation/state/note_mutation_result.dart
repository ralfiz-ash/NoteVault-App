enum NoteMutationKind { created, updated, deleted }

/// What the last successful note mutation did. Lets a screen react once
/// (e.g. show "Saved" or navigate back) with `ref.listen`.
class NoteMutationResult {
  const NoteMutationResult(this.kind, this.noteId);

  final NoteMutationKind kind;
  final String noteId;

  @override
  bool operator ==(Object other) =>
      other is NoteMutationResult &&
      other.kind == kind &&
      other.noteId == noteId;

  @override
  int get hashCode => Object.hash(kind, noteId);

  @override
  String toString() => 'NoteMutationResult($kind, $noteId)';
}
