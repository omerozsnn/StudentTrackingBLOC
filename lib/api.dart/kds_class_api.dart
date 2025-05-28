import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ogrenci_takip_sistemi/models/kds_class_model.dart';

class KdsClassApiService {
  final String baseUrl;

  KdsClassApiService({String? baseUrl})
      : baseUrl = baseUrl ?? 'http://localhost:3000';

  // Bir sınıfa atanmış tüm KDS'leri getir
  Future<List<KdsClass>> getKDSByClass(int classId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kds-class/class/$classId/kds'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => KdsClass.fromJson(item)).toList();
      } else {
        debugPrint('API Hatası: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Sınıfa ait KDS listesi yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('KDS sınıf listesi çekme hatası: $e');
      throw Exception('Sınıfa ait KDS listesi yüklenemedi: $e');
    }
  }

  // Bir KDS'yi bir sınıfa ata
  Future<KdsClass> assignKDSClass(int kdsId, int classId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kds-class'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'kds_id': kdsId,
          'sinif_id': classId,
        }),
      );

      if (response.statusCode == 201) {
        return KdsClass.fromJson(json.decode(response.body));
      } else {
        debugPrint('API Hatası: ${response.statusCode} - ${response.body}');
        throw Exception('KDS sınıfa atanamadı: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('KDS sınıfa atama hatası: $e');
      throw Exception('KDS sınıfa atanamadı: $e');
    }
  }

  // Toplu atama: Bir KDS'yi 6. sınıf seviyesindeki tüm sınıflara ata
  Future<bool> assignKDSToSixthGrade(int kdsId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kds-class/assign-kds-to-sixth-grade'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'kds_id': kdsId}),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        debugPrint('API Hatası: ${response.statusCode} - ${response.body}');
        throw Exception('KDS 6. sınıflara atanamadı: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('KDS 6. sınıflara atama hatası: $e');
      throw Exception('KDS 6. sınıflara atanamadı: $e');
    }
  }

  // Toplu atama: Bir KDS'yi 7. sınıf seviyesindeki tüm sınıflara ata
  Future<bool> assignKDSToSeventhGrade(int kdsId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kds-class/assign-kds-to-seventh-grade'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'kds_id': kdsId}),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        debugPrint('API Hatası: ${response.statusCode} - ${response.body}');
        throw Exception('KDS 7. sınıflara atanamadı: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('KDS 7. sınıflara atama hatası: $e');
      throw Exception('KDS 7. sınıflara atanamadı: $e');
    }
  }

  // Toplu atama: Bir KDS'yi 8. sınıf seviyesindeki tüm sınıflara ata
  Future<bool> assignKDSToEighthGrade(int kdsId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/kds-class/assign-kds-to-eighth-grade'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'kds_id': kdsId}),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        debugPrint('API Hatası: ${response.statusCode} - ${response.body}');
        throw Exception('KDS 8. sınıflara atanamadı: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('KDS 8. sınıflara atama hatası: $e');
      throw Exception('KDS 8. sınıflara atanamadı: $e');
    }
  }

  // Bir KDS'yi bir sınıftan kaldır
  Future<bool> deleteKDSFromClass(int kdsId, int classId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/kds-class/kds/$kdsId/class/$classId'),
      );

      if (response.statusCode == 204) {
        return true;
      } else {
        debugPrint('API Hatası: ${response.statusCode} - ${response.body}');
        throw Exception('KDS sınıftan kaldırılamadı: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('KDS sınıftan kaldırma hatası: $e');
      throw Exception('KDS sınıftan kaldırılamadı: $e');
    }
  }
}
