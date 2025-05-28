import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:ogrenci_takip_sistemi/models/ogrenci_denemeleri_model.dart';

class StudentExamRepository {
  final String baseUrl;

  StudentExamRepository({required this.baseUrl});

  // Get all student exam results
  Future<List<StudentExamResult>> getAllStudentExamResults() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ogrenci-denemeleri'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> resultData = jsonDecode(response.body);
        return resultData
            .map((json) => StudentExamResult.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to load student exam results: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching student exam results: $e');
    }
  }

  // Get student exam results with pagination
  Future<Map<String, dynamic>> getStudentExamResultsWithPagination({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/ogrenci-denemeleri/pagination?limit=$limit&offset=$offset'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> resultData = jsonDecode(response.body);
        final List<StudentExamResult> rows = (resultData['rows'] as List)
            .map((json) => StudentExamResult.fromJson(json))
            .toList();

        return {
          'rows': rows,
          'count': resultData['count'],
        };
      } else {
        throw Exception(
            'Failed to load paginated student exam results: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching paginated student exam results: $e');
    }
  }

  // Create a new student exam result
  Future<void> createStudentExamResult(StudentExamResult result) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ogrenci-denemeleri'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(result.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception(
            'Failed to create student exam result: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating student exam result: $e');
    }
  }

  // Update a student exam result
  Future<void> updateStudentExamResult(
    int ogrenciId,
    int denemeSinaviId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/ogrenci-denemeleri/$ogrenciId/$denemeSinaviId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update student exam result: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating student exam result: $e');
    }
  }

  // Delete a student exam result
  Future<void> deleteStudentExamResult(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/ogrenci-denemeleri/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete student exam result: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting student exam result: $e');
    }
  }

  // Get exam results for a specific student
  Future<List<StudentExamResult>> getStudentExamResultsByStudentId(
      int ogrenciId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ogrenci-denemeleri/ogrenci/$ogrenciId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> resultData = jsonDecode(response.body);
        return resultData
            .map((json) => StudentExamResult.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to load student exam results by student ID: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching student exam results by student ID: $e');
    }
  }

  // Import exam results from Excel file
  Future<void> importExamPointsFromExcel(File file) async {
    try {
      var uri = Uri.parse('$baseUrl/ogrenci-denemeleri/excel');
      var request = http.MultipartRequest('POST', uri);

      // Add file
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType('application',
            'vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
      ));

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to import exam points from Excel: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error importing exam points from Excel: $e');
    }
  }

  // Get scores for all students for a specific exam
  Future<List<StudentExamResult>> getStudentsScoresByExam(
      int denemeSinaviId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ogrenci-denemeleri/sinav/$denemeSinaviId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> resultData = jsonDecode(response.body);
        return resultData
            .map((json) => StudentExamResult.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to load students scores by exam: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching students scores by exam: $e');
    }
  }

  // Get all students for a specific exam
  Future<List<StudentExamResult>> getStudentsByExam(int denemeSinaviId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/ogrenci-denemeleri/sinav/$denemeSinaviId/ogrenciler'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> resultData = jsonDecode(response.body);
        return resultData
            .map((json) => StudentExamResult.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to load students by exam: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching students by exam: $e');
    }
  }

  // Get participation information for a student
  Future<StudentExamParticipation> getStudentExamParticipation(
      int ogrenciId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ogrenci-denemeleri/ogrenci/$ogrenciId/katilim'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> resultData = jsonDecode(response.body);
        return StudentExamParticipation.fromJson(resultData);
      } else {
        throw Exception(
            'Failed to load student exam participation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching student exam participation: $e');
    }
  }

  // Get class exam averages
  Future<ClassDenemeAverages> getClassDenemeAverages(
      int sinifId, int ogrenciId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/ogrenci-denemeleri/class/$sinifId/student/$ogrenciId/avarages'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> resultData = jsonDecode(response.body);
        return ClassDenemeAverages.fromJson(resultData);
      } else {
        throw Exception(
            'Failed to load class exam averages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching class exam averages: $e');
    }
  }
}
