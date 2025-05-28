import 'package:ogrenci_takip_sistemi/api.dart/sınıfDenemeleriApi.dart';
import 'package:flutter/foundation.dart';

class SinifDenemeRepository {
  final ApiService apiService;

  SinifDenemeRepository({required this.apiService});

  // Tüm sınıf-deneme ilişkilerini getir
  Future<List<dynamic>> getAllSinifDenemeleri() async {
    try {
      return await apiService.getAllSinifDenemeleri();
    } catch (e) {
      debugPrint('Sınıf-deneme ilişkileri getirilemedi: $e');
      throw Exception('Sınıf-deneme ilişkileri getirilemedi: $e');
    }
  }

  // Belirli bir sınıf-deneme ilişkisini getir
  Future<Map<String, dynamic>> getSinifDenemeleriById(int sinifId, int denemeSinaviId) async {
    try {
      return await apiService.getSinifDenemeleriById(sinifId, denemeSinaviId);
    } catch (e) {
      debugPrint('Sınıf-deneme ilişkisi getirilemedi: $e');
      throw Exception('Sınıf-deneme ilişkisi getirilemedi: $e');
    }
  }

  // Yeni bir sınıf-deneme ilişkisi oluştur
  Future<void> createSinifDenemeleri(Map<String, dynamic> data) async {
    try {
      await apiService.createSinifDenemeleri(data);
    } catch (e) {
      debugPrint('Sınıf-deneme ilişkisi oluşturulamadı: $e');
      throw Exception('Sınıf-deneme ilişkisi oluşturulamadı: $e');
    }
  }

  // Bir sınıf-deneme ilişkisini güncelle
  Future<void> updateSinifDenemeleri(int sinifId, int denemeSinaviId, Map<String, dynamic> data) async {
    try {
      await apiService.updateSinifDenemeleri(sinifId, denemeSinaviId, data);
    } catch (e) {
      debugPrint('Sınıf-deneme ilişkisi güncellenemedi: $e');
      throw Exception('Sınıf-deneme ilişkisi güncellenemedi: $e');
    }
  }

  // Bir sınıf-deneme ilişkisini sil
  Future<void> deleteSinifDenemeleri(int sinifId, int denemeSinaviId) async {
    try {
      await apiService.deleteSinifDenemeleri(sinifId, denemeSinaviId);
    } catch (e) {
      debugPrint('Sınıf-deneme ilişkisi silinemedi: $e');
      throw Exception('Sınıf-deneme ilişkisi silinemedi: $e');
    }
  }

  // Belirli bir deneme sınavına ait sınıfları getir
  Future<List<dynamic>> getClassesByExam(int denemeSinaviId) async {
    try {
      return await apiService.getClassesByExam(denemeSinaviId);
    } catch (e) {
      debugPrint('Deneme sınavına ait sınıflar getirilemedi: $e');
      throw Exception('Deneme sınavına ait sınıflar getirilemedi: $e');
    }
  }

  // Belirli bir sınıfa ait deneme sınavlarını getir
  Future<List<dynamic>> getExamsByClass(int sinifId) async {
    try {
      return await apiService.getExamsByClass(sinifId);
    } catch (e) {
      debugPrint('Sınıfa ait deneme sınavları getirilemedi: $e');
      throw Exception('Sınıfa ait deneme sınavları getirilemedi: $e');
    }
  }

  // Tüm 6. sınıflara Deneme Sınavı ataması yap
  Future<void> assignExamToSixthGrade(Map<String, dynamic> data) async {
    try {
      await apiService.assignExamToSixthGrade(data);
    } catch (e) {
      debugPrint('6. sınıflara deneme sınavı atanamadı: $e');
      throw Exception('6. sınıflara deneme sınavı atanamadı: $e');
    }
  }

  // Tüm 5. sınıflara Deneme Sınavı ataması yap
  Future<void> assignExamToFifthGrade(Map<String, dynamic> data) async {
    try {
      await apiService.assignExamToFifthGrade(data);
    } catch (e) {
      debugPrint('5. sınıflara deneme sınavı atanamadı: $e');
      throw Exception('5. sınıflara deneme sınavı atanamadı: $e');
    }
  }

  // Tüm 7. sınıflara Deneme Sınavı ataması yap
  Future<void> assignExamToSeventhGrade(Map<String, dynamic> data) async {
    try {
      await apiService.assignExamToSeventhGrade(data);
    } catch (e) {
      debugPrint('7. sınıflara deneme sınavı atanamadı: $e');
      throw Exception('7. sınıflara deneme sınavı atanamadı: $e');
    }
  }

  // Tüm 8. sınıflara Deneme Sınavı ataması yap
  Future<void> assignExamToEighthGrade(Map<String, dynamic> data) async {
    try {
      await apiService.assignExamToEighthGrade(data);
    } catch (e) {
      debugPrint('8. sınıflara deneme sınavı atanamadı: $e');
      throw Exception('8. sınıflara deneme sınavı atanamadı: $e');
    }
  }

  // Belirli bir sınıfa deneme sınavı ataması yap
  Future<void> assignExamToSpecificClass(int examId, int classId) async {
    try {
      await apiService.assignExamToSpecificClass(examId, classId);
    } catch (e) {
      debugPrint('Belirli sınıfa deneme sınavı atanamadı: $e');
      throw Exception('Belirli sınıfa deneme sınavı atanamadı: $e');
    }
  }
} 