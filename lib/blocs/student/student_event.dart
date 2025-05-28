// lib/blocs/student/student_event.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'dart:io';

@immutable
abstract class StudentEvent extends Equatable {
  const StudentEvent();

  @override
  List<Object?> get props => [];
}

// Öğrencileri yükleme olayı
class LoadStudents extends StudentEvent {}

// Bir sınıfın öğrencilerini yükleme olayı
class LoadStudentsByClass extends StudentEvent {
  final String className;

  const LoadStudentsByClass(this.className);

  @override
  List<Object?> get props => [className];
}

// Öğrenci arama olayı
class SearchStudents extends StudentEvent {
  final String query;

  const SearchStudents(this.query);

  @override
  List<Object?> get props => [query];
}

// Öğrenci seçme olayı
class SelectStudent extends StudentEvent {
  final int studentId;

  const SelectStudent(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

// Öğrenci detaylarını yükleme olayı
class LoadStudentDetails extends StudentEvent {
  final int studentId;

  const LoadStudentDetails(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

// Öğrenci silme olayı
class DeleteStudent extends StudentEvent {
  final int studentId;

  const DeleteStudent(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

// Öğrenci fotoğrafı yükleme olayı
class UploadStudentPhoto extends StudentEvent {
  final int studentId;
  final File photoFile;

  const UploadStudentPhoto(this.studentId, this.photoFile);

  @override
  List<Object?> get props => [studentId, photoFile];
}

// Öğrenci fotoğrafını alma olayı
class GetStudentPhoto extends StudentEvent {
  final int studentId;

  const GetStudentPhoto(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

// Öğrenci ekleme olayı
class AddStudent extends StudentEvent {
  final Map<String, dynamic> studentData;
  final File? imageFile;

  const AddStudent(this.studentData, {this.imageFile});

  @override
  List<Object?> get props => [studentData, imageFile];
}

// Öğrenci güncelleme olayı
class UpdateStudent extends StudentEvent {
  final int studentId;
  final Map<String, dynamic> updateData;
  final File? imageFile;

  const UpdateStudent(this.studentId, this.updateData, {this.imageFile});

  @override
  List<Object?> get props => [studentId, updateData, imageFile];
}

// Excel'den öğrenci içe aktarma olayı
class ImportStudentsFromExcel extends StudentEvent {
  final File excelFile;

  const ImportStudentsFromExcel(this.excelFile);

  @override
  List<Object?> get props => [excelFile];
}

// Excel'den öğrenci güncelleme olayı
class UpdateStudentsFromExcel extends StudentEvent {
  final File excelFile;

  const UpdateStudentsFromExcel(this.excelFile);

  @override
  List<Object?> get props => [excelFile];
}

class StudentLoadingEvent extends StudentEvent {
  @override
  List<Object?> get props => [];
}
