import '../../domain/entities/folder.dart';

class FolderModel {
  const FolderModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;

  factory FolderModel.fromEntity(Folder folder) => FolderModel(
    id: folder.id,
    name: folder.name,
    createdAt: folder.createdAt,
  );

  factory FolderModel.fromMap(Map<String, dynamic> map) => FolderModel(
    id: map['id'] as String,
    name: map['name'] as String,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  Folder toEntity() => Folder(id: id, name: name, createdAt: createdAt);
}
