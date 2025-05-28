import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';

@immutable
abstract class ClassEvent extends Equatable {
  const ClassEvent();

  @override
  List<Object?> get props => [];
}

class LoadClasses extends ClassEvent {}

class AddClass extends ClassEvent {
  final Classes classData;

  const AddClass(this.classData);

  @override
  List<Object?> get props => [classData];
}

class UpdateClass extends ClassEvent {
  final Classes classData;

  const UpdateClass(this.classData);

  @override
  List<Object?> get props => [classData];
}

class DeleteClass extends ClassEvent {
  final int classId;

  const DeleteClass(this.classId);

  @override
  List<Object?> get props => [classId];
}

class LoadClassesForDropdown extends ClassEvent {
  final String? selectedClassName;

  const LoadClassesForDropdown({this.selectedClassName});

  @override
  List<Object?> get props => [selectedClassName];
}

class LoadClassesForScroll extends ClassEvent {
  final int offset;
  final int limit;

  const LoadClassesForScroll({this.offset = 0, this.limit = 50});

  @override
  List<Object?> get props => [offset, limit];
}

class LoadClassesWithPagination extends ClassEvent {
  final int page;
  final int limit;

  const LoadClassesWithPagination({this.page = 1, this.limit = 10});

  @override
  List<Object?> get props => [page, limit];
}

class LoadClassById extends ClassEvent {
  final int classId;

  const LoadClassById(this.classId);

  @override
  List<Object?> get props => [classId];
}

class LoadClassesByName extends ClassEvent {
  final String className;

  const LoadClassesByName(this.className);

  @override
  List<Object?> get props => [className];
}

class UploadClassExcel extends ClassEvent {
  final File filePath;

  const UploadClassExcel(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class SelectClass extends ClassEvent {
  final Classes? selectedClass;

  const SelectClass(this.selectedClass);

  @override
  List<Object?> get props => [selectedClass];
}

// Sınıf seçimini temizleme olayı
class UnselectClass extends ClassEvent {
  @override
  List<Object?> get props => [];
}
