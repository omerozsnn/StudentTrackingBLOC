import 'package:flutter/foundation.dart';
import 'package:ogrenci_takip_sistemi/api.dart/kds_class_api.dart';
import 'package:ogrenci_takip_sistemi/models/kds_class_model.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';

class KdsClassRepository {
  final KdsClassApiService apiService;

  KdsClassRepository({required this.apiService});

  // Bir sınıfa atanmış tüm KDS'leri getir
  Future<List<KdsClass>> getKDSByClass(int classId) async {
    try {
      return await apiService.getKDSByClass(classId);
    } catch (e) {
      debugPrint('Repository: Sınıfa ait KDS listesi alınamadı: $e');
      throw Exception('Sınıfa ait KDS listesi alınamadı: $e');
    }
  }

  // Bir KDS'yi bir sınıfa ata
  Future<KdsClass> assignKDSClass(int kdsId, int classId) async {
    try {
      return await apiService.assignKDSClass(kdsId, classId);
    } catch (e) {
      debugPrint('Repository: KDS sınıfa atanamadı: $e');
      throw Exception('KDS sınıfa atanamadı: $e');
    }
  }

  // Toplu atama: Bir KDS'yi 6. sınıf seviyesindeki tüm sınıflara ata
  Future<bool> assignKDSToSixthGrade(int kdsId) async {
    try {
      return await apiService.assignKDSToSixthGrade(kdsId);
    } catch (e) {
      debugPrint('Repository: KDS 6. sınıflara atanamadı: $e');
      throw Exception('KDS 6. sınıflara atanamadı: $e');
    }
  }

  // Toplu atama: Bir KDS'yi 7. sınıf seviyesindeki tüm sınıflara ata
  Future<bool> assignKDSToSeventhGrade(int kdsId) async {
    try {
      return await apiService.assignKDSToSeventhGrade(kdsId);
    } catch (e) {
      debugPrint('Repository: KDS 7. sınıflara atanamadı: $e');
      throw Exception('KDS 7. sınıflara atanamadı: $e');
    }
  }

  // Toplu atama: Bir KDS'yi 8. sınıf seviyesindeki tüm sınıflara ata
  Future<bool> assignKDSToEighthGrade(int kdsId) async {
    try {
      return await apiService.assignKDSToEighthGrade(kdsId);
    } catch (e) {
      debugPrint('Repository: KDS 8. sınıflara atanamadı: $e');
      throw Exception('KDS 8. sınıflara atanamadı: $e');
    }
  }

  // Bir KDS'yi bir sınıftan kaldır
  Future<bool> deleteKDSFromClass(int kdsId, int classId) async {
    try {
      return await apiService.deleteKDSFromClass(kdsId, classId);
    } catch (e) {
      debugPrint('Repository: KDS sınıftan kaldırılamadı: $e');
      throw Exception('KDS sınıftan kaldırılamadı: $e');
    }
  }
}
