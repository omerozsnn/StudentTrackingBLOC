import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ogrenci_okul_denemesi_model.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // Tüm öğrenci okul denemelerini listele
  Future<List<OgrenciOkulDenemesi>> getAllOgrenciOkulDenemeleri() async {
    try {
      final url = '$baseUrl/ogrenci-okul-denemeleri';
      print('API isteği: GET $url');

      final response = await http.get(Uri.parse(url));
      print('Yanıt kodu: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        print('Veri alındı: ${jsonData.length} adet sonuç');

        // API yanıtı bir Map ve data içeriyorsa, data içindeki listeyi kullan
        final responseData = json.decode(response.body);
        if (responseData is Map && responseData.containsKey('data')) {
          jsonData = responseData['data'];
          print('API Yanıtından data listesi çıkarılıyor...');
        }

        return jsonData
            .map((item) => OgrenciOkulDenemesi.fromJson(item))
            .toList();
      } else {
        print('Hata yanıtı: ${response.body}');
        throw Exception('Failed to load öğrenci okul denemeleri');
      }
    } catch (e) {
      print('API Hatası (getAllOgrenciOkulDenemeleri): $e');
      throw Exception('API Error: $e');
    }
  }

  // Belirli bir öğrencinin deneme sonuçlarını listele
  Future<List<OgrenciOkulDenemesi>> getOgrenciOkulDenemeleriByStudentId(
      int ogrenciId) async {
    try {
      final url = '$baseUrl/ogrenci-okul-denemeleri/ogrenci/$ogrenciId';
      print('API isteği: GET $url');

      final response = await http.get(Uri.parse(url));
      print('Yanıt kodu: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        print('Veri alındı: ${jsonData.length} adet sonuç');

        // API yanıtı bir Map ve data içeriyorsa, data içindeki listeyi kullan
        final responseData = json.decode(response.body);
        if (responseData is Map && responseData.containsKey('data')) {
          jsonData = responseData['data'];
          print('API Yanıtından data listesi çıkarılıyor...');
        }

        return jsonData
            .map((item) => OgrenciOkulDenemesi.fromJson(item))
            .toList();
      } else if (response.statusCode == 404) {
        // 404 (Bulunamadı) durumunda hata fırlatmak yerine boş liste döndür
        print('Öğrenci için sonuç bulunamadı, boş liste döndürülüyor');
        return [];
      } else {
        print('Hata yanıtı: ${response.body}');
        throw Exception('Failed to load denemeleri for student');
      }
    } catch (e) {
      print('API Hatası (getOgrenciOkulDenemeleriByStudentId): $e');
      throw Exception('API Error: $e');
    }
  }

  // Upsert işlemi için tek bir fonksiyon
  Future<OgrenciOkulDenemesi> upsertOgrenciOkulDeneme(
      OgrenciOkulDenemesi data) async {
    try {
      // First check if the exam exists
      final checkUrl = '$baseUrl/okul-denemeleri/${data.okulDenemesiId}';
      print('API isteği: GET $checkUrl (Sınav kontrolü)');

      final checkResponse = await http.get(Uri.parse(checkUrl));

      if (checkResponse.statusCode != 200) {
        print(
            'Sınav bulunamadı: ${checkResponse.statusCode} - ${checkResponse.body}');
        throw Exception(
            'Sınav bulunamadı: ID ${data.okulDenemesiId}. Lütfen önce sınavları yükleyin.');
      }

      // API PARAMETRE DÜZELTMESİ: Backend'in beklediği parametre adlarını kullanıyoruz
      Map<String, dynamic> jsonData = {
        'ogrenci_id': data.ogrenciId,
        'okul_deneme_sinavi_id': data
            .okulDenemesiId, // Anahtar değişiklik: okul_denemesi_id -> okul_deneme_sinavi_id
        if (data.dogruSayisi != null) 'dogru_sayisi': data.dogruSayisi,
        if (data.yanlisSayisi != null) 'yanlis_sayisi': data.yanlisSayisi,
        if (data.netSayisi != null) 'net_sayisi': data.netSayisi,
        if (data.puan != null) 'puan': data.puan,
        if (data.tarih != null) 'tarih': data.tarih!.toIso8601String(),
        if (data.aciklama != null) 'aciklama': data.aciklama,
        if (data.katildi != null) 'katildi': data.katildi,
        if (data.id != null) 'id': data.id,
      };

      // Continue with creating/updating the result
      final url = '$baseUrl/ogrenci-okul-denemeleri';
      print('API isteği: POST $url');
      print(
          'Gönderilen veri: ${json.encode(jsonData)}'); // Düzeltilmiş JSON verisi

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
            jsonData), // Model'in toJson() metodu yerine özel JSON verisi kullanıyoruz
      );
      print('Yanıt kodu: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Oluşturulan/güncellenen veri: ${response.body}');

        // API yanıtının yapısını ayrıştır
        final responseData = json.decode(response.body);

        // API yanıtı data içinde mi yoksa doğrudan mı kontrol et
        if (responseData is Map && responseData.containsKey('data')) {
          // 'data' içindeki verileri kullan
          print('API Yanıtından data objesi çıkarılıyor...');
          return OgrenciOkulDenemesi.fromJson(responseData['data']);
        } else {
          // Doğrudan yanıtı kullan
          return OgrenciOkulDenemesi.fromJson(responseData);
        }
      } else {
        print('Hata yanıtı: ${response.body}');
        throw Exception('Failed to save öğrenci okul deneme');
      }
    } catch (e) {
      print('API Hatası (upsertOgrenciOkulDeneme): $e');
      throw Exception('API Error: $e');
    }
  }

  // Öğrenci deneme sonucunu sil
  Future<void> deleteOgrenciOkulDeneme(int id) async {
    try {
      final url = '$baseUrl/ogrenci-okul-denemeleri/$id';
      print('API isteği: DELETE $url');

      final response = await http.delete(Uri.parse(url));
      print('Yanıt kodu: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('Hata yanıtı: ${response.body}');
        throw Exception('Failed to delete öğrenci okul deneme');
      }
    } catch (e) {
      print('API Hatası (deleteOgrenciOkulDeneme): $e');
      throw Exception('API Error: $e');
    }
  }

  Future<Map<String, dynamic>> getClassOkulDenemeAverages(
      int sinifId, int ogrenciId) async {
    try {
      final url =
          '$baseUrl/ogrenci-okul-denemeleri/class/$sinifId/student/$ogrenciId/avarages';
      print('API isteği: GET $url');

      final response = await http.get(Uri.parse(url));
      print('Yanıt kodu: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('Veri alındı: ${data.keys.length} adet veri');
        return data;
      } else {
        print('Hata yanıtı: ${response.body}');
        throw Exception('Sınıf ortalamaları alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      print('API Hatası (getClassOkulDenemeAverages): $e');
      throw Exception('Sınıf ortalamaları alınırken hata oluştu: $e');
    }
  }
}
