import '../../domain/entities/tag.dart';
import '../../domain/entities/tag_colors.dart';

class TagModel {
  const TagModel({
    required this.id,
    required this.name,
    this.colorValue = TagColors.defaultValue,
  });

  final String id;
  final String name;
  final String colorValue;

  factory TagModel.fromEntity(Tag tag) => TagModel(
    id: tag.id,
    name: tag.name,
    colorValue: TagColors.normalize(tag.colorValue),
  );

  factory TagModel.fromMap(Map<String, dynamic> map) => TagModel(
    id: map['id'] as String,
    name: map['name'] as String,
    colorValue: TagColors.normalize(map['color'] as String?),
  );

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'color': colorValue};

  /// A stored colour that is missing or not "#RRGGBB" becomes the default,
  /// so a bad value can never break the UI.
  Tag toEntity() =>
      Tag(id: id, name: name, colorValue: TagColors.normalize(colorValue));
}
