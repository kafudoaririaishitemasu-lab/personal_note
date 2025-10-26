import 'package:hive/hive.dart';

part 'note.g.dart'; // generate with build_runner

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  bool isLocked;

  @HiveField(4)
  bool isTrashed;

  @HiveField(5)
  String createdAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.isLocked = false,
    this.isTrashed = false,
    required this.createdAt
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    bool? isLocked,
    bool? isTrashed,
    String? createdAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isLocked: isLocked ?? this.isLocked,
      isTrashed: isTrashed ?? this.isTrashed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
