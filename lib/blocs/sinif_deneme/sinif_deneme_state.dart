import 'package:equatable/equatable.dart';

abstract class SinifDenemeState extends Equatable {
  const SinifDenemeState();

  @override
  List<Object?> get props => [];
}

// Başlangıç durumu
class SinifDenemeInitial extends SinifDenemeState {}

// Yükleniyor durumu
class SinifDenemeLoading extends SinifDenemeState {}

// Tüm sınıf-deneme ilişkileri yüklendi
class SinifDenemeleriLoaded extends SinifDenemeState {
  final List<dynamic> sinifDenemeleri;

  const SinifDenemeleriLoaded(this.sinifDenemeleri);

  @override
  List<Object?> get props => [sinifDenemeleri];
}

// Belirli bir sınıfa ait deneme sınavları yüklendi
class ExamsByClassLoaded extends SinifDenemeState {
  final List<dynamic> examsByClass;
  final int sinifId;

  const ExamsByClassLoaded(this.examsByClass, this.sinifId);

  @override
  List<Object?> get props => [examsByClass, sinifId];
}

// Belirli bir deneme sınavına ait sınıflar yüklendi
class ClassesByExamLoaded extends SinifDenemeState {
  final List<dynamic> classesByExam;
  final int denemeSinaviId;

  const ClassesByExamLoaded(this.classesByExam, this.denemeSinaviId);

  @override
  List<Object?> get props => [classesByExam, denemeSinaviId];
}

// İşlem başarılı durumu
class SinifDenemeOperationSuccess extends SinifDenemeState {
  final String message;

  const SinifDenemeOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// Hata durumu
class SinifDenemeError extends SinifDenemeState {
  final String message;

  const SinifDenemeError(this.message);

  @override
  List<Object?> get props => [message];
} 