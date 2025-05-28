import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:3000';

  ApiService({baseUrl});

  // Helper method to handle POST requests
  Future<void> _makePostRequest(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to complete the request: ${response.body}');
    }
  }

  // Transfer all students from one academic year to another
  Future<void> transferAllStudents(int fromYearId, int toYearId) async {
    final data = {
      'fromYearId': fromYearId,
      'toYearId': toYearId,
    };

    await _makePostRequest('transfer-students', data);
  }
}
