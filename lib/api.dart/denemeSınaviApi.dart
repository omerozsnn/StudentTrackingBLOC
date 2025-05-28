import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ogrenci_takip_sistemi/models/deneme_sinavi_model.dart';

class ApiService {
  final String baseUrl;

  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? 'http://localhost:3000';

  // Tüm deneme sınavlarını getir
  Future<List<DenemeSinavi>> getAllDenemeSinavi() async {
    final response = await http.get(Uri.parse('$baseUrl/deneme-sinavi'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => DenemeSinavi.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load deneme sinavlari');
    }
  }

  // ID'ye göre tek bir deneme sınavı getir
  Future<DenemeSinavi> getDenemeSinaviById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/deneme-sinavi/$id'));

    if (response.statusCode == 200) {
      return DenemeSinavi.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load deneme sinavi');
    }
  }

  // Yeni bir deneme sınavı oluştur
  Future<DenemeSinavi> createDenemeSinavi(DenemeSinavi denemeSinavi) async {
    final response = await http.post(
      Uri.parse('$baseUrl/deneme-sinavi'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(denemeSinavi.toJson()),
    );

    if (response.statusCode == 201) {
      return DenemeSinavi.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create deneme sinavi');
    }
  }

  // Mevcut bir deneme sınavını güncelle
  Future<DenemeSinavi> updateDenemeSinavi(int id, DenemeSinavi denemeSinavi) async {
    final response = await http.put(
      Uri.parse('$baseUrl/deneme-sinavi/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(denemeSinavi.toJson()),
    );

    if (response.statusCode == 200) {
      return DenemeSinavi.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update deneme sinavi');
    }
  }

  // Bir deneme sınavını sil
  Future<http.Response> deleteDenemeSinavi(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/deneme-sinavi/$id'));

    if (response.statusCode == 200 || response.statusCode == 204) {
      return response;
    } else {
      throw Exception('Failed to delete deneme sinavi');
    }
  }

  // Deneme sınavı adına göre ID'yi getir
  Future<int> getDenemeSinaviIdByName(String denemeSinaviAdi) async {
    final encodedName = Uri.encodeComponent(denemeSinaviAdi);
    final response = await http
        .get(Uri.parse('$baseUrl/deneme-sinavi/get-id-by-name/$encodedName'));

    if (response.statusCode == 200) {
      return json.decode(response.body)['id'];
    } else {
      throw Exception('Failed to get deneme sinavi ID');
    }
  }

  // Belirli bir üniteye ait deneme sınavlarını getir
  Future<List<DenemeSinavi>> getDenemeSinaviByUnit(int unitId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/deneme-sinavi/unit/$unitId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => DenemeSinavi.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load deneme sinavlari for unit');
    }
  }

  // Deneme sınavının ünitesini güncelle
  Future<DenemeSinavi> updateDenemeSinaviUnit(int denemeSinaviId, int uniteId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/deneme-sinavi/$denemeSinaviId/unit'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'unite_id': uniteId}),
    );

    if (response.statusCode == 200) {
      return DenemeSinavi.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update deneme sinavi unit');
    }
  }

  // Deneme sınavına ait ünite bilgilerini getir
  Future<Map<String, dynamic>> getDenemeSinaviUnit(int denemeSinaviId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/deneme-sinavi/$denemeSinaviId/unit'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get deneme sinavi unit');
    }
  }
}
