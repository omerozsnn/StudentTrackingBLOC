import 'dart:convert';
import 'package:http/http.dart' as http;

// Özel hata sınıfı
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}${details != null ? '\nDetails: $details' : ''}';
  }
}

class ApiService {
  final String baseUrl;

  ApiService({String? baseUrl})
      : this.baseUrl = baseUrl ?? 'http://localhost:3000';

  // API yanıtını işle ve hata durumunu kontrol et
  dynamic _handleResponse(http.Response response, String operation) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return null;
        return json.decode(response.body);
      }

      String details = '';
      try {
        final errorData = json.decode(response.body);
        details = errorData['message'] ?? errorData['error'] ?? response.body;
      } catch (_) {
        details = response.body;
      }

      throw ApiException(
        message: 'İşlem başarısız: $operation',
        statusCode: response.statusCode,
        details: details,
      );
    } on FormatException {
      throw ApiException(
        message: 'Geçersiz yanıt formatı: $operation',
        statusCode: response.statusCode,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Beklenmeyen hata: $operation',
        details: e.toString(),
      );
    }
  }

  // Yeni bir Dua Sure kaydı oluştur
  Future<void> addPrayerSurahTracking(
      Map<String, dynamic> prayerSurahTrackingData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/prayerSurahTracking'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(prayerSurahTrackingData),
      );

      _handleResponse(response, 'Dua/Sure değerlendirmesi ekleme');
    } catch (e) {
      throw ApiException(
        message: 'Dua/Sure değerlendirmesi eklenirken hata oluştu',
        details: e.toString(),
      );
    }
  }

  // Dua Sure kaydını güncelle
  Future<void> updatePrayerSurahTracking(
      int id, Map<String, dynamic> prayerSurahTrackingData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/prayerSurahTracking/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(prayerSurahTrackingData),
      );

      _handleResponse(response, 'Dua/Sure değerlendirmesi güncelleme');
    } catch (e) {
      throw ApiException(
        message: 'Dua/Sure değerlendirmesi güncellenirken hata oluştu',
        details: e.toString(),
      );
    }
  }

  // Dua Sure kaydını sil
  Future<void> deletePrayerSurahTracking(int id) async {
    try {
      final response =
          await http.delete(Uri.parse('$baseUrl/prayerSurahTracking/$id'));

      _handleResponse(response, 'Dua/Sure değerlendirmesi silme');
    } catch (e) {
      throw ApiException(
        message: 'Dua/Sure değerlendirmesi silinirken hata oluştu',
        details: e.toString(),
      );
    }
  }

  // Tüm Dua Sure kayıtlarını getir
  Future<List<Map<String, dynamic>>> getPrayerSurahTrackings() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/prayerSurahTracking'));

      final data =
          _handleResponse(response, 'Dua/Sure değerlendirmelerini getirme');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw ApiException(
        message: 'Dua/Sure değerlendirmeleri getirilirken hata oluştu',
        details: e.toString(),
      );
    }
  }

  // Belirli bir Dua Sure kaydını ID'ye göre getir
  Future<Map<String, dynamic>> getPrayerSurahTrackingById(int id) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/prayerSurahTracking/$id'));

      final data =
          _handleResponse(response, 'Dua/Sure değerlendirmesi getirme');
      return Map<String, dynamic>.from(data);
    } catch (e) {
      throw ApiException(
        message: 'Dua/Sure değerlendirmesi getirilirken hata oluştu',
        details: e.toString(),
      );
    }
  }

  // Öğrenci ID'sine göre Dua Sure kayıtlarını getir
  Future<List<Map<String, dynamic>>> getPrayerSurahStudentById(
      int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/prayerSurahStudent/student/$studentId'),
      );

      final data =
          _handleResponse(response, 'Öğrenci Dua/Sure bilgilerini getirme');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw ApiException(
        message: 'Öğrenci Dua/Sure bilgileri getirilirken hata oluştu',
        details: e.toString(),
      );
    }
  }

  // Öğrencinin dua/sure takip bilgilerini getir
  Future<List<Map<String, dynamic>>> getPrayerSurahTrackingsByStudentId(
      int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/students/$studentId/prayer-surah-trackings'),
      );

      final data =
          _handleResponse(response, 'Öğrenci değerlendirmelerini getirme');
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw ApiException(
        message: 'Öğrenci değerlendirmeleri getirilirken hata oluştu',
        details: e.toString(),
      );
    }
  }

  // Öğrenci ve Dua/Sure ID'sine göre değerlendirme sil
  Future<void> deletePrayerSurahTrackingByIds(
      int studentId, int prayerSurahId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/students/$studentId/prayer-surah-trackings/$prayerSurahId'),
      );

      _handleResponse(response, 'Değerlendirme silme');
    } catch (e) {
      throw ApiException(
        message: 'Değerlendirme silinirken hata oluştu',
        details: e.toString(),
      );
    }
  }

  // Toplu değerlendirme ekleme/güncelleme
  Future<void> bulkUpdatePrayerSurahTracking(
      List<Map<String, dynamic>> trackings) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/prayerSurahTracking/bulk'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(trackings), // Artık sadece listeyi gönderiyoruz
      );

      _handleResponse(response, 'Toplu değerlendirme güncelleme');
    } catch (e) {
      throw ApiException(
        message: 'Toplu değerlendirme güncellenirken hata oluştu',
        details: e.toString(),
      );
    }
  }
}
