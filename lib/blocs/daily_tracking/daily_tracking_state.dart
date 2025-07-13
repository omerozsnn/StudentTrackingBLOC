import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/daily_tracking_model.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';
import 'package:ogrenci_takip_sistemi/screens/daily_tracking/daily_tracking_screen.dart';

@immutable
abstract class DailyTrackingState extends Equatable {
  const DailyTrackingState();

  @override
  List<Object?> get props => [];
}

// Başlangıç durumu
class DailyTrackingInitial extends DailyTrackingState {}

// Yükleniyor durumu
class DailyTrackingLoading extends DailyTrackingState {}

// Sınıflar yüklendi durumu
class ClassesLoaded extends DailyTrackingState {
  final List<Classes> classes;

  const ClassesLoaded(this.classes);

  @override
  List<Object?> get props => [classes];
}

// Öğrenciler yüklendi durumu
class StudentsLoaded extends DailyTrackingState {
  final List<Student> students;
  final int classId;

  const StudentsLoaded(this.students, this.classId);

  @override
  List<Object?> get props => [students, classId];
}

// Takip verileri yüklendi durumu
class TrackingDataLoaded extends DailyTrackingState {
  final List<Classes> classes;
  final int? currentClassId;
  final List<Student> students;
  final Map<int, Map<String, Map<EnumCourse, int>>> trackingData;
  final Map<int, Map<int, Map<EnumCourse, int>>> weeklyData;
  final DateTime selectedMonth;
  final Map<int, bool> expandedStudents;

  const TrackingDataLoaded({
    required this.classes,
    required this.currentClassId,
    required this.students,
    required this.trackingData,
    required this.weeklyData,
    required this.selectedMonth,
    required this.expandedStudents,
  });

  @override
  List<Object?> get props => [
        classes,
        currentClassId,
        students,
        trackingData,
        weeklyData,
        selectedMonth,
        expandedStudents,
      ];

  // copyWith method for state updates
  TrackingDataLoaded copyWith({
    List<Classes>? classes,
    int? currentClassId,
    List<Student>? students,
    Map<int, Map<String, Map<EnumCourse, int>>>? trackingData,
    Map<int, Map<int, Map<EnumCourse, int>>>? weeklyData,
    DateTime? selectedMonth,
    Map<int, bool>? expandedStudents,
  }) {
    return TrackingDataLoaded(
      classes: classes ?? this.classes,
      currentClassId: currentClassId ?? this.currentClassId,
      students: students ?? this.students,
      trackingData: trackingData ?? this.trackingData,
      weeklyData: weeklyData ?? this.weeklyData,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      expandedStudents: expandedStudents ?? this.expandedStudents,
    );
  }
}

// Ay değişti durumu
class MonthChanged extends DailyTrackingState {
  final DateTime newMonth;

  const MonthChanged(this.newMonth);

  @override
  List<Object?> get props => [newMonth];
}

// Veri kaydedildi durumu
class TrackingDataSaved extends DailyTrackingState {
  final String message;

  const TrackingDataSaved(this.message);

  @override
  List<Object?> get props => [message];
}

// Öğrenci genişletme durumu değişti
class StudentExpansionChanged extends DailyTrackingState {
  final int studentId;
  final bool isExpanded;

  const StudentExpansionChanged(this.studentId, this.isExpanded);

  @override
  List<Object?> get props => [studentId, isExpanded];
}

// Hata durumu
class DailyTrackingError extends DailyTrackingState {
  final String message;

  const DailyTrackingError(this.message);

  @override
  List<Object?> get props => [message];
}

// İşlem başarılı durumu
class DailyTrackingOperationSuccess extends DailyTrackingState {
  final String message;

  const DailyTrackingOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Bilgilendirme durumu
class DailyTrackingOperationMessage extends DailyTrackingState {
  final String message;

  const DailyTrackingOperationMessage(this.message);

  @override
  List<Object?> get props => [message];
} 