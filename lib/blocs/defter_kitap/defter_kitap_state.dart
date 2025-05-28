import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/defter_kitap_model.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';

@immutable
abstract class DefterKitapState extends Equatable {
  const DefterKitapState();

  @override
  List<Object?> get props => [];
}

// Initial state
class DefterKitapInitial extends DefterKitapState {}

// Loading state
class DefterKitapLoadingState extends DefterKitapState {}

// Dates loaded state
class DefterKitapDatesLoaded extends DefterKitapState {
  final List<String> availableDates;
  final int courseClassId;

  const DefterKitapDatesLoaded(this.availableDates, this.courseClassId);

  @override
  List<Object?> get props => [availableDates, courseClassId];
}

// Records for a date and course class loaded state
class DefterKitapRecordsLoaded extends DefterKitapState {
  final List<Map<String, dynamic>> records;
  final String date;
  final int courseClassId;
  final List<Student> students;

  const DefterKitapRecordsLoaded(
    this.records,
    this.date,
    this.courseClassId,
    this.students,
  );

  @override
  List<Object?> get props => [records, date, courseClassId, students];
}

// Error state
class DefterKitapError extends DefterKitapState {
  final String message;

  const DefterKitapError(this.message);

  @override
  List<Object?> get props => [message];
}

// Operation success state
class DefterKitapOperationSuccess extends DefterKitapState {
  final String message;
  final List<String>? updatedDates;

  const DefterKitapOperationSuccess(this.message, {this.updatedDates});

  @override
  List<Object?> get props => [message, updatedDates];
}
