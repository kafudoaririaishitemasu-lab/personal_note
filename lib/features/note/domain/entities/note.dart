class Note {
  final String id;
  String title;
  String content;
  bool isLocked;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.isLocked = false,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "content": content,
    "isLocked": isLocked,
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json["id"],
    title: json["title"],
    content: json["content"],
    isLocked: json["isLocked"] ?? false,
  );

  Note copyWith({
    String? id,
    String? title,
    String? content,
    bool? isLocked,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}

