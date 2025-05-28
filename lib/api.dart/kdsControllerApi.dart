import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:path/path.dart' as path;

class KDSApiService {
  final String baseUrl = 'http://localhost:3000';

  KDSApiService({baseUrl});

  // Tüm KDS'leri getir
  Future<List<dynamic>> getAllKDS() async {
    final response = await http.get(Uri.parse('$baseUrl/kds'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load KDS list');
    }
  }

  // Belirli bir KDS'yi getir
  Future<Map<String, dynamic>> getKDSById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/kds/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load KDS');
    }
  }

  // Yeni bir KDS oluştur
  Future<Map<String, dynamic>> addKDS(Map<String, dynamic> kdsData,
      {File? soruResimFile}) async {
    print('addKDS fonksiyonu çağrıldı. Veriler: $kdsData');

    var uri = Uri.parse('$baseUrl/kds');
    print('Hedef URI: $uri');

    var request = http.MultipartRequest('POST', uri);

    // Veri alanlarını ekle
    kdsData.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
        print('Alan eklendi: $key = ${value.toString()}');
      }
    });

    // Debug - tüm alanları yazdır
    print('Request alanları: ${request.fields}');

    // Resim dosyası varsa ekle
    if (soruResimFile != null) {
      var stream = http.ByteStream(soruResimFile.openRead());
      var length = await soruResimFile.length();
      var filename = path.basename(soruResimFile.path);
      var multipartFile = http.MultipartFile(
        'soru_resim',
        stream,
        length,
        filename: filename,
        contentType: MediaType('image', filename.split('.').last),
      );

      request.files.add(multipartFile);
      print('Dosya eklendi: $filename');
    }

    try {
      // Direk HTTP isteği gönder (multipart request kullanmadan)
      if (soruResimFile == null) {
        // Alternatif yaklaşım - normal HTTP POST isteği
        var response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(kdsData),
        );

        print('Yanıt kodu: ${response.statusCode}');
        print('Yanıt: ${response.body}');

        if (response.statusCode != 201) {
          throw Exception('Failed to add KDS: ${response.body}');
        }

        return jsonDecode(response.body);
      } else {
        // Multipart request ile devam et
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        print('Yanıt kodu: ${response.statusCode}');
        print('Yanıt: ${response.body}');

        if (response.statusCode != 201) {
          throw Exception('Failed to add KDS: ${response.body}');
        }

        return jsonDecode(response.body);
      }
    } catch (e) {
      print('API isteği sırasında hata: $e');
      rethrow;
    }
  }

  // Belirli bir KDS'yi güncelle
  Future<void> updateKDS(int id, Map<String, dynamic> kdsData,
      {File? soruResimFile}) async {
    var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/kds/$id'));

    // Veri alanlarını ekle
    kdsData.forEach((key, value) {
      // answersheet'i JSON string'e dönüştür
      if (key == 'answersheet' && value != null) {
        request.fields[key] = json.encode(value);
      } else if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    // Resim dosyası varsa ekle
    if (soruResimFile != null) {
      var stream = http.ByteStream(soruResimFile.openRead());
      var length = await soruResimFile.length();
      var filename = basename(soruResimFile.path);
      var multipartFile = http.MultipartFile(
        'soru_resim',
        stream,
        length,
        filename: filename,
        contentType: MediaType('image', filename.split('.').last),
      );

      request.files.add(multipartFile);
    }

    var response = await request.send();

    if (response.statusCode != 200) {
      var responseStr = await response.stream.bytesToString();
      throw Exception('Failed to update KDS: ${responseStr}');
    }
  }

  // Belirli bir KDS'yi sil
  Future<void> deleteKDS(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/kds/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete KDS');
    }
  }

  // Üniteye ait KDS'leri getir
  Future<List<dynamic>> getKDSByUnit(int unitId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/kds/units/$unitId/kds'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load KDS by unit');
    }
  }

  Future<String> getKDSImageUrl(int id) async {
    try {
      // Doğrudan resim endpoint URL'ini oluştur - backend'de /kds/{id}/image endpoint'ini kullan
      return '$baseUrl/kds/$id/image';
    } catch (e) {
      throw Exception('Error creating KDS image URL: $e');
    }
  }
}
