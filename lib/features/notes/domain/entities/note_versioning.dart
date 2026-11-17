import 'note.dart';

/// Conflict rule for notes across devices: "latest revision wins".
///
/// Given two versions of the same note (same id), the winner is the one with
/// - the higher `version` (revision counter), else
/// - the later `updatedAt` (only for two edits made from the same revision
///   on different devices), else
/// - the larger content key (a fixed tie-break so every device picks the
///   same winner).
///
/// Every device evaluates the same rule on the same data, so all of them
/// converge on the same note. Losing local edits are never silently thrown
/// away: they are kept as a separate "conflict copy" note.
abstract final class NoteVersioning {
  /// True if [a] should replace [b].
  static bool isNewer(Note a, Note b) {
    if (a.version != b.version) return a.version > b.version;
    final byTime = a.updatedAt.compareTo(b.updatedAt);
    if (byTime != 0) return byTime > 0;
    return _contentKey(a).compareTo(_contentKey(b)) > 0;
  }

  /// Same user-visible content (title, content, folder, tags).
  static bool sameContent(Note a, Note b) => _contentKey(a) == _contentKey(b);

  static String _contentKey(Note n) => [
    n.title,
    n.content,
    n.folderId ?? '',
    (n.tags.map((t) => t.toLowerCase()).toList()..sort()).join(','),
  ].join('\u0000');
}
