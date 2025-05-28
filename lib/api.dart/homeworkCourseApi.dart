import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ogrenci_takip_sistemi/models/homework_course_classes_model.dart';

class HomeworkCourseClassApiService {
  final String baseUrl;

  HomeworkCourseClassApiService({required this.baseUrl});

  // Yeni bir HomeworkCourseClass ekle
  Future<HomeworkCourseClass> addHomeworkCourseClass(
      HomeworkCourseClass homeworkCourseClass) async {
    final response = await http.post(
      Uri.parse('$baseUrl/homeworkCourseClass'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(homeworkCourseClass.toJson()),
    );

    if (response.statusCode == 201) {
      return HomeworkCourseClass.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add HomeworkCourseClass: ${response.body}');
    }
  }

  // Tüm HomeworkCourseClass kayıtlarını getir
  Future<List<HomeworkCourseClass>> getAllHomeworkCourseClasses() async {
    final response = await http.get(Uri.parse('$baseUrl/homeworkCourseClass'));

    if (response.statusCode == 200) {
      List<dynamic> responseBody = json.decode(response.body);
      return responseBody
          .map((json) => HomeworkCourseClass.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load HomeworkCourseClasses: ${response.body}');
    }
  }

  // Belirli bir HomeworkCourseClass kaydını getir
  Future<HomeworkCourseClass> getHomeworkCourseClassById(int id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/homeworkCourseClass/$id'));

    if (response.statusCode == 200) {
      return HomeworkCourseClass.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load HomeworkCourseClass: ${response.body}');
    }
  }

  // Belirli bir HomeworkCourseClass kaydını sil
  Future<void> deleteHomeworkCourseClass(int id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/homeworkCourseClass/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete HomeworkCourseClass: ${response.body}');
    }
  }
}
