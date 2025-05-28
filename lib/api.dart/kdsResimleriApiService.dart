import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class KDSResimleriApiService {
  final String baseUrl;
  KDSResimleriApiService({required this.baseUrl});

  // GET /kds-images - Tüm KDS resimlerini getir
  Future<List<dynamic>> getAllKDSResimleri() async {
    final response = await http.get(Uri.parse('$baseUrl/kds-images'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception(
          'KDS resimleri yüklenemedi. Status code: ${response.statusCode}');
    }
  }

  // GET /kds/:kdsId/images - Belirli bir KDS'ye ait resimleri getir
  Future<List<dynamic>> getImagesByKDS(int kdsId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/kds/$kdsId/images'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else if (response.statusCode == 404) {
        // 404 durumunda boş liste döndür - resim bulunamadı hatası normal
        return [];
      } else {
        throw Exception(
            'KDS id: $kdsId resimleri yüklenemedi. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('KDS resimleri alınırken hata: $error');
      // Eğer 404 hatası ise boş liste döndür, diğer hatalarda exception fırlat
      if (error.toString().contains('404')) {
        return [];
      }
      throw Exception('KDS id: $kdsId resimleri yüklenemedi. Hata: $error');
    }
  }

  // POST /kds/:kdsId/images - Çoklu resim yükle
  Future<dynamic> addKDSResimleri(int kdsId, List<File> images) async {
    print(
        'addKDSResimleri fonksiyonu çağrıldı. KDS ID: $kdsId, Resim sayısı: ${images.length}');

    var uri = Uri.parse('$baseUrl/kds/$kdsId/images');
    print('Hedef URI: $uri');

    var request = http.MultipartRequest('POST', uri);

    // KDS ID'sini request body'sine ekle
    request.fields['kds_id'] = kdsId.toString();

    // Her dosyayı request'e ekle
    for (var i = 0; i < images.length; i++) {
      File image = images[i];
      print('Resim ${i + 1} ekleniyor: ${image.path}');

      try {
        var stream = http.ByteStream(image.openRead());
        var length = await image.length();
        var filename = path.basename(image.path);

        print('Dosya: $filename, Boyut: $length bytes');

        var multipartFile = http.MultipartFile(
          'images', // Backend'teki form alanı adı - controller'da req.files erişimi için
          stream,
          length,
          filename: filename,
          contentType: MediaType('image', filename.split('.').last),
        );

        request.files.add(multipartFile);
        print('Dosya başarıyla eklenmiş olmalı: $filename');
      } catch (e) {
        print('Dosya eklenirken hata: $e');
      }
    }

    print('Tüm dosyalar eklendi. Request gönderiliyor...');
    print('Request dosya sayısı: ${request.files.length}');

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Yanıt kodu: ${response.statusCode}');
      print('Yanıt: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'KDS resimleri yüklenemedi. Status code: ${response.statusCode}, Hata: ${response.body}');
      }
    } catch (e) {
      print('Resim yükleme isteği sırasında hata: $e');
      rethrow;
    }
  }

  // GET /kds/images/:id - Resim dosyasını göstermek için URL oluşturucu
  String getKDSResimUrl(int imageId) {
    return '$baseUrl/kds/images/$imageId';
  }

  // DELETE /kds/images/:id - Belirli bir KDS resmini sil
  Future<void> deleteKDSResim(int imageId) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/kds/images/$imageId'));
    if (response.statusCode != 204) {
      throw Exception(
          'KDS resmi silinemedi. Status code: ${response.statusCode}');
    }
  }
}
