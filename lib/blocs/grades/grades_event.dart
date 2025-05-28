import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/grades_model.dart';

@immutable
abstract class GradesEvent extends Equatable {
  const GradesEvent();

  @override
  List<Object?> get props => [];
}

class LoadGradesByCourseClass extends GradesEvent {
  final int? courseClassId;
  final int semester;

  const LoadGradesByCourseClass({
    this.courseClassId,
    this.semester = 1,
  });

  @override
  List<Object?> get props => [courseClassId, semester];
}

class LoadGradesBySemester extends GradesEvent {
  final int semester;

  const LoadGradesBySemester({required this.semester});

  @override
  List<Object?> get props => [semester];
}

class UpdateGrade extends GradesEvent {
  final int gradeId;
  final Grade grade;

  const UpdateGrade({
    required this.gradeId,
    required this.grade,
  });

  @override
  List<Object?> get props => [gradeId, grade];
}

class CreateGrade extends GradesEvent {
  final Grade grade;

  const CreateGrade({required this.grade});

  @override
  List<Object?> get props => [grade];
}

class DeleteGrade extends GradesEvent {
  final int gradeId;

  const DeleteGrade({required this.gradeId});

  @override
  List<Object?> get props => [gradeId];
}

class UploadExcelGrades extends GradesEvent {
  final File excelFile;

  const UploadExcelGrades({required this.excelFile});

  @override
  List<Object?> get props => [excelFile];
}

class SetSelectedCourseClass extends GradesEvent {
  final int? courseClassId;

  const SetSelectedCourseClass({required this.courseClassId});

  @override
  List<Object?> get props => [courseClassId];
}

class SetSelectedSemester extends GradesEvent {
  final int semester;

  const SetSelectedSemester({required this.semester});

  @override
  List<Object?> get props => [semester];
}
