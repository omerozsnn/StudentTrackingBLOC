import 'package:equatable/equatable.dart';
import 'package:ogrenci_takip_sistemi/models/prayer_surah_student_model.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';

enum PrayerSurahStudentStatus { initial, loading, success, failure }

class PrayerSurahStudentState extends Equatable {
  final PrayerSurahStudentStatus status;
  final List<PrayerSurahStudent> prayerSurahStudents;
  final List<Student> students;
  final int? selectedPrayerSurahId;
  final String? selectedClass;
  final bool selectAll;
  final Map<int, bool> selectedStudents;
  final String? errorMessage;

  const PrayerSurahStudentState({
    this.status = PrayerSurahStudentStatus.initial,
    this.prayerSurahStudents = const [],
    this.students = const [],
    this.selectedPrayerSurahId,
    this.selectedClass,
    this.selectAll = false,
    this.selectedStudents = const {},
    this.errorMessage,
  });

  PrayerSurahStudentState copyWith({
    PrayerSurahStudentStatus? status,
    List<PrayerSurahStudent>? prayerSurahStudents,
    List<Student>? students,
    int? selectedPrayerSurahId,
    String? selectedClass,
    bool? selectAll,
    Map<int, bool>? selectedStudents,
    String? errorMessage,
    bool clearSelectedPrayerSurahId = false,
    bool clearSelectedClass = false,
    bool clearError = false,
  }) {
    return PrayerSurahStudentState(
      status: status ?? this.status,
      prayerSurahStudents: prayerSurahStudents ?? this.prayerSurahStudents,
      students: students ?? this.students,
      selectedPrayerSurahId: clearSelectedPrayerSurahId
          ? null
          : selectedPrayerSurahId ?? this.selectedPrayerSurahId,
      selectedClass:
          clearSelectedClass ? null : selectedClass ?? this.selectedClass,
      selectAll: selectAll ?? this.selectAll,
      selectedStudents: selectedStudents ?? this.selectedStudents,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        prayerSurahStudents,
        students,
        selectedPrayerSurahId,
        selectedClass,
        selectAll,
        selectedStudents,
        errorMessage,
      ];

  // Helper methods
  List<int> get selectedStudentIds => selectedStudents.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();

  bool hasSelectedStudents() => selectedStudentIds.isNotEmpty;
}
