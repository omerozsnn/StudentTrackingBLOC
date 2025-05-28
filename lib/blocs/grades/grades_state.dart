import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/grades_model.dart';

@immutable
abstract class GradesState extends Equatable {
  const GradesState();

  @override
  List<Object?> get props => [];
}

class GradesInitial extends GradesState {}

class GradesLoading extends GradesState {}

class GradesLoaded extends GradesState {
  final List<Grade> grades;

  const GradesLoaded(this.grades);

  @override
  List<Object?> get props => [grades];
}

class GradeUpdated extends GradesState {
  final Grade grade;

  const GradeUpdated(this.grade);

  @override
  List<Object?> get props => [grade];
}

class GradesError extends GradesState {
  final String message;

  const GradesError(this.message);

  @override
  List<Object?> get props => [message];
}

class GradeOperationSuccess extends GradesState {
  final String message;

  const GradeOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ExcelUploadSuccess extends GradesState {
  final String message;

  const ExcelUploadSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
