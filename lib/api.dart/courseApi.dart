import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ogrenci_takip_sistemi/models/courses_model.dart';

class ApiService {
  final String baseUrl = 'http://localhost:3000';

  ApiService({baseUrl});

  // Tüm kursları getir
  Future<List<Course>> getCourses() async {
    final response = await http.get(Uri.parse('$baseUrl/courses'));

    if (response.statusCode == 200) {
      final dynamic responseData = jsonDecode(response.body);
      
      // Check if the response is a Map with a courses/data property
      if (responseData is Map<String, dynamic>) {
        // Try to extract the list of courses from common response formats
        final List<dynamic> courseItems;
        if (responseData.containsKey('courses')) {
          courseItems = responseData['courses'] as List<dynamic>;
        } else if (responseData.containsKey('data')) {
          courseItems = responseData['data'] as List<dynamic>;
        } else if (responseData.containsKey('results')) {
          courseItems = responseData['results'] as List<dynamic>;
        } else if (responseData.containsKey('rows')) {
          courseItems = responseData['rows'] as List<dynamic>;
        } else {
          // If no recognizable list field, use empty list
          print('API response structure not recognized: $responseData');
          return [];
        }
        
        // Map each dynamic object to a Course instance
        return courseItems.map<Course>((json) => Course.fromJson(json)).toList();
      } 
      // If the response is already a List
      else if (responseData is List<dynamic>) {
        return responseData.map<Course>((json) => Course.fromJson(json)).toList();
      } 
      // Unexpected response format
      else {
        print('Unexpected API response format: $responseData');
        return [];
      }
    } else {
      throw Exception('Failed to load courses');
    }
  }

  // Scroll için kursları getir
  Future<List<Course>> getCoursesForScroll(
      {int offset = 0, int limit = 10}) async {
    final response = await http
        .get(Uri.parse('$baseUrl/courses/scroll?offset=$offset&limit=$limit'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      List<Course> coursesList = data.map<Course>((json) {
        return Course.fromJson(json); // Mapping from json to Course
      }).toList();

      return coursesList;
    } else {
      throw Exception('Failed to load courses for scroll');
    }
  }

  // Dropdown için kursları getir
  /*Future<List<dynamic>> getCoursesForDropdown() async {
    final response = await http.get(Uri.parse('$baseUrl/courses/dropdown'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load courses for dropdown');
    }
  }*/

  Future<List<Course>> getCoursesForDropdown() async {
    final response = await http.get(Uri.parse('$baseUrl/courses/dropdown'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      // Map each dynamic object to a Course instance using the fromJson constructor
      List<Course> courseList = data.map<Course>((json) {
        return Course.fromJson(json); // Mapping from json to Course
      }).toList();

      return courseList;
    } else {
      throw Exception('Failed to load Course');
    }
  }

  // ID'ye göre kurs getir
  Future<Course> getCourseById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/courses/$id'));

    if (response.statusCode == 200) {
      return Course.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load course by ID');
    }
  }

  // İsme göre kurs getir
  Future<List<Course>> getCoursesByName(String name) async {
    final response = await http.get(Uri.parse('$baseUrl/courses/name/$name'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Course.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load courses by name');
    }
  }

  // Yeni kurs ekle
  Future<void> addCourse(Course courseData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/courses'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(courseData),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add course');
    }
  }

  // Kurs güncelle
  Future<void> updateCourse(int id, Course courseData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/courses/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(courseData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update course');
    }
  }

  //dersin ismine göre dersin id'sini getir
  Future<int?> getCourseIdByName(String name) async {
    final response = await http.get(Uri.parse('$baseUrl/courses/name/$name'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isEmpty) {
        return null;
      }
      
      // Take the first matching course
      final courseData = Course.fromJson(data[0]);
      return courseData.id;
    } else {
      throw Exception('Failed to load course by name');
    }
  }

  // Kurs sil
  Future<http.Response> deleteCourse(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/courses/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete course');
    }

    return response;
  }

  // Debug method to get raw response
  Future<String> getCoursesRawResponse() async {
    final response = await http.get(Uri.parse('$baseUrl/courses'));
    
    if (response.statusCode == 200) {
      return response.body; // Return raw string response
    } else {
      return 'Error: ${response.statusCode}';
    }
  }
}
