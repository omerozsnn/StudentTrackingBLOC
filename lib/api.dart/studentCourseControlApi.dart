import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:3000';

  ApiService({baseUrl});

  // Yeni bir öğrenci-ders ilişkisi ekle
  Future<void> addStudentCourse(Map<String, dynamic> studentCourseData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/student-courses'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(studentCourseData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add student-course relationship');
    }
  }

  // Öğrenci-ders ilişkisini güncelle
  Future<void> updateStudentCourse(Map<String, dynamic> studentCourseData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/student-courses'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(studentCourseData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update student-course relationship');
    }
  }

  // Öğrenci-ders ilişkisini sil
  Future<void> deleteStudentCourse(Map<String, dynamic> studentCourseData) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/student-courses'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(studentCourseData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete student-course relationship');
    }
  }

  // Öğrenci-ders ilişkisini getir
  Future<Map<String, dynamic>> getStudentCourse(Map<String, dynamic> studentCourseData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/student-courses/find'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(studentCourseData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load student-course relationship');
    }
  }

  // Tüm öğrenci-ders ilişkilerini getir
  Future<List<dynamic>> getAllStudentCourses() async {
    final response = await http.get(Uri.parse('$baseUrl/student-courses'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load student-course relationships');
    }
  }

  // Belirli bir öğrenci-ders ilişkisini ID ile getir
  Future<Map<String, dynamic>> getStudentCourseById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/student-courses/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load student-course relationship by ID');
    }
  }

  // Belirli bir öğrenciye ait ders ilişkilerini getir
  Future<List<dynamic>> getStudentCoursesByStudent(int studentId) async {
    final response = await http.get(Uri.parse('$baseUrl/student-courses/student/$studentId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load courses for student');
    }
  }

  // Belirli bir ders için tüm öğrenci ilişkilerini getir
  Future<List<dynamic>> getStudentCoursesByCourse(int courseId) async {
    final response = await http.get(Uri.parse('$baseUrl/student-courses/course/$courseId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load students for course');
    }
  }
}
