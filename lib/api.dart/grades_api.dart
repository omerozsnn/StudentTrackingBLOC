import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:ogrenci_takip_sistemi/models/grades_model.dart';

class GradesRepository {
  final String baseUrl;

  GradesRepository({required this.baseUrl});

  // Create a new grade
  Future<Grade> createGrade(Grade grade) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/grades'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(grade.toJson()),
      );

      if (response.statusCode == 201) {
        return Grade.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create grade: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating grade: $e');
    }
  }

  // Get a grade by ID
  Future<Grade> getGrade(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/grades/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Grade.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch grade: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching grade: $e');
    }
  }

  // Update a grade
  Future<Grade> updateGrade(int id, Grade grade) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/grades/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(grade.toJson()),
      );

      if (response.statusCode == 200) {
        return Grade.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update grade: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating grade: $e');
    }
  }

  // Delete a grade
  Future<void> deleteGrade(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/grades/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete grade: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting grade: $e');
    }
  }

  // Get all grades for a student
  Future<List<Grade>> getStudentGrades(int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/grades/students/$studentId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Grade.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to fetch student grades: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching student grades: $e');
    }
  }

  // Get all grades for a course class
  Future<List<Grade>> getCourseClassGrades(int courseClassId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/grades/course-classes/$courseClassId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Grade.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to fetch course class grades: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching course class grades: $e');
    }
  }

  // Get grades for a specific semester and course class
  Future<List<Grade>> getGradesBySemester(
      int courseClassId, int semester) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/grades/course-classes/$courseClassId/semester/$semester'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Grade.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to fetch grades by semester: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching grades by semester: $e');
    }
  }

  // Get student semester grades
  Future<StudentSemesterGrades> getStudentSemesterGrades(
      int studentId, int semester) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/grades/student/$studentId/donem/$semester'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return StudentSemesterGrades.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to fetch student semester grades: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching student semester grades: $e');
    }
  }

  // Upload Excel grades file
  Future<void> uploadExcelGrades(
      File file, int courseClassId, int semester) async {
    try {
      final uri = Uri.parse('$baseUrl/grades/upload-excel');
      final request = http.MultipartRequest('POST', uri);

      // Add file
      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType('application',
            'vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
      );
      request.files.add(multipartFile);

      // Add parameters
      request.fields['sinif_dersleri_id'] = courseClassId.toString();
      request.fields['donem'] = semester.toString();

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception('Failed to upload Excel file: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error uploading Excel file: $e');
    }
  }

  // Get class grades by class ID and semester
  Future<ClassGradesByCourse> getClassGradesByClassId(
      int classId, int semester) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/grades/class/$classId/semester/$semester'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return ClassGradesByCourse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch class grades: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching class grades: $e');
    }
  }

  // Get course class grades with rankings
  Future<CourseClassGrades> getClassGradesByCourseClassId(
      int courseClassId, int semester) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/grades/courseclass/$courseClassId/semester/$semester'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return CourseClassGrades.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to fetch course class grades with rankings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching course class grades with rankings: $e');
    }
  }
}
