import 'package:equatable/equatable.dart';

class TeacherFeedback extends Equatable {
  final int id;
  final int gorusId;
  final int ogrenciId;
  final String gorusMetni;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TeacherFeedback({
    required this.id,
    required this.gorusId,
    required this.ogrenciId,
    required this.gorusMetni,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props =>
      [id, gorusId, ogrenciId, gorusMetni, createdAt, updatedAt];

  factory TeacherFeedback.fromJson(Map<String, dynamic> json) {
    return TeacherFeedback(
      id: json['id'],
      gorusId: json['gorus_id'],
      ogrenciId: json['ogrenci_id'],
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
      'gorus_id': gorusId,
      'ogrenci_id': ogrenciId,
      'gorus_metni': gorusMetni,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  TeacherFeedback copyWith({
    int? id,
    int? gorusId,
    int? ogrenciId,
    String? gorusMetni,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeacherFeedback(
      id: id ?? this.id,
      gorusId: gorusId ?? this.gorusId,
      ogrenciId: ogrenciId ?? this.ogrenciId,
      gorusMetni: gorusMetni ?? this.gorusMetni,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
