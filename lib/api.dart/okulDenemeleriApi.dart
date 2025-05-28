import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/okul_denemesi_model.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // Tüm okul denemelerini getir (sayfalama ile)
  Future<Map<String, dynamic>> getAllOkulDenemeleri(
      {int page = 1, int limit = 10}) async {
    final response = await http
        .get(Uri.parse('$baseUrl/okul-denemeleri?page=$page&limit=$limit'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data['data'] != null) {
        List<dynamic> denemeList = data['data'];
        List<OkulDenemesi> denemeler = denemeList
            .map((denemeJson) => OkulDenemesi.fromJson(denemeJson))
            .toList();
        return {
          'data': denemeler,
          'totalItems': data['totalItems'],
          'totalPages': data['totalPages'],
          'currentPage': data['currentPage'],
        };
      }
      return data;
    } else {
      throw Exception('Failed to load okul denemeleri');
    }
  }

  // Belirli bir okul denemesini getir
  Future<OkulDenemesi> getOkulDenemesiById(int id) async {
    try {
      final url = '$baseUrl/okul-denemeleri/$id';
      print('API isteği: GET $url (getOkulDenemesiById)');

      final response = await http.get(Uri.parse(url));
      print('Yanıt kodu: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Yanıt: ${response.body}');
        return OkulDenemesi.fromJson(json.decode(response.body));
      } else {
        print('Hata yanıtı: ${response.body}');
        throw Exception('Failed to load okul denemesi with ID: $id');
      }
    } catch (e) {
      print('getOkulDenemesiById API Hatası: $e');
      rethrow;
    }
  }

  // Yeni bir okul denemesi oluştur
  Future<OkulDenemesi> createOkulDenemesi(OkulDenemesi deneme) async {
    try {
      final url = '$baseUrl/okul-denemeleri';
      print('API isteği: POST $url');
      print('Gönderilen veri: ${json.encode(deneme.toJson())}');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(deneme.toJson()),
      );
      print('Yanıt kodu: ${response.statusCode}');

      if (response.statusCode == 201) {
        print('Oluşturulan sınav: ${response.body}');
        return OkulDenemesi.fromJson(json.decode(response.body));
      } else {
        print('Hata yanıtı: ${response.body}');
        throw Exception('Failed to create okul denemesi');
      }
    } catch (e) {
      print('createOkulDenemesi API Hatası: $e');
      rethrow;
    }
  }

  // Belirli bir okul denemesini güncelle
  Future<OkulDenemesi> updateOkulDenemesi(OkulDenemesi deneme) async {
    if (deneme.id == null) {
      throw Exception('Cannot update okul denemesi without id');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/okul-denemeleri/${deneme.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(deneme.toJson()),
    );
    if (response.statusCode == 200) {
      return OkulDenemesi.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update okul denemesi');
    }
  }

  // Belirli bir okul denemesini sil
  Future<void> deleteOkulDenemesi(int id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/okul-denemeleri/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete okul denemesi');
    }
  }
}
