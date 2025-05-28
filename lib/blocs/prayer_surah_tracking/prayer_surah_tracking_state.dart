import 'package:equatable/equatable.dart';
import 'package:ogrenci_takip_sistemi/models/prayer_surah_tracking_model.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';

enum PrayerSurahTrackingStatus { initial, loading, success, failure }

class PrayerSurahTrackingState extends Equatable {
  final PrayerSurahTrackingStatus status;
  final List<PrayerSurahTracking> trackings;
  final List<Student> students;
  final List<String> classes;
  final List<Map<String, dynamic>> assignedSurahDuaList;
  final List<Map<String, dynamic>> previousTrackings;
  final String? selectedClass;
  final int? selectedSurahDuaId;
  final Map<int, Map<String, dynamic>> studentTrackings;
  final String? errorMessage;
  final bool isSubmitting;

  const PrayerSurahTrackingState({
    this.status = PrayerSurahTrackingStatus.initial,
    this.trackings = const [],
    this.students = const [],
    this.classes = const [],
    this.assignedSurahDuaList = const [],
    this.previousTrackings = const [],
    this.selectedClass,
    this.selectedSurahDuaId,
    this.studentTrackings = const {},
    this.errorMessage,
    this.isSubmitting = false,
  });

  PrayerSurahTrackingState copyWith({
    PrayerSurahTrackingStatus? status,
    List<PrayerSurahTracking>? trackings,
    List<Student>? students,
    List<String>? classes,
    List<Map<String, dynamic>>? assignedSurahDuaList,
    List<Map<String, dynamic>>? previousTrackings,
    String? selectedClass,
    int? selectedSurahDuaId,
    Map<int, Map<String, dynamic>>? studentTrackings,
    String? errorMessage,
    bool? isSubmitting,
    bool clearSelectedClass = false,
    bool clearSelectedSurahDuaId = false,
    bool clearError = false,
  }) {
    return PrayerSurahTrackingState(
      status: status ?? this.status,
      trackings: trackings ?? this.trackings,
      students: students ?? this.students,
      classes: classes ?? this.classes,
      assignedSurahDuaList: assignedSurahDuaList ?? this.assignedSurahDuaList,
      previousTrackings: previousTrackings ?? this.previousTrackings,
      selectedClass:
          clearSelectedClass ? null : selectedClass ?? this.selectedClass,
      selectedSurahDuaId: clearSelectedSurahDuaId
          ? null
          : selectedSurahDuaId ?? this.selectedSurahDuaId,
      studentTrackings: studentTrackings ?? this.studentTrackings,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  @override
  List<Object?> get props => [
        status,
        trackings,
        students,
        classes,
        assignedSurahDuaList,
        previousTrackings,
        selectedClass,
        selectedSurahDuaId,
        studentTrackings,
        errorMessage,
        isSubmitting,
      ];
}
