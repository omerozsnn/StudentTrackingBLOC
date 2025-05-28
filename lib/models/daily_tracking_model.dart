import 'package:ogrenci_takip_sistemi/models/classes_model.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';

enum EnumCourse {
  TURKCE,
  MATEMATIK,
  FEN_BILIMLERI,
  SOSYAL_BILGILER,
  INGILIZCE,
  DIKAB,
}

EnumCourse courseFromString(String value) {
  switch (value.toUpperCase()) {
    case 'TÜRKÇE':
      return EnumCourse.TURKCE;
    case 'MATEMATİK':
      return EnumCourse.MATEMATIK;
    case 'FEN BİLİMLERİ':
      return EnumCourse.FEN_BILIMLERI;
    case 'SOSYAL BİLGİLER':
      return EnumCourse.SOSYAL_BILGILER;
    case 'İNGİLİZCE':
      return EnumCourse.INGILIZCE;
    case 'DİKAB':
      return EnumCourse.DIKAB;
    default:
      throw Exception('Tanımsız course: $value');
  }
}

String courseToString(EnumCourse course) {
  switch (course) {
    case EnumCourse.TURKCE:
      return 'TÜRKÇE';
    case EnumCourse.MATEMATIK:
      return 'MATEMATİK';
    case EnumCourse.FEN_BILIMLERI:
      return 'FEN BİLİMLERİ';
    case EnumCourse.SOSYAL_BILGILER:
      return 'SOSYAL BİLGİLER';
    case EnumCourse.INGILIZCE:
      return 'İNGİLİZCE';
    case EnumCourse.DIKAB:
      return 'DİKAB';
  }
}

class DailyTracking {
  final int id;
  final DateTime date;
  final EnumCourse course;
  final int solvedQuestions;
  final int sinifId;
  final int ogrenciId;
  final int? egitimOgretimYiliId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Nested ilişkiler
  final Classes? sinif;
  final Student? ogrenci;

  DailyTracking({
    required this.id,
    required this.date,
    required this.course,
    required this.solvedQuestions,
    required this.sinifId,
    required this.ogrenciId,
    this.egitimOgretimYiliId,
    this.createdAt,
    this.updatedAt,
    this.sinif,
    this.ogrenci,
  });

  factory DailyTracking.fromJson(Map<String, dynamic> json) {
    return DailyTracking(
      id: json['id'],
      date: DateTime.parse(json['date']),
      course: courseFromString(json['course']),
      solvedQuestions: json['solved_questions'],
      sinifId: json['sinif_id'],
      ogrenciId: json['ogrenci_id'],
      egitimOgretimYiliId: json['egitim_ogretim_yili_id'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      sinif: json['sinif'] != null ? Classes.fromJson(json['sinif']) : null,
      ogrenci:
          json['ogrenci'] != null ? Student.fromJson(json['ogrenci']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'course': courseToString(course),
      'solved_questions': solvedQuestions,
      'sinif_id': sinifId,
      'ogrenci_id': ogrenciId,
      'egitim_ogretim_yili_id': egitimOgretimYiliId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'sinif': sinif?.toJson(),
      'ogrenci': ogrenci?.toJson(),
    };
  }
}
