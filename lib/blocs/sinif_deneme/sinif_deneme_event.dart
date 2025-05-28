import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
abstract class SinifDenemeEvent extends Equatable {
  const SinifDenemeEvent();

  @override
  List<Object?> get props => [];
}

// Tüm sınıf-deneme ilişkilerini yükleme
class LoadAllSinifDenemeleri extends SinifDenemeEvent {}

// Belirli bir sınıfa ait deneme sınavlarını yükleme
class LoadExamsByClass extends SinifDenemeEvent {
  final int sinifId;

  const LoadExamsByClass(this.sinifId);

  @override
  List<Object?> get props => [sinifId];
}

// Belirli bir deneme sınavına ait sınıfları yükleme
class LoadClassesByExam extends SinifDenemeEvent {
  final int denemeSinaviId;

  const LoadClassesByExam(this.denemeSinaviId);

  @override
  List<Object?> get props => [denemeSinaviId];
}

// Yeni bir sınıf-deneme ilişkisi oluşturma
class CreateSinifDeneme extends SinifDenemeEvent {
  final Map<String, dynamic> data;

  const CreateSinifDeneme(this.data);

  @override
  List<Object?> get props => [data];
}

// Sınıf-deneme ilişkisini güncelleme
class UpdateSinifDeneme extends SinifDenemeEvent {
  final int sinifId;
  final int denemeSinaviId;
  final Map<String, dynamic> data;

  const UpdateSinifDeneme({
    required this.sinifId,
    required this.denemeSinaviId,
    required this.data,
  });

  @override
  List<Object?> get props => [sinifId, denemeSinaviId, data];
}

// Sınıf-deneme ilişkisini silme
class DeleteSinifDeneme extends SinifDenemeEvent {
  final int sinifId;
  final int denemeSinaviId;

  const DeleteSinifDeneme(this.sinifId, this.denemeSinaviId);

  @override
  List<Object?> get props => [sinifId, denemeSinaviId];
}

// Belirli bir sınıfa deneme sınavı atama
class AssignExamToClass extends SinifDenemeEvent {
  final int examId;
  final int classId;

  const AssignExamToClass(this.examId, this.classId);

  @override
  List<Object?> get props => [examId, classId];
}

// Tüm 5. sınıflara deneme sınavı atama
class AssignExamToFifthGrade extends SinifDenemeEvent {
  final Map<String, dynamic> data;

  const AssignExamToFifthGrade(this.data);

  @override
  List<Object?> get props => [data];
}

// Tüm 6. sınıflara deneme sınavı atama
class AssignExamToSixthGrade extends SinifDenemeEvent {
  final Map<String, dynamic> data;

  const AssignExamToSixthGrade(this.data);

  @override
  List<Object?> get props => [data];
}

// Tüm 7. sınıflara deneme sınavı atama
class AssignExamToSeventhGrade extends SinifDenemeEvent {
  final Map<String, dynamic> data;

  const AssignExamToSeventhGrade(this.data);

  @override
  List<Object?> get props => [data];
}

// Tüm 8. sınıflara deneme sınavı atama
class AssignExamToEighthGrade extends SinifDenemeEvent {
  final Map<String, dynamic> data;

  const AssignExamToEighthGrade(this.data);

  @override
  List<Object?> get props => [data];
}

// Yükleme durumu olayı
class SinifDenemeLoadingEvent extends SinifDenemeEvent {} 