import 'package:equatable/equatable.dart';
import '../../models/ogrenci_okul_denemesi_model.dart';

abstract class OgrenciOkulDenemeleriState extends Equatable {
  const OgrenciOkulDenemeleriState();

  @override
  List<Object?> get props => [];
}

// Başlangıç durumu
class OgrenciOkulDenemeleriInitial extends OgrenciOkulDenemeleriState {}

// Yükleniyor durumu
class OgrenciOkulDenemeleriLoading extends OgrenciOkulDenemeleriState {}

// Yüklendi durumu (tüm öğrenci okul denemeleri)
class OgrenciOkulDenemeleriLoaded extends OgrenciOkulDenemeleriState {
  final List<OgrenciOkulDenemesi> denemeleri;
  final OgrenciOkulDenemesi? selectedDenemeSonucu;

  const OgrenciOkulDenemeleriLoaded({
    required this.denemeleri,
    this.selectedDenemeSonucu,
  });

  @override
  List<Object?> get props => [denemeleri, selectedDenemeSonucu];

  OgrenciOkulDenemeleriLoaded copyWith({
    List<OgrenciOkulDenemesi>? denemeleri,
    OgrenciOkulDenemesi? selectedDenemeSonucu,
    bool clearSelectedDenemeSonucu = false,
  }) {
    return OgrenciOkulDenemeleriLoaded(
      denemeleri: denemeleri ?? this.denemeleri,
      selectedDenemeSonucu: clearSelectedDenemeSonucu
          ? null
          : selectedDenemeSonucu ?? this.selectedDenemeSonucu,
    );
  }
}

// Sınıf ortalamaları yüklendi durumu
class ClassOkulDenemeAveragesLoaded extends OgrenciOkulDenemeleriState {
  final Map<String, dynamic> averages;

  const ClassOkulDenemeAveragesLoaded(this.averages);

  @override
  List<Object?> get props => [averages];
}

// Hata durumu
class OgrenciOkulDenemeleriError extends OgrenciOkulDenemeleriState {
  final String message;

  const OgrenciOkulDenemeleriError(this.message);

  @override
  List<Object?> get props => [message];
}

// İşlem başarılı durumu
class OgrenciOkulDenemeleriOperationSuccess extends OgrenciOkulDenemeleriState {
  final String message;

  const OgrenciOkulDenemeleriOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
