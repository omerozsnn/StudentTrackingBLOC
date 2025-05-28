import 'package:equatable/equatable.dart';
import 'package:ogrenci_takip_sistemi/models/deneme_sinavi_model.dart';

abstract class DenemeSinaviState extends Equatable {
  final List<DenemeSinavi> denemeSinavlari;
  final DenemeSinavi? selectedDenemeSinavi;

  const DenemeSinaviState({
    this.denemeSinavlari = const <DenemeSinavi>[],
    this.selectedDenemeSinavi,
  });

  @override
  List<Object?> get props => [denemeSinavlari, selectedDenemeSinavi];
}

// Başlangıç durumu
class DenemeSinaviInitial extends DenemeSinaviState {
  const DenemeSinaviInitial() : super();
}

// Yükleme durumu
class DenemeSinaviLoading extends DenemeSinaviState {
  const DenemeSinaviLoading({
    List<DenemeSinavi> denemeSinavlari = const <DenemeSinavi>[],
    DenemeSinavi? selectedDenemeSinavi,
  }) : super(
          denemeSinavlari: denemeSinavlari,
          selectedDenemeSinavi: selectedDenemeSinavi,
        );
}

// Deneme sınavları yüklendi durumu
class DenemeSinavlariLoaded extends DenemeSinaviState {
  const DenemeSinavlariLoaded(
    List<DenemeSinavi> denemeSinavlari, {
    DenemeSinavi? selectedDenemeSinavi,
  }) : super(
          denemeSinavlari: denemeSinavlari,
          selectedDenemeSinavi: selectedDenemeSinavi,
        );
}

// Deneme sınavı seçildi durumu
class DenemeSinaviSelected extends DenemeSinaviState {
  const DenemeSinaviSelected(
    DenemeSinavi denemeSinavi, {
    List<DenemeSinavi> denemeSinavlari = const <DenemeSinavi>[],
  }) : super(
          denemeSinavlari: denemeSinavlari,
          selectedDenemeSinavi: denemeSinavi,
        );
}

// Hata durumu
class DenemeSinaviError extends DenemeSinaviState {
  final String message;

  const DenemeSinaviError(
    this.message, {
    List<DenemeSinavi> denemeSinavlari = const <DenemeSinavi>[],
    DenemeSinavi? selectedDenemeSinavi,
  }) : super(
          denemeSinavlari: denemeSinavlari,
          selectedDenemeSinavi: selectedDenemeSinavi,
        );

  @override
  List<Object?> get props => [message, denemeSinavlari, selectedDenemeSinavi];
}

// İşlem başarılı durumu
class DenemeSinaviOperationSuccess extends DenemeSinaviState {
  final String message;

  const DenemeSinaviOperationSuccess(
    this.message, {
    List<DenemeSinavi> denemeSinavlari = const <DenemeSinavi>[],
    DenemeSinavi? selectedDenemeSinavi,
  }) : super(
          denemeSinavlari: denemeSinavlari,
          selectedDenemeSinavi: selectedDenemeSinavi,
        );

  @override
  List<Object?> get props => [message, denemeSinavlari, selectedDenemeSinavi];
} 