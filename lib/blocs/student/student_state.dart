// lib/blocs/student/student_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'dart:typed_data';

@immutable
abstract class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object?> get props => [];
}

// Başlangıç durumu
class StudentInitial extends StudentState {}

// Yükleniyor durumu
class StudentLoading extends StudentState {}

// Öğrenciler yüklendi durumu
class StudentsLoaded extends StudentState {
  final List<Student> students;

  const StudentsLoaded(this.students);

  @override
  List<Object?> get props => [students];
}

// Öğrenci seçildi durumu
class StudentSelected extends StudentState {
  final Student selectedStudent;
  final List<Student> students;

  const StudentSelected(this.selectedStudent, this.students);

  @override
  List<Object?> get props => [selectedStudent, students];
}

// Öğrenci fotoğrafı yüklendi durumu
class StudentPhotoLoaded extends StudentState {
  final int studentId;
  final Uint8List photo;

  const StudentPhotoLoaded(this.studentId, this.photo);

  @override
  List<Object?> get props => [studentId, photo];
  
  @override
  String toString() {
    return 'StudentPhotoLoaded{studentId: $studentId, photoSize: ${photo.length} bytes}';
  }
}

// Hata durumu
class StudentError extends StudentState {
  final String message;

  const StudentError(this.message);

  @override
  List<Object?> get props => [message];
}

// İşlem başarılı durumu
class StudentOperationSuccess extends StudentState {
  final String message;

  const StudentOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Bilgilendirme durumu (hata olmayan bildirim ve uyarılar için)
class StudentOperationMessage extends StudentState {
  final String message;

  const StudentOperationMessage(this.message);

  @override
  List<Object?> get props => [message];
}
