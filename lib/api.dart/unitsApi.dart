import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ogrenci_takip_sistemi/models/units_model.dart';

class ApiService {
  final String baseUrl;
  
  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? 'http://localhost:3000';

  // Tüm üniteleri getir
  Future<List<Unit>> getAllUnits() async {
    final response = await http.get(Uri.parse('$baseUrl/units'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Unit.fromJson(item)).toList();
    } else {
      throw Exception('Üniteler getirilemedi');
    }
  }

  // Belirli bir üniteyi getir
  Future<Unit> getUnitById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/units/$id'));

    if (response.statusCode == 200) {
      return Unit.fromJson(json.decode(response.body));
    } else {
      throw Exception('Ünite getirilemedi');
    }
  }

  // Yeni bir ünite ekle
  Future<Unit> addUnit(Unit unit) async {
    final response = await http.post(
      Uri.parse('$baseUrl/units'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(unit.toJson()),
    );

    if (response.statusCode == 201) {
      return Unit.fromJson(json.decode(response.body));
    } else {
      throw Exception('Ünite eklenemedi');
    }
  }

  // String olarak ünite adı ile ekleme (eski API uyumluluğu için)
  Future<Unit> addUnitByName(String unitName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/units'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'ünite_adı': unitName}),
    );

    if (response.statusCode == 201) {
      return Unit.fromJson(json.decode(response.body));
    } else {
      throw Exception('Ünite eklenemedi');
    }
  }

  // Belirli bir üniteyi güncelle
  Future<Unit> updateUnit(int id, Unit unit) async {
    final response = await http.put(
      Uri.parse('$baseUrl/units/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(unit.toJson()),
    );

    if (response.statusCode == 200) {
      return Unit.fromJson(json.decode(response.body));
    } else {
      throw Exception('Ünite güncellenemedi');
    }
  }

  // String olarak ünite adı ile güncelleme (eski API uyumluluğu için)
  Future<Unit> updateUnitByName(int id, String unitName) async {
    final response = await http.put(
      Uri.parse('$baseUrl/units/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'ünite_adı': unitName}),
    );

    if (response.statusCode == 200) {
      return Unit.fromJson(json.decode(response.body));
    } else {
      throw Exception('Ünite güncellenemedi');
    }
  }

  // Ünite adına göre ünite id getir
  Future<Unit> getUnitByName(String unitName) async {
    final response = await http.get(Uri.parse('$baseUrl/units/name/$unitName'));

    if (response.statusCode == 200) {
      return Unit.fromJson(json.decode(response.body));
    } else {
      throw Exception('Ünite getirilemedi');
    }
  }

  // Belirli bir üniteyi sil
  Future<http.Response> deleteUnit(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/units/$id'));

    if (response.statusCode == 204 || response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Ünite silinemedi');
    }
  }

  // Birden fazla ünite ekleme
  Future<List<Unit>> addMultipleUnits(List<String> unitNames) async {
    final response = await http.post(
      Uri.parse('$baseUrl/units/multiple'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'units': unitNames}), // JSON body'ye unit isimleri liste olarak eklenir
    );

    if (response.statusCode == 201) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Unit.fromJson(item)).toList();
    } else {
      throw Exception('Üniteler eklenemedi');
    }
  }

  // Üniteleri bir eğitim öğretim yılından diğerine transfer etme
  Future<List<Unit>> transferUnitsToNextYear(int fromYearId, int toYearId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/units/transfer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'fromYearId': fromYearId, 'toYearId': toYearId}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Unit.fromJson(item)).toList();
    } else {
      throw Exception('Üniteler transfer edilemedi');
    }
  }
}
