import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentHomeworkApiService {
  final String baseUrl = 'http://localhost:3000';

  StudentHomeworkApiService({baseUrl});

  // Tüm öğrenci ödevlerini getir
  Future<List<dynamic>> getAllStudentHomeworks() async {
    final response = await http.get(Uri.parse('$baseUrl/student-homeworks'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load student homeworks');
    }
  }

  // Belirli bir öğrenci ödevini getir
  Future<Map<String, dynamic>> getStudentHomeworkById(int id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/student-homeworks/$id'));

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load student homework');
    }
  }

  // Belirli bir öğrenciye ait tüm ödevleri getir (studentId ile)
  Future<List<dynamic>> getStudentHomeworksByStudentId(int studentId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/student-homeworks/student/$studentId'));

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to load student homeworks for student ID $studentId');
    }
  }

  // Yeni bir öğrenci ödevi ekle
  Future<void> addStudentHomework(
      Map<String, dynamic> studentHomeworkData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/student-homeworks'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(studentHomeworkData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add student homework');
    }
  }

  // Belirli bir öğrenci ödevini güncelle
  Future<void> updateStudentHomework(
      int id, Map<String, dynamic> studentHomeworkData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/student-homeworks/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(studentHomeworkData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update student homework');
    }
  }

  // Belirli bir öğrenci ödevini sil
  Future<void> deleteStudentHomework(int id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/student-homeworks/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete student homework');
    }
  }

  // Sınıf ve ödev ID'sine göre öğrencileri getir
  Future<List<dynamic>> getStudentsByClassAndHomework(
      int classId, int homeworkId) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/student-homeworks/class/$classId/homework/$homeworkId/students'),
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load students for homework: ${response.body}');
    }
  }

  // Toplu öğrenci ödevi güncelleme
  Future<Map<String, dynamic>> bulkUpdateStudentHomework(
      List<Map<String, dynamic>> updates) async {
    final response = await http.put(
      Uri.parse('$baseUrl/student-homeworks/bulk-update'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'updates': updates
            .map((update) => {
                  'id': update['id'],
                  'ogrenci_id': update['ogrenci_id'],
                  'odev_id': update['odev_id'],
                })
            .toList(),
      }),
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return {
        'message': responseData['message'],
        'updatedRecords': responseData['updatedRecords'],
      };
    } else {
      throw Exception(
          'Failed to bulk update student homeworks: ${response.body}');
    }
  }

  // ✅ Belirli öğrencilerin ödevlerini toplu olarak getir (Bulk Get)
  Future<List<dynamic>> bulkGetStudentHomework(List<int> studentIds) async {
    final response = await http.post(
      Uri.parse('$baseUrl/student-homeworks/bulk-get'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"ogrenci_ids": studentIds}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['data'];
    } else {
      throw Exception('Failed to bulk get student homeworks: ${response.body}');
    }
  }
}
