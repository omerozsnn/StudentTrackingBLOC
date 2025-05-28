import 'package:equatable/equatable.dart';
import 'package:ogrenci_takip_sistemi/models/ogrenci_denemeleri_model.dart';

abstract class OgrenciDenemeState extends Equatable {
  const OgrenciDenemeState();

  @override
  List<Object?> get props => [];
}

// Başlangıç durumu
class OgrenciDenemeInitial extends OgrenciDenemeState {}

// Yükleniyor durumu
class OgrenciDenemeLoading extends OgrenciDenemeState {}

// Tüm öğrenci deneme sonuçları yüklendi
class OgrenciDenemeResultsLoaded extends OgrenciDenemeState {
  final List<StudentExamResult> results;

  const OgrenciDenemeResultsLoaded(this.results);

  @override
  List<Object?> get props => [results];
}

// Belirli bir öğrencinin deneme sonuçları yüklendi
class OgrenciDenemeResultsByStudentLoaded extends OgrenciDenemeState {
  final List<StudentExamResult> results;
  final int ogrenciId;

  const OgrenciDenemeResultsByStudentLoaded(this.results, this.ogrenciId);

  @override
  List<Object?> get props => [results, ogrenciId];
}

// Belirli bir denemenin sonuçları yüklendi
class OgrenciDenemeResultsByExamLoaded extends OgrenciDenemeState {
  final List<StudentExamResult> results;
  final int denemeSinaviId;

  const OgrenciDenemeResultsByExamLoaded(this.results, this.denemeSinaviId);

  @override
  List<Object?> get props => [results, denemeSinaviId];
}

// Öğrenci deneme katılım bilgileri yüklendi
class OgrenciDenemeParticipationLoaded extends OgrenciDenemeState {
  final StudentExamParticipation participation;

  const OgrenciDenemeParticipationLoaded(this.participation);

  @override
  List<Object?> get props => [participation];
}

// Sınıf deneme ortalamaları yüklendi
class ClassDenemeAveragesLoaded extends OgrenciDenemeState {
  final ClassDenemeAverages averages;

  const ClassDenemeAveragesLoaded(this.averages);

  @override
  List<Object?> get props => [averages];
}

// İşlem başarılı durumu
class OgrenciDenemeOperationSuccess extends OgrenciDenemeState {
  final String message;

  const OgrenciDenemeOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Hata durumu
class OgrenciDenemeError extends OgrenciDenemeState {
  final String message;

  const OgrenciDenemeError(this.message);

  @override
  List<Object?> get props => [message];
} 