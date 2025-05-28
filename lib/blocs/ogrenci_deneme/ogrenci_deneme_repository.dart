import 'dart:io';
import 'package:ogrenci_takip_sistemi/api.dart/ogrenciDenemeleriApi.dart';
import 'package:ogrenci_takip_sistemi/models/ogrenci_denemeleri_model.dart';
import 'package:flutter/foundation.dart';

class OgrenciDenemeRepository {
  final StudentExamRepository apiService;

  OgrenciDenemeRepository({required this.apiService});

  // Tüm öğrenci deneme sınavı sonuçlarını getir
  Future<List<StudentExamResult>> getAllStudentExamResults() async {
    try {
      return await apiService.getAllStudentExamResults();
    } catch (e) {
      debugPrint('Öğrenci deneme sonuçları getirilemedi: $e');
      throw Exception('Öğrenci deneme sonuçları getirilemedi: $e');
    }
  }

  // Belirli bir öğrencinin deneme sınavı sonuçlarını getir
  Future<List<StudentExamResult>> getStudentExamResultsByStudentId(int ogrenciId) async {
    try {
      return await apiService.getStudentExamResultsByStudentId(ogrenciId);
    } catch (e) {
      debugPrint('Öğrencinin deneme sonuçları getirilemedi: $e');
      throw Exception('Öğrencinin deneme sonuçları getirilemedi: $e');
    }
  }

  // Belirli bir deneme sınavına ait tüm öğrenci sonuçlarını getir
  Future<List<StudentExamResult>> getStudentsScoresByExam(int denemeSinaviId) async {
    try {
      return await apiService.getStudentsScoresByExam(denemeSinaviId);
    } catch (e) {
      debugPrint('Deneme sınavı sonuçları getirilemedi: $e');
      throw Exception('Deneme sınavı sonuçları getirilemedi: $e');
    }
  }

  // Yeni bir öğrenci deneme sınavı sonucu ekle
  Future<void> createStudentExamResult(StudentExamResult result) async {
    try {
      await apiService.createStudentExamResult(result);
    } catch (e) {
      debugPrint('Deneme sonucu eklenemedi: $e');
      throw Exception('Deneme sonucu eklenemedi: $e');
    }
  }

  // Öğrenci deneme sınavı sonucunu güncelle
  Future<void> updateStudentExamResult(
    int ogrenciId,
    int denemeSinaviId,
    Map<String, dynamic> data,
  ) async {
    try {
      await apiService.updateStudentExamResult(ogrenciId, denemeSinaviId, data);
    } catch (e) {
      debugPrint('Deneme sonucu güncellenemedi: $e');
      throw Exception('Deneme sonucu güncellenemedi: $e');
    }
  }

  // Öğrenci deneme sınavı sonucunu sil
  Future<void> deleteStudentExamResult(int id) async {
    try {
      await apiService.deleteStudentExamResult(id);
    } catch (e) {
      debugPrint('Deneme sonucu silinemedi: $e');
      throw Exception('Deneme sonucu silinemedi: $e');
    }
  }

  // Excel'den öğrenci deneme sonuçlarını yükle
  Future<void> importExamPointsFromExcel(File file) async {
    try {
      await apiService.importExamPointsFromExcel(file);
    } catch (e) {
      debugPrint('Excel\'den deneme sonuçları yüklenemedi: $e');
      throw Exception('Excel\'den deneme sonuçları yüklenemedi: $e');
    }
  }

  // Öğrenci deneme sınavı katılım bilgilerini getir
  Future<StudentExamParticipation> getStudentExamParticipation(int ogrenciId) async {
    try {
      return await apiService.getStudentExamParticipation(ogrenciId);
    } catch (e) {
      debugPrint('Öğrenci katılım bilgileri getirilemedi: $e');
      throw Exception('Öğrenci katılım bilgileri getirilemedi: $e');
    }
  }

  // Sınıf deneme sınavı ortalamalarını getir
  Future<ClassDenemeAverages> getClassDenemeAverages(int sinifId, int ogrenciId) async {
    try {
      return await apiService.getClassDenemeAverages(sinifId, ogrenciId);
    } catch (e) {
      debugPrint('Sınıf ortalamaları getirilemedi: $e');
      throw Exception('Sınıf ortalamaları getirilemedi: $e');
    }
  }
} 