import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ogrenci_takip_sistemi/models/defter_kitap_model.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // Hata mesajını yönetmek için yardımcı fonksiyon
  void _handleError(http.Response response) {
    throw Exception(
      'API isteği başarısız oldu. Status Code: ${response.statusCode}, Response: ${response.body}',
    );
  }

  // Tüm Defter ve Kitap kayıtlarını getir
  Future<Map<String, dynamic>> getDefterKitap(
      {int page = 1, int limit = 10}) async {
    final response = await http
        .get(Uri.parse('$baseUrl/defterkitap?page=$page&limit=$limit'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      // 'data' alanındaki listeler DefterKitap nesnelerine dönüştürülüyor
      if (responseData['data'] != null && responseData['data'] is List) {
        final List<dynamic> rawList = responseData['data'];
        final List<DefterKitap> defterKitapList =
            rawList.map((item) => DefterKitap.fromJson(item)).toList();

        responseData['data'] = defterKitapList;
      }

      return responseData;
    } else {
      _handleError(response);
      throw Exception('Unexpected error occurred');
    }
  }

  // Dropdown için Defter ve Kitapları getir
  Future<List<DefterKitap>> getDefterKitapForDropdown() async {
    final response = await http.get(Uri.parse('$baseUrl/defterkitap/dropdown'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => DefterKitap.fromJson(item)).toList();
    } else {
      _handleError(response);
      throw Exception('Unexpected error occurred');
    }
  }

  // Yeni bir Defter ve Kitap kaydı ekle
  Future<void> addDefterKitap(Map<String, dynamic> defterKitapData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/defterkitap'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(defterKitapData),
    );

    if (response.statusCode != 201) {
      _handleError(response);
    }
  }

  // Belirli bir Defter ve Kitap kaydını güncelle
  Future<void> updateDefterKitap(
      int id, Map<String, dynamic> defterKitapData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/defterkitap/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(defterKitapData),
    );

    if (response.statusCode != 200) {
      _handleError(response);
    }
  }

  // Belirli bir Defter ve Kitap kaydını sil
  Future<void> deleteDefterKitap(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/defterkitap/$id'));

    // 200 ve 204 durum kodlarını başarı olarak kabul et
    if (response.statusCode != 200 && response.statusCode != 204) {
      _handleError(response);
    }
  }

  // ID'ye göre Defter ve Kitap kaydını getir
  Future<DefterKitap> getDefterKitapById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/defterkitap/$id'));

    if (response.statusCode == 200) {
      return DefterKitap.fromJson(json.decode(response.body));
    } else {
      _handleError(response);
      throw Exception('Unexpected error occurred');
    }
  }

  // Tarihe göre Defter ve Kitap kayıtlarını getir
  Future<List<DefterKitap>> getDefterKitapByDate(String tarih) async {
    final response =
        await http.get(Uri.parse('$baseUrl/defterkitap/date/$tarih'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => DefterKitap.fromJson(item)).toList();
    } else {
      _handleError(response);
      throw Exception('Unexpected error occurred');
    }
  }

  // Tarihe ve sınıf dersine göre Defter ve Kitap kayıtlarını getir
  Future<List<DefterKitap>> getDefterKitapByDateAndCourseClass(
      String tarih, int courseClassId) async {
    final response = await http.get(Uri.parse(
        '$baseUrl/defterkitap/date/$tarih/courseclass/$courseClassId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => DefterKitap.fromJson(item)).toList();
    } else {
      _handleError(response);
      throw Exception('Unexpected error occurred');
    }
  }

  // Öğrenci ID'sine göre Defter ve Kitap kayıtlarını getir
  Future<List<DefterKitap>> getDefterKitapByStudentId(int studentId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/defterkitap/ogrenci_id/$studentId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => DefterKitap.fromJson(item)).toList();
    } else {
      _handleError(response);
      throw Exception('Unexpected error occurred');
    }
  }

  // Sınıf dersine göre Defter ve Kitap kayıtlarını getir
  Future<List<DefterKitap>> getDefterKitapByCourseClassId(
      int courseClassId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/defterkitap/courseclass/$courseClassId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => DefterKitap.fromJson(item)).toList();
    } else {
      _handleError(response);
      throw Exception('Unexpected error occurred');
    }
  }

  // Duruma göre Defter ve Kitap kayıtlarını filtrele
  Future<List<DefterKitap>> filterDefterKitapByStatus(
      String statusType, String statusValue) async {
    final response = await http
        .get(Uri.parse('$baseUrl/defterkitap/filter/$statusType/$statusValue'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => DefterKitap.fromJson(item)).toList();
    } else {
      _handleError(response);
      throw Exception('Unexpected error occurred');
    }
  }

  // Tarihe ve öğrenciye göre Defter ve Kitap kayıtlarını getir
  Future<List<DefterKitap>> getDefterKitapByDateAndStudent(
      String tarih, int studentId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/defterkitap/date/$tarih/student/$studentId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => DefterKitap.fromJson(item)).toList();
    } else {
      _handleError(response);
      throw Exception('Unexpected error occurred');
    }
  }

  // Birden fazla Defter ve Kitap kaydı ekle
  Future<void> addMultipleDefterKitap(
      List<Map<String, dynamic>> defterKitapList) async {
    final response = await http.post(
      Uri.parse('$baseUrl/defterkitap/multiple'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'defterKitapList': defterKitapList}),
    );

    if (response.statusCode != 201) {
      _handleError(response);
    }
  }

  // Belirli bir sınıf dersine ait tarihleri getir
  Future<List<dynamic>> getDatesByCourseClassId(int courseClassId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/defterkitap/dates/courseclass/$courseClassId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      // 404 durumunda bu normal bir durum - sadece tarih yok
      print('Sınıf-ders için henüz tarih bulunmuyor (404)');
      // Boş liste dön
      return [];
    } else {
      throw Exception(
          'API isteği başarısız oldu. Status Code: ${response.statusCode}, Response: ${response.body}');
    }
  }

  // Defter-Kitap kaydını güncelle veya ekle (Upsert)
  Future<void> addOrUpdateDefterKitap(
      Map<String, dynamic> defterKitapData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/defterkitap/upsert'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(defterKitapData),
    );

    if (response.statusCode != 200) {
      _handleError(response);
    }
  }

  // CourseClass ID'sine göre detay bilgileri al
  Future<Map<String, dynamic>?> getCourseClassById(int courseClassId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/sinif-dersleri/$courseClassId'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print(
            'CourseClass detayları alınamadı. Status: ${response.statusCode}');
        return null;
      }
    } catch (error) {
      print('CourseClass detayları alınamadı: $error');
      return null;
    }
  }
}
