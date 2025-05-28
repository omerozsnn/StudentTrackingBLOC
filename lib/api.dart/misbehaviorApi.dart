import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ogrenci_takip_sistemi/models/misbehaviour_model.dart';

class MisbehaviourApiService {
  final String baseUrl;

  MisbehaviourApiService({required this.baseUrl});

  // Yeni bir yaramazlık kaydı oluştur
  Future<Misbehaviour> addMisbehaviour(Misbehaviour misbehaviour) async {
    final response = await http.post(
      Uri.parse('$baseUrl/misbehaviour'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(misbehaviour.toJson()),
    );

    if (response.statusCode == 201) {
      return Misbehaviour.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add misbehaviour: ${response.body}');
    }
  }

  // Yaramazlık kaydını güncelle
  Future<Misbehaviour> updateMisbehaviour(
      int id, Misbehaviour misbehaviour) async {
    final response = await http.put(
      Uri.parse('$baseUrl/misbehaviour/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(misbehaviour.toJson()),
    );

    if (response.statusCode == 200) {
      return Misbehaviour.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update misbehaviour: ${response.body}');
    }
  }

  // Yaramazlık kaydını sil
  Future<void> deleteMisbehaviour(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/misbehaviour/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete misbehaviour: ${response.body}');
    }
  }

  // Tüm yaramazlık kayıtlarını getir
  Future<List<Misbehaviour>> getAllMisbehaviours() async {
    final response = await http.get(Uri.parse('$baseUrl/misbehaviour'));

    if (response.statusCode == 200) {
      List<dynamic> responseBody = json.decode(response.body);
      return responseBody.map((json) => Misbehaviour.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load misbehaviours: ${response.body}');
    }
  }

  // ID'ye göre bir yaramazlık kaydını getir
  Future<Misbehaviour> getMisbehaviourById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/misbehaviour/$id'));

    if (response.statusCode == 200) {
      return Misbehaviour.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load misbehaviour by ID: ${response.body}');
    }
  }

  // Yaramazlık adına göre ID'sini getir
  Future<int> getMisbehaviourIdByName(String yaramazlikAdi) async {
    final encodedName = Uri.encodeComponent(yaramazlikAdi);
    final response =
        await http.get(Uri.parse('$baseUrl/misbehaviour/name/$encodedName'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to get misbehaviour ID by name: ${response.body}');
    }
  }

  // Yaramazlık transfer et
  Future<Map<String, dynamic>> transferMisbehaviour(
      int fromYearId, int toYearId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/misbehaviour/transfer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'fromYearId': fromYearId, 'toYearId': toYearId}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to transfer misbehaviour: ${response.body}');
    }
  }
}
