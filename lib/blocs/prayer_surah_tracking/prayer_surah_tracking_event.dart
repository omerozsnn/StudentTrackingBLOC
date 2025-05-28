import 'package:equatable/equatable.dart';
import 'package:ogrenci_takip_sistemi/models/prayer_surah_tracking_model.dart';

abstract class PrayerSurahTrackingEvent extends Equatable {
  const PrayerSurahTrackingEvent();

  @override
  List<Object?> get props => [];
}

class LoadClasses extends PrayerSurahTrackingEvent {}

class SelectClass extends PrayerSurahTrackingEvent {
  final String className;

  const SelectClass(this.className);

  @override
  List<Object?> get props => [className];
}

class LoadStudentsWithTrackings extends PrayerSurahTrackingEvent {
  final String className;
  final int? surahDuaId;

  const LoadStudentsWithTrackings(this.className, {this.surahDuaId});

  @override
  List<Object?> get props => [className, surahDuaId];
}

class LoadAssignedSurahDua extends PrayerSurahTrackingEvent {
  final String className;

  const LoadAssignedSurahDua(this.className);

  @override
  List<Object?> get props => [className];
}

class SelectSurahDua extends PrayerSurahTrackingEvent {
  final int surahDuaId;

  const SelectSurahDua(this.surahDuaId);

  @override
  List<Object?> get props => [surahDuaId];
}

class SelectStudent extends PrayerSurahTrackingEvent {
  final int studentId;

  const SelectStudent(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class UpdateStudentTrackingStatus extends PrayerSurahTrackingEvent {
  final int studentId;
  final String durum;

  const UpdateStudentTrackingStatus(this.studentId, this.durum);

  @override
  List<Object?> get props => [studentId, durum];
}

class UpdateStudentTrackingDegerlendirme extends PrayerSurahTrackingEvent {
  final int studentId;
  final String? degerlendirme;

  const UpdateStudentTrackingDegerlendirme(this.studentId, this.degerlendirme);

  @override
  List<Object?> get props => [studentId, degerlendirme];
}

class UpdateStudentTrackingEkGorus extends PrayerSurahTrackingEvent {
  final int studentId;
  final String ekgorus;

  const UpdateStudentTrackingEkGorus(this.studentId, this.ekgorus);

  @override
  List<Object?> get props => [studentId, ekgorus];
}

class SaveTrackings extends PrayerSurahTrackingEvent {
  final List<int> studentIds;
  final int surahDuaId;

  const SaveTrackings({required this.studentIds, required this.surahDuaId});

  @override
  List<Object?> get props => [studentIds, surahDuaId];
}

class LoadStudentPhoto extends PrayerSurahTrackingEvent {
  final int studentId;

  const LoadStudentPhoto(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class LoadPreviousTrackings extends PrayerSurahTrackingEvent {
  final int studentId;
  final int? surahDuaId;

  const LoadPreviousTrackings(this.studentId, {this.surahDuaId});

  @override
  List<Object?> get props => [studentId, surahDuaId];
}
