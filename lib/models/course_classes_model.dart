import 'courses_model.dart';
import 'classes_model.dart';

class CourseClass {
  final int id;
  final int sinifId;
  final int dersId;
  final int? egitimOgretimYiliId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Course? course;
  final Classes? classes;

  CourseClass({
    required this.id,
    required this.sinifId,
    required this.dersId,
    this.egitimOgretimYiliId,
    this.createdAt,
    this.updatedAt,
    this.course,
    this.classes,
  });

  factory CourseClass.fromJson(Map<String, dynamic> json) {
    return CourseClass(
      id: json['id'],
      sinifId: json['sinif_id'],
      dersId: json['ders_id'],
      egitimOgretimYiliId: json['egitimOgretimYiliId'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      course: json['courses'] != null ? Course.fromJson(json['courses']) : null,
      classes: json['class'] != null ? Classes.fromJson(json['class']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sinif_id': sinifId,
      'ders_id': dersId,
      'egitimOgretimYiliId': egitimOgretimYiliId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'courses': course?.toJson(),
      'class': classes?.toJson(),
    };
  }
}
