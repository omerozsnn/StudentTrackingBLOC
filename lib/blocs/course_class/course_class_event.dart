import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/course_classes_model.dart';

@immutable
abstract class CourseClassEvent extends Equatable {
  const CourseClassEvent();

  @override
  List<Object?> get props => [];
}

// Tüm ders-sınıf atamalarını yükleme olayı
class LoadCourseClasses extends CourseClassEvent {}

// Sınıf ID'sine göre ders atamalarını yükleme olayı
class LoadCourseClassesByClassId extends CourseClassEvent {
  final int classId;

  const LoadCourseClassesByClassId(this.classId);

  @override
  List<Object?> get props => [classId];
}

// Ders-sınıf ataması seçme olayı
class SelectCourseClass extends CourseClassEvent {
  final CourseClass? courseClass;

  const SelectCourseClass(this.courseClass);

  @override
  List<Object?> get props => [courseClass];
}

// Ders-sınıf ataması ekleme olayı
class AddCourseClass extends CourseClassEvent {
  final CourseClass courseClass;

  const AddCourseClass(this.courseClass);

  @override
  List<Object?> get props => [courseClass];
}

// Ders-sınıf ataması güncelleme olayı
class UpdateCourseClass extends CourseClassEvent {
  final CourseClass courseClass;

  const UpdateCourseClass(this.courseClass);

  @override
  List<Object?> get props => [courseClass];
}

// Ders-sınıf ataması silme olayı
class DeleteCourseClass extends CourseClassEvent {
  final int courseClassId;

  const DeleteCourseClass(this.courseClassId);

  @override
  List<Object?> get props => [courseClassId];
}

// Yükleme durumu olayı
class CourseClassLoadingEvent extends CourseClassEvent {} 