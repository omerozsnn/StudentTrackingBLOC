class Teacher {
  final int id;
  final String teacherName;
  final String? teacherImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Teacher({
    required this.id,
    required this.teacherName,
    this.teacherImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'],
      teacherName: json['teacher_name'],
      teacherImage: json['teacher_image'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacher_name': teacherName,
      'teacher_image': teacherImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
