import '../../../../core/errors/failure.dart';
import '../../../tags/domain/validation/tag_validators.dart';
import '../entities/note_draft.dart';

/// Rules for note input, shared by the editor (field messages) and the use
/// cases (safety net). Each method returns a message, or `null` when valid.
abstract final class NoteValidators {
  static const maxTitleLength = 200;
  static const maxTagLength = TagValidators.maxNameLength;
  static const maxTags = 20;

  static String? title(String? value) {
    final title = value?.trim() ?? '';
    if (title.isEmpty) return 'Title is required';
    if (title.length > maxTitleLength) {
      return 'Title must be at most $maxTitleLength characters';
    }
    return null;
  }

  /// A single tag being added (same rule as the tags feature). Content may
  /// be empty, so it has no rule.
  static String? tag(String? value) => TagValidators.name(value);

  static String? tagCount(List<String> tags) =>
      tags.length > maxTags ? 'A note can have at most $maxTags tags' : null;

  /// Throws [ValidationFailure] if [draft] (already normalized) is invalid.
  static void check(NoteDraft draft) {
    final tagError = [
      tagCount(draft.tags),
      ...draft.tags.map(tag),
    ].nonNulls.firstOrNull;
    final errors = <String, String>{
      'title': ?title(draft.title),
      'tags': ?tagError,
    };
    if (errors.isNotEmpty) {
      throw ValidationFailure(
        message: errors.values.first,
        fieldErrors: errors,
      );
    }
  }
}
