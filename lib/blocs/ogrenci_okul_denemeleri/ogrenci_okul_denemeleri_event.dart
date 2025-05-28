import 'package:equatable/equatable.dart';
import '../../models/ogrenci_okul_denemesi_model.dart';

abstract class OgrenciOkulDenemeleriEvent extends Equatable {
  const OgrenciOkulDenemeleriEvent();

  @override
  List<Object?> get props => [];
}

// Tüm öğrenci okul denemelerini yükle
class LoadAllOgrenciOkulDenemeleri extends OgrenciOkulDenemeleriEvent {
  const LoadAllOgrenciOkulDenemeleri();
}

// Belirli bir öğrencinin deneme sonuçlarını yükle
class LoadOgrenciOkulDenemeleriByStudent extends OgrenciOkulDenemeleriEvent {
  final int ogrenciId;

  const LoadOgrenciOkulDenemeleriByStudent(this.ogrenciId);

  @override
  List<Object?> get props => [ogrenciId];
}

// Öğrenci deneme sonucunu oluştur veya güncelle
class UpsertOgrenciOkulDenemesi extends OgrenciOkulDenemeleriEvent {
  final OgrenciOkulDenemesi denemeSonucu;

  const UpsertOgrenciOkulDenemesi(this.denemeSonucu);

  @override
  List<Object?> get props => [denemeSonucu];
}

// Öğrenci deneme sonucunu sil
class DeleteOgrenciOkulDenemesi extends OgrenciOkulDenemeleriEvent {
  final int id;

  const DeleteOgrenciOkulDenemesi(this.id);

  @override
  List<Object?> get props => [id];
}

// Sınıf için okul denemesi ortalamalarını yükle
class LoadClassOkulDenemeAverages extends OgrenciOkulDenemeleriEvent {
  final int sinifId;
  final int ogrenciId;

  const LoadClassOkulDenemeAverages({
    required this.sinifId,
    required this.ogrenciId,
  });

  @override
  List<Object?> get props => [sinifId, ogrenciId];
}

// Öğrenci deneme sonucunu seç
class SelectOgrenciOkulDenemesi extends OgrenciOkulDenemeleriEvent {
  final OgrenciOkulDenemesi? denemeSonucu;

  const SelectOgrenciOkulDenemesi(this.denemeSonucu);

  @override
  List<Object?> get props => [denemeSonucu];
}
