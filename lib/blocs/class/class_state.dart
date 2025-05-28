import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';
import 'dart:typed_data';

@immutable
abstract class ClassState extends Equatable {
  final List<Classes> classes;
  final Classes? selectedClass;

  const ClassState({
    this.classes = const [],
    this.selectedClass,
  });

  @override
  List<Object?> get props => [classes, selectedClass];
}

// Başlangıç durumu
class ClassInitial extends ClassState {
  const ClassInitial() : super(classes: const []);
}

class ClassLoading extends ClassState {
  const ClassLoading({
    List<Classes> classes = const [],
    Classes? selectedClass,
  }) : super(classes: classes, selectedClass: selectedClass);
}

// Sınıflar yüklendi durumu
class ClassesLoaded extends ClassState {
  const ClassesLoaded(List<Classes> classes, {Classes? selectedClass})
      : super(classes: classes, selectedClass: selectedClass);
}

// Sınıf yuklendi durumu
class ClassLoaded extends ClassState {
  final Classes classData;

  const ClassLoaded(this.classData,
      {List<Classes> classes = const [], Classes? selectedClass})
      : super(classes: classes, selectedClass: selectedClass);

  @override
  List<Object?> get props => [classData, ...super.props];
}

// Sınıf seçildi durumu
class ClassSelected extends ClassState {
  const ClassSelected({
    required List<Classes> classes,
    required Classes selectedClass,
  });

  @override
  List<Object?> get props => [selectedClass, classes];
}

class ClassAdded extends ClassState {
  final Classes classData;

  const ClassAdded(this.classData);

  @override
  List<Object?> get props => [classData];
}

// Hata durumu
class ClassError extends ClassState {
  final String message;

  const ClassError(this.message);

  @override
  List<Object?> get props => [message];
}

class ClassOperationSuccess extends ClassState {
  final String message;

  const ClassOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
