import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/daily_tracking_model.dart';

@immutable
abstract class DailyTrackingEvent extends Equatable {
  const DailyTrackingEvent();

  @override
  List<Object?> get props => [];
}

// Sınıfları yükleme eventi
class LoadClasses extends DailyTrackingEvent {}

// Sınıf seçme eventi
class SelectClass extends DailyTrackingEvent {
  final int classId;

  const SelectClass(this.classId);

  @override
  List<Object?> get props => [classId];
}

// Öğrencileri yükleme eventi
class LoadStudents extends DailyTrackingEvent {
  final int classId;

  const LoadStudents(this.classId);

  @override
  List<Object?> get props => [classId];
}

// Takip verilerini yükleme eventi
class LoadTrackingData extends DailyTrackingEvent {
  final int classId;
  final DateTime selectedMonth;

  const LoadTrackingData(this.classId, this.selectedMonth);

  @override
  List<Object?> get props => [classId, selectedMonth];
}

// Ay değiştirme eventi
class ChangeMonth extends DailyTrackingEvent {
  final int monthDelta;

  const ChangeMonth(this.monthDelta);

  @override
  List<Object?> get props => [monthDelta];
}

// Takip verisi kaydetme eventi
class SaveTrackingData extends DailyTrackingEvent {
  final int studentId;
  final DateTime date;
  final EnumCourse course;
  final int? value;

  const SaveTrackingData(this.studentId, this.date, this.course, this.value);

  @override
  List<Object?> get props => [studentId, date, course, value];
}

// Öğrenci genişletme durumu değiştirme eventi
class ToggleStudentExpansion extends DailyTrackingEvent {
  final int studentId;

  const ToggleStudentExpansion(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

// Verileri yenileme eventi
class RefreshData extends DailyTrackingEvent {}

// Başlangıç durumuna döndürme eventi
class ResetDailyTracking extends DailyTrackingEvent {} 