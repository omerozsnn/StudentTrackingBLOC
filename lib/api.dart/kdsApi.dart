import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:ogrenci_takip_sistemi/models/kds_model.dart';
import 'package:flutter/foundation.dart';

class KDSApiService {
  final String baseUrl;

  KDSApiService({String? baseUrl})
      : baseUrl = baseUrl ?? 'http://localhost:3000';

  // Tüm KDS'leri getir
  Future<List<KDS>> getAllKDS() async {
    final response = await http.get(Uri.parse('$baseUrl/kds'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => KDS.fromJson(item)).toList();
    } else {
      throw Exception('KDS listesi yüklenemedi');
    }
  }

  // Belirli bir KDS'yi getir
  Future<KDS> getKDSById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/kds/$id'));

    if (response.statusCode == 200) {
      return KDS.fromJson(json.decode(response.body));
    } else {
      throw Exception('KDS getirilemedi');
    }
  }

  // Yeni bir KDS oluştur
  Future<KDS> addKDS(KDS kds) async {
    final response = await http.post(
      Uri.parse('$baseUrl/kds'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(kds.toJson()),
    );

    if (response.statusCode == 201) {
      return KDS.fromJson(json.decode(response.body));
    } else {
      throw Exception('KDS eklenemedi: ${response.body}');
    }
  }

  // Belirli bir KDS'yi güncelle
  Future<KDS> updateKDS(int id, KDS kds) async {
    final response = await http.put(
      Uri.parse('$baseUrl/kds/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(kds.toJson()),
    );

    if (response.statusCode == 200) {
      return KDS.fromJson(json.decode(response.body));
    } else {
      throw Exception('KDS güncellenemedi: ${response.body}');
    }
  }

  // KDS resimlerini yükle
  Future<List<KDSImage>> addKDSImages(int kdsId, List<File> images) async {
    var uri = Uri.parse('$baseUrl/kds/$kdsId/images');
    var request = http.MultipartRequest('POST', uri);
    request.fields['kds_id'] = kdsId.toString();

    for (var image in images) {
      var stream = http.ByteStream(image.openRead());
      var length = await image.length();
      var filename = path.basename(image.path);

      var multipartFile = http.MultipartFile(
        'images',
        stream,
        length,
        filename: filename,
        contentType: MediaType('image', filename.split('.').last),
      );

      request.files.add(multipartFile);
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => KDSImage.fromJson(item)).toList();
      } else {
        debugPrint(
            'KDS resimleri yüklenemedi. Durum kodu: ${response.statusCode}, Yanıt: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('KDS resimleri yüklenirken hata oluştu: $e');
      return [];
    }
  }

  // KDS'ye ait resimleri getir
  Future<List<KDSImage>> getKDSImages(int kdsId) async {
    final response = await http.get(Uri.parse('$baseUrl/kds/$kdsId/images'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => KDSImage.fromJson(item)).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('KDS resimleri getirilemedi');
    }
  }

  // KDS resim URL'i döndür
  String getKDSImageUrl(int imageId) {
    return '$baseUrl/kds/images/$imageId';
  }

  // Belirli bir KDS'yi sil
  Future<void> deleteKDS(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/kds/$id'));

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('KDS silinemedi');
    }
  }

  // KDS resmini sil
  Future<void> deleteKDSImage(int imageId) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/kds/images/$imageId'));

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('KDS resmi silinemedi');
    }
  }

  // Üniteye ait KDS'leri getir
  Future<List<KDS>> getKDSByUnit(int unitId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/kds/units/$unitId/kds'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => KDS.fromJson(item)).toList();
    } else {
      throw Exception('Üniteye ait KDS listesi yüklenemedi');
    }
  }
}
