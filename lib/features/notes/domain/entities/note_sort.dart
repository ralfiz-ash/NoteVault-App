import 'note.dart';

enum NoteSortField { updated, created, title }

/// How the notes list is ordered: a field plus a direction. Dates are
/// compared as stored (UTC instants), titles alphabetically ignoring case.
/// Ties fall back to the id, so the order is always stable.
class NoteSort {
  const NoteSort({this.field = NoteSortField.updated, this.ascending = false});

  /// Recently edited first.
  static const defaultSort = NoteSort();

  final NoteSortField field;
  final bool ascending;

  NoteSort copyWith({NoteSortField? field, bool? ascending}) => NoteSort(
    field: field ?? this.field,
    ascending: ascending ?? this.ascending,
  );

  int compare(Note a, Note b) {
    final byField = switch (field) {
      NoteSortField.updated => a.updatedAt.compareTo(b.updatedAt),
      NoteSortField.created => a.createdAt.compareTo(b.createdAt),
      NoteSortField.title => a.title.toLowerCase().compareTo(
        b.title.toLowerCase(),
      ),
    };
    final result = byField != 0 ? byField : a.id.compareTo(b.id);
    return ascending ? result : -result;
  }

  @override
  bool operator ==(Object other) =>
      other is NoteSort && other.field == field && other.ascending == ascending;

  @override
  int get hashCode => Object.hash(field, ascending);

  @override
  String toString() => 'NoteSort(${field.name}, ${ascending ? 'asc' : 'desc'})';
}
