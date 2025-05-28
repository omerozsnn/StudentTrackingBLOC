import 'package:ogrenci_takip_sistemi/models/misbehaviour_model.dart';

class StudentMisbehaviour {
  final int? id;
  final int ogrenciId;
  final int yaramazlikId;
  final String tarih;
  final String? aciklama;
  final int? egitimOgretimYiliId;
  final Misbehaviour? misbehaviour;
  final Map<String, dynamic>? student;

  StudentMisbehaviour({
    this.id,
    required this.ogrenciId,
    required this.yaramazlikId,
    required this.tarih,
    this.aciklama,
    this.egitimOgretimYiliId,
    this.misbehaviour,
    this.student,
  });

  // JSON'dan model oluşturma
  factory StudentMisbehaviour.fromJson(Map<String, dynamic> json) {
    return StudentMisbehaviour(
      id: json['id'],
      ogrenciId: json['ogrenci_id'],
      yaramazlikId: json['yaramazlık_id'],
      tarih: json['tarih'],
      aciklama: json['aciklama'],
      egitimOgretimYiliId: json['egitimOgretimYiliId'],
      misbehaviour: json['misbehaviour'] != null
          ? Misbehaviour.fromJson(json['misbehaviour'])
          : null,
      student: json['student'],
    );
  }

  // Modelden JSON oluşturma
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['ogrenci_id'] = ogrenciId;
    data['yaramazlık_id'] = yaramazlikId;
    data['tarih'] = tarih;
    if (aciklama != null) data['aciklama'] = aciklama;
    if (egitimOgretimYiliId != null)
      data['egitimOgretimYiliId'] = egitimOgretimYiliId;
    return data;
  }

  // Modeli kopyalayıp bazı alanları güncelleme
  StudentMisbehaviour copyWith({
    int? id,
    int? ogrenciId,
    int? yaramazlikId,
    String? tarih,
    String? aciklama,
    int? egitimOgretimYiliId,
    Misbehaviour? misbehaviour,
    Map<String, dynamic>? student,
  }) {
    return StudentMisbehaviour(
      id: id ?? this.id,
      ogrenciId: ogrenciId ?? this.ogrenciId,
      yaramazlikId: yaramazlikId ?? this.yaramazlikId,
      tarih: tarih ?? this.tarih,
      aciklama: aciklama ?? this.aciklama,
      egitimOgretimYiliId: egitimOgretimYiliId ?? this.egitimOgretimYiliId,
      misbehaviour: misbehaviour ?? this.misbehaviour,
      student: student ?? this.student,
    );
  }

  @override
  String toString() {
    return 'StudentMisbehaviour(id: $id, ogrenciId: $ogrenciId, yaramazlikId: $yaramazlikId, tarih: $tarih, aciklama: $aciklama, egitimOgretimYiliId: $egitimOgretimYiliId)';
  }
}
