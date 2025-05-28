import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:3000';

  ApiService({baseUrl});

  // Yeni bir ödev ekle
  Future<void> addHomework(Map<String, dynamic> homeworkData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/homework'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(homeworkData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add homework: ${response.body}');
    }
  }

  // Sadece ödev adı ile ödev ekle
  Future<void> addHomeworkByName(String odevAdi) async {
    final response = await http.post(
      Uri.parse('$baseUrl/homework'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'odev_adi': odevAdi}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add homework by name: ${response.body}');
    }
  }

  // Sınıf ID'ye göre ödevleri getir
  Future<List<dynamic>> getHomeworksByClassId(int sinifId) async {
    final response = await http.get(Uri.parse('$baseUrl/homeworks/class/$sinifId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load homeworks by class ID: ${response.body}');
    }
  }

  // Tüm ödevleri getir
  Future<List<dynamic>> getAllHomeworks() async {
    final response = await http.get(Uri.parse('$baseUrl/homeworks'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load homeworks: ${response.body}');
    }
  }

  // Belirli bir ödevi getir
  Future<Map<String, dynamic>> getHomeworkById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/homework/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load homework: ${response.body}');
    }
  }

  // Ödevi güncelle
  Future<void> updateHomework(int id, Map<String, dynamic> homeworkData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/homework/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(homeworkData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update homework: ${response.body}');
    }
  }

  // Ödevi sil
  Future<void> deleteHomework(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/homework/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete homework: ${response.body}');
    }
  }

  // Belirli bir sınıf ve ders için ödevleri getir
  Future<List<dynamic>> getHomeworksByClassAndCourse(int sinifId, int dersId) async {
    final response = await http.get(Uri.parse('$baseUrl/homeworks/class/$sinifId/course/$dersId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load homeworks by class and course: ${response.body}');
    }
  }

  // Ödev teslim tarihini kontrol et
  Future<Map<String, dynamic>> checkHomeworkDeadline(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/homework/$id/check-deadline'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to check homework deadline: ${response.body}');
    }
  }

  // Belirli bir sınıf ve ders için teslim tarihi kontrolü
  Future<Map<String, dynamic>> getHomeworksByDueDate(int sinifId, int dersId) async {
    final response = await http.get(Uri.parse('$baseUrl/homeworks/class/$sinifId/course/$dersId/due-date'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load homeworks by due date: ${response.body}');
    }
  }

  // Ödev transfer et
  Future<void> transferHomeworks(int fromYearId, int toYearId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/homework/transfer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'fromYearId': fromYearId, 'toYearId': toYearId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to transfer homeworks: ${response.body}');
    }
  }
}
