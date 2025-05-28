import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/course_classes_model.dart';

class ApiService {
  final String baseUrl = 'http://localhost:3000';

  ApiService({baseUrl});

  // Yeni CourseClass ekle
  Future<void> addCourseClass(CourseClass courseClass) async {
    final response = await http.post(
      Uri.parse('$baseUrl/course-classes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(courseClass.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add CourseClass');
    }
  }

  // Tüm CourseClass kayıtlarını getir
  Future<List<CourseClass>> getAllCourseClasses() async {
    final response = await http.get(Uri.parse('$baseUrl/course-classes'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CourseClass.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load CourseClasses');
    }
  }

  // ID'ye göre CourseClass getir
  Future<CourseClass> getCourseClassById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/course-classes/$id'));

    if (response.statusCode == 200) {
      return CourseClass.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load CourseClass by ID');
    }
  }

  // CourseClass güncelle
  Future<void> updateCourseClass(int id, CourseClass courseClass) async {
    final response = await http.put(
      Uri.parse('$baseUrl/course-classes/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(courseClass.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update CourseClass');
    }
  }

  // CourseClass sil
  Future<void> deleteCourseClass(int id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/course-classes/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete CourseClass');
    }
  }

  // Sınıf ID'ye göre CourseClass kayıtlarını getir
  Future<List<CourseClass>> getCourseClassesByClassId(int sinifId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/course-classes/sinif/$sinifId'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CourseClass.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load CourseClasses by Class ID');
    }
  }

  // Sınıf ve ders ID'ye göre CourseClass ID getir
  Future<int?> getCourseClassIdByClassAndCourseId(
      int sinifId, int dersId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/course-classes/sinif/$sinifId/ders/$dersId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final courseClass = CourseClass.fromJson(data);
      return courseClass.id;
    } else {
      throw Exception('Failed to load CourseClass by Class ID and Course ID');
    }
  }
}
