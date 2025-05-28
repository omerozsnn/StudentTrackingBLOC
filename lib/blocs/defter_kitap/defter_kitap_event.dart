import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/defter_kitap_model.dart';

@immutable
abstract class DefterKitapEvent extends Equatable {
  const DefterKitapEvent();

  @override
  List<Object?> get props => [];
}

// Event to load dates for a specific course class
class LoadDefterKitapDates extends DefterKitapEvent {
  final int courseClassId;

  const LoadDefterKitapDates(this.courseClassId);

  @override
  List<Object?> get props => [courseClassId];
}

// Event to load records for a specific date and course class
class LoadDefterKitapByDate extends DefterKitapEvent {
  final String date;
  final int courseClassId;

  const LoadDefterKitapByDate(this.date, this.courseClassId);

  @override
  List<Object?> get props => [date, courseClassId];
}

// Event to update or add notebook/book status
class AddOrUpdateDefterKitap extends DefterKitapEvent {
  final List<Map<String, dynamic>> defterKitapDataList;
  final String date;
  final int courseClassId;

  const AddOrUpdateDefterKitap(
    this.defterKitapDataList,
    this.date,
    this.courseClassId,
  );

  @override
  List<Object?> get props => [defterKitapDataList, date, courseClassId];
}

// Event to update a single student's notebook/book status
class UpdateStudentDefterKitap extends DefterKitapEvent {
  final int studentId;
  final int courseClassId;
  final bool notebookStatus;
  final bool bookStatus;
  final String date;

  const UpdateStudentDefterKitap({
    required this.studentId,
    required this.courseClassId,
    required this.notebookStatus,
    required this.bookStatus,
    required this.date,
  });

  @override
  List<Object?> get props =>
      [studentId, courseClassId, notebookStatus, bookStatus, date];
}

// Event to initiate loading state
class DefterKitapLoading extends DefterKitapEvent {}

// Event to reset state
class ResetDefterKitapState extends DefterKitapEvent {}
