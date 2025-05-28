import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:3000';

  ApiService({baseUrl});

  // Yeni bir ödev takibi ekle
  Future<void> addHomeworkTracking(
      Map<String, dynamic> homeworkTrackingData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/homeworkTracking'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(homeworkTrackingData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add homework tracking: ${response.body}');
    }
  }

  // Tüm ödev takiplerini getir
  Future<List<dynamic>> getAllHomeworkTracking() async {
    final response = await http.get(Uri.parse('$baseUrl/homeworkTracking'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to load homework tracking records: ${response.body}');
    }
  }

  // Belirli bir ödev takibini getir
  Future<Map<String, dynamic>> getHomeworkTrackingById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/homeworkTracking/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load homework tracking: ${response.body}');
    }
  }

  // Ödev takibini güncelle
  Future<void> updateHomeworkTracking(
      int id, Map<String, dynamic> homeworkTrackingData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/homeworkTracking/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(homeworkTrackingData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update homework tracking: ${response.body}');
    }
  }

  Future<void> updateHomeworkTrackingStatus(
      int trackingId, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/homework-tracking/$trackingId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data), // Map'i JSON'a dönüştür
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update homework tracking: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update homework tracking: $e');
    }
  }

  // Ödev takibini sil
  Future<void> deleteHomeworkTracking(int id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/homeworkTracking/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete homework tracking: ${response.body}');
    }
  }

  // Öğrenci ödev ID'ye göre ödev takibini getir
  Future<List<dynamic>> getHomeworkTrackingByStudentHomeworkId(
      int studentHomeworkId) async {
    final response = await http.get(Uri.parse(
        '$baseUrl/homeworkTracking/studentHomework/$studentHomeworkId'));

    if (response.statusCode == 200) {
      return json.decode(response.body); // Burada liste döneceğini varsayıyoruz
    } else {
      throw Exception(
          'Failed to load homework tracking by studentHomeworkId: ${response.body}');
    }
  }

  // Eski ödev kayıtlarını arşivle
  Future<void> archiveOldHomeworkTrackings(String archiveDate) async {
    final response = await http.put(
      Uri.parse('$baseUrl/homeworkTracking/archive'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'archiveDate': archiveDate}),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to archive old homework tracking records: ${response.body}');
    }
  }

  // Toplu ekleme için yeni metod
  Future<void> bulkUpsertHomeworkTracking(
      List<Map<String, dynamic>> bulkData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/homeworkTracking/bulk-upsert'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bulkData),
    );

    if (response.statusCode != 200) {
      throw Exception('Toplu işlem başarısız: ${response.body}');
    }
  }

  // ✅ Öğrenci ödev ID'ye göre ödev takibini getir (bulk işlemi)
  Future<List<dynamic>> bulkGetHomeworkTracking(
      List<int> studentHomeworkIds) async {
    final response = await http.post(
      Uri.parse('$baseUrl/homeworkTracking/bulk-get'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"ogrenci_odevleri_ids": studentHomeworkIds}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to bulk get homework tracking: ${response.body}');
    }
  }

  Future<List<dynamic>> bulkGetHomeworkTrackingForHomework(
      List<int> studentIds, int homeworkId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/homeworkTracking/bulk-get-by-homework'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"studentIds": studentIds, "homeworkId": homeworkId}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception(
          'Failed to bulk get homework tracking for homework: ${response.body}');
    }
  }
}
