import 'package:ogrenci_takip_sistemi/models/units_model.dart';
import 'classes_model.dart';

class DenemeSinavi {
  final int? id;
  final String? denemeSinaviAdi;
  final int? soruSayisi;
  final int? uniteId;
  final Unit? unit;
  final int? egitimOgretimYiliId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final List<Classes>? siniflar;

  DenemeSinavi({
    this.id,
    this.denemeSinaviAdi,
    this.soruSayisi,
    this.uniteId,
    this.unit,
    this.egitimOgretimYiliId,
    this.createdAt,
    this.updatedAt,
    this.siniflar,
  });

  factory DenemeSinavi.fromJson(Map<String, dynamic> json) {
    return DenemeSinavi(
      id: json['id'],
      denemeSinaviAdi: json['deneme_sinavi_adi'],
      soruSayisi: json['soru_sayisi'],
      uniteId: json['unite_id'],
      unit: json['unit'] != null ? Unit.fromJson(json['unit']) : null,
      egitimOgretimYiliId: json['egitimOgretimYiliId'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      siniflar: json['siniflar'] != null
          ? List<Classes>.from(json['siniflar'].map((x) => Classes.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deneme_sinavi_adi': denemeSinaviAdi,
      'soru_sayisi': soruSayisi,
      'unite_id': uniteId,
    };
  }
}
