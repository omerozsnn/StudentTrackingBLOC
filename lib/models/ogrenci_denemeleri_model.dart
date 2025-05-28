import 'package:ogrenci_takip_sistemi/models/deneme_sinavi_model.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';

class StudentExamResult {
  final int? id;
  final int ogrenciId;
  final int denemeSinaviId;
  final int? dogru;
  final int? yanlis;
  final int? bos;
  final int? puan;

  final Student? ogrenci;
  final DenemeSinavi? denemeSinavi;

  StudentExamResult({
    this.id,
    required this.ogrenciId,
    required this.denemeSinaviId,
    this.dogru,
    this.yanlis,
    this.bos,
    this.puan,
    this.ogrenci,
    this.denemeSinavi,
  });

  factory StudentExamResult.fromJson(Map<String, dynamic> json) {
    return StudentExamResult(
      id: json['id'],
      ogrenciId: json['ogrenci_id'],
      denemeSinaviId: json['deneme_sinavi_id'],
      dogru: json['dogru'],
      yanlis: json['yanlis'],
      bos: json['bos'],
      puan: json['puan'],
      ogrenci:
          json['ogrenci'] != null ? Student.fromJson(json['ogrenci']) : null,
      denemeSinavi: json['denemeSinavi'] != null
          ? DenemeSinavi.fromJson(json['denemeSinavi'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'ogrenci_id': ogrenciId,
      'deneme_sinavi_id': denemeSinaviId,
    };

    if (id != null) data['id'] = id;
    if (dogru != null) data['dogru'] = dogru;
    if (yanlis != null) data['yanlis'] = yanlis;
    if (bos != null) data['bos'] = bos;
    if (puan != null) data['puan'] = puan;

    return data;
  }

  // Create a copy with updated fields
  StudentExamResult copyWith({
    int? id,
    int? ogrenciId,
    int? denemeSinaviId,
    int? dogru,
    int? yanlis,
    int? bos,
    int? puan,
    Student? ogrenci,
    DenemeSinavi? denemeSinavi,
  }) {
    return StudentExamResult(
      id: id ?? this.id,
      ogrenciId: ogrenciId ?? this.ogrenciId,
      denemeSinaviId: denemeSinaviId ?? this.denemeSinaviId,
      dogru: dogru ?? this.dogru,
      yanlis: yanlis ?? this.yanlis,
      bos: bos ?? this.bos,
      puan: puan ?? this.puan,
      ogrenci: ogrenci ?? this.ogrenci,
      denemeSinavi: denemeSinavi ?? this.denemeSinavi,
    );
  }
}

class StudentExamParticipation {
  final int ogrenciId;
  final String ogrenciAdi;
  final int sinifId;
  final String sinifAdi;
  final int egitimYiliId;
  final int totalDeneme;
  final int katilanDenemeSayisi;
  final int katilmayanDenemeSayisi;
  final List<ParticipatedExam> katilanDenemeler;
  final List<NonParticipatedExam> katilmayanDenemeler;

  StudentExamParticipation({
    required this.ogrenciId,
    required this.ogrenciAdi,
    required this.sinifId,
    required this.sinifAdi,
    required this.egitimYiliId,
    required this.totalDeneme,
    required this.katilanDenemeSayisi,
    required this.katilmayanDenemeSayisi,
    required this.katilanDenemeler,
    required this.katilmayanDenemeler,
  });

  factory StudentExamParticipation.fromJson(Map<String, dynamic> json) {
    return StudentExamParticipation(
      ogrenciId: json['student_id'],
      ogrenciAdi: json['student_name'],
      sinifId: json['sinif_id'],
      sinifAdi: json['sinif_adi'] ?? '',
      egitimYiliId: json['egitim_yili_id'],
      totalDeneme: json['totalDeneme'],
      katilanDenemeSayisi: json['katilanDenemeSayisi'],
      katilmayanDenemeSayisi: json['katilmayanDenemesayisi'],
      katilanDenemeler: (json['katilanDenemeler'] as List)
          .map((e) => ParticipatedExam.fromJson(e))
          .toList(),
      katilmayanDenemeler: (json['katilmayanDenemeler'] as List)
          .map((e) => NonParticipatedExam.fromJson(e))
          .toList(),
    );
  }
}

class ParticipatedExam {
  final int denemeSinaviId;
  final String denemeSinaviAdi;
  final int? dogru;
  final int? yanlis;
  final int? bos;
  final int? puan;

  ParticipatedExam({
    required this.denemeSinaviId,
    required this.denemeSinaviAdi,
    this.dogru,
    this.yanlis,
    this.bos,
    this.puan,
  });

  factory ParticipatedExam.fromJson(Map<String, dynamic> json) {
    return ParticipatedExam(
      denemeSinaviId: json['deneme_sinavi_id'],
      denemeSinaviAdi: json['deneme_sinavi_adi'],
      dogru: json['dogru'],
      yanlis: json['yanlis'],
      bos: json['bos'],
      puan: json['puan'],
    );
  }
}

class NonParticipatedExam {
  final int denemeSinaviId;
  final String denemeSinaviAdi;

  NonParticipatedExam({
    required this.denemeSinaviId,
    required this.denemeSinaviAdi,
  });

  factory NonParticipatedExam.fromJson(Map<String, dynamic> json) {
    return NonParticipatedExam(
      denemeSinaviId: json['deneme_sinavi_id'],
      denemeSinaviAdi: json['deneme_sinavi_adi'],
    );
  }
}

class ClassDenemeAverage {
  final int denemeId;
  final String denemeSinaviAdi;
  final int? soruSayisi;
  final double? averageScore;
  final double? averageCorrect;
  final double? averageWrong;
  final double? averageEmpty;
  final int totalParticipants;
  final bool hasParticipated;

  ClassDenemeAverage({
    required this.denemeId,
    required this.denemeSinaviAdi,
    this.soruSayisi,
    this.averageScore,
    this.averageCorrect,
    this.averageWrong,
    this.averageEmpty,
    required this.totalParticipants,
    required this.hasParticipated,
  });

  factory ClassDenemeAverage.fromJson(Map<String, dynamic> json) {
    return ClassDenemeAverage(
      denemeId: json['deneme_id'],
      denemeSinaviAdi: json['deneme_sinavi_adi'],
      soruSayisi: json['soru_sayisi'],
      averageScore: json['averageScore']?.toDouble(),
      averageCorrect: json['averageCorrect']?.toDouble(),
      averageWrong: json['averageWrong']?.toDouble(),
      averageEmpty: json['averageEmpty']?.toDouble(),
      totalParticipants: json['totalParticipants'],
      hasParticipated: json['hasParticipated'],
    );
  }
}

class ClassDenemeAverages {
  final int sinifId;
  final int egitimYiliId;
  final List<ClassDenemeAverage> denemeAverages;

  ClassDenemeAverages({
    required this.sinifId,
    required this.egitimYiliId,
    required this.denemeAverages,
  });

  factory ClassDenemeAverages.fromJson(Map<String, dynamic> json) {
    return ClassDenemeAverages(
      sinifId: json['sinif_id'],
      egitimYiliId: json['egitim_yili_id'],
      denemeAverages: (json['denemeAverages'] as List)
          .map((e) => ClassDenemeAverage.fromJson(e))
          .toList(),
    );
  }
}
