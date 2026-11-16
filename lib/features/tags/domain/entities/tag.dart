import 'tag_colors.dart';

/// An independent, reusable tag. Its name is unique ignoring case.
class Tag {
  const Tag({
    required this.id,
    required this.name,
    this.colorValue = TagColors.defaultValue,
  });

  final String id;
  final String name;

  /// "#RRGGBB" (see [TagColors]); never a UI type.
  final String colorValue;

  Tag copyWith({String? name, String? colorValue}) => Tag(
    id: id,
    name: name ?? this.name,
    colorValue: colorValue ?? this.colorValue,
  );

  @override
  bool operator ==(Object other) =>
      other is Tag &&
      other.id == id &&
      other.name == name &&
      other.colorValue == colorValue;

  @override
  int get hashCode => Object.hash(id, name, colorValue);

  @override
  String toString() => 'Tag($id, "$name", $colorValue)';
}
