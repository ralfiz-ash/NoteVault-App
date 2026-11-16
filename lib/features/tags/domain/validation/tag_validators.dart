import '../entities/tag_colors.dart';

/// Tag input rules (one place; notes reuse [name] for tags typed in the
/// editor). Each method returns a message, or `null` when valid.
abstract final class TagValidators {
  static const maxNameLength = 40;

  static String? name(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Tag cannot be empty';
    if (name.length > maxNameLength) {
      return 'Tags must be at most $maxNameLength characters';
    }
    return null;
  }

  static String? color(String? value) =>
      TagColors.isValid(value) ? null : 'Choose a colour';
}
