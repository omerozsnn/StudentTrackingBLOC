import 'package:equatable/equatable.dart';

class TeacherFeedbackOption extends Equatable {
  final int id;
  final String gorusMetni;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TeacherFeedbackOption({
    required this.id,
    required this.gorusMetni,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, gorusMetni, createdAt, updatedAt];

  factory TeacherFeedbackOption.fromJson(Map<String, dynamic> json) {
    return TeacherFeedbackOption(
      id: json['id'],
      gorusMetni: json['gorus_metni'] ?? '',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gorus_metni': gorusMetni,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  TeacherFeedbackOption copyWith({
    int? id,
    String? gorusMetni,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeacherFeedbackOption(
      id: id ?? this.id,
      gorusMetni: gorusMetni ?? this.gorusMetni,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
