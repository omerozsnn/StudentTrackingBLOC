import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/courses_model.dart';
import 'dart:io';

@immutable
abstract class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object?> get props => [];
}

// Tüm dersleri yükleme olayı
class LoadCourses extends CourseEvent {}

// Sayfalama ile dersleri yükleme olayı
class LoadCoursesWithPagination extends CourseEvent {
  final int page;
  final int limit;

  const LoadCoursesWithPagination({
    required this.page,
    required this.limit,
  });

  @override
  List<Object?> get props => [page, limit];
}

// Dropdown için dersleri yükleme olayı
class LoadCoursesForDropdown extends CourseEvent {
  const LoadCoursesForDropdown();
}

// Ders arama olayı
class SearchCourses extends CourseEvent {
  final String query;

  const SearchCourses(this.query);

  @override
  List<Object?> get props => [query];
}

// Ders seçme olayı
class SelectCourse extends CourseEvent {
  final Course? course;

  const SelectCourse(this.course);

  @override
  List<Object?> get props => [course];
}

// Ders ekleme olayı
class AddCourse extends CourseEvent {
  final Course course;

  const AddCourse(this.course);

  @override
  List<Object?> get props => [course];
}

// Ders güncelleme olayı
class UpdateCourse extends CourseEvent {
  final Course course;

  const UpdateCourse(this.course);

  @override
  List<Object?> get props => [course];
}

// Ders silme olayı
class DeleteCourse extends CourseEvent {
  final int courseId;

  const DeleteCourse(this.courseId);

  @override
  List<Object?> get props => [courseId];
}

// Excel'den ders yükleme olayı
class UploadCourseExcel extends CourseEvent {
  final File file;

  const UploadCourseExcel(this.file);

  @override
  List<Object?> get props => [file];
}

// Yükleme durumu olayı
class CourseLoadingEvent extends CourseEvent {} 