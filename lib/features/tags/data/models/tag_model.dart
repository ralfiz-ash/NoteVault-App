import '../../domain/entities/tag.dart';

class TagModel {
  const TagModel({required this.id, required this.name});

  final String id;
  final String name;

  factory TagModel.fromEntity(Tag tag) => TagModel(id: tag.id, name: tag.name);

  factory TagModel.fromMap(Map<String, dynamic> map) =>
      TagModel(id: map['id'] as String, name: map['name'] as String);

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  Tag toEntity() => Tag(id: id, name: name);
}
