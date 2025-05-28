import 'package:equatable/equatable.dart';
import 'package:ogrenci_takip_sistemi/models/prayer_surah_student_model.dart';

abstract class PrayerSurahStudentEvent extends Equatable {
  const PrayerSurahStudentEvent();

  @override
  List<Object?> get props => [];
}

class LoadPrayerSurahStudents extends PrayerSurahStudentEvent {}

class LoadPrayerSurahStudentsByStudentId extends PrayerSurahStudentEvent {
  final int studentId;

  const LoadPrayerSurahStudentsByStudentId(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class LoadPrayerSurahStudentsByClassId extends PrayerSurahStudentEvent {
  final int classId;

  const LoadPrayerSurahStudentsByClassId(this.classId);

  @override
  List<Object?> get props => [classId];
}

class AddPrayerSurahStudent extends PrayerSurahStudentEvent {
  final PrayerSurahStudent prayerSurahStudent;

  const AddPrayerSurahStudent(this.prayerSurahStudent);

  @override
  List<Object?> get props => [prayerSurahStudent];
}

class UpdatePrayerSurahStudent extends PrayerSurahStudentEvent {
  final int id;
  final PrayerSurahStudent prayerSurahStudent;

  const UpdatePrayerSurahStudent(this.id, this.prayerSurahStudent);

  @override
  List<Object?> get props => [id, prayerSurahStudent];
}

class DeletePrayerSurahStudent extends PrayerSurahStudentEvent {
  final int id;

  const DeletePrayerSurahStudent(this.id);

  @override
  List<Object?> get props => [id];
}

class AssignPrayerSurahToMultipleStudents extends PrayerSurahStudentEvent {
  final int prayerSurahId;
  final List<int> studentIds;

  const AssignPrayerSurahToMultipleStudents(
      this.prayerSurahId, this.studentIds);

  @override
  List<Object?> get props => [prayerSurahId, studentIds];
}

class SetSelectedPrayerSurahId extends PrayerSurahStudentEvent {
  final int? prayerSurahId;

  const SetSelectedPrayerSurahId(this.prayerSurahId);

  @override
  List<Object?> get props => [prayerSurahId];
}

class SetSelectedClass extends PrayerSurahStudentEvent {
  final String? className;

  const SetSelectedClass(this.className);

  @override
  List<Object?> get props => [className];
}

class SelectAllStudents extends PrayerSurahStudentEvent {
  final bool selectAll;

  const SelectAllStudents(this.selectAll);

  @override
  List<Object?> get props => [selectAll];
}

class ToggleStudentSelection extends PrayerSurahStudentEvent {
  final int studentId;
  final bool isSelected;

  const ToggleStudentSelection(this.studentId, this.isSelected);

  @override
  List<Object?> get props => [studentId, isSelected];
}
