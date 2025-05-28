import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:3000';

  ApiService({baseUrl});

  // Aktif eğitim öğretim yılını getir
  Future<Map<String, dynamic>?> getCurrentYear() async {
    final response = await http.get(Uri.parse('$baseUrl/egitim-ogretim-yillari/current'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load current education year');
    }
  }

  // Yeni bir eğitim öğretim yılı oluştur
  Future<Map<String, dynamic>> createNewYear(Map<String, dynamic> newYearData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/egitim-ogretim-yillari'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newYearData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create new education year');
    }
  }

  // Tüm eğitim öğretim yıllarını getir
  Future<List<dynamic>> getAllYears() async {
    final response = await http.get(Uri.parse('$baseUrl/egitim-ogretim-yillari'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load education years');
    }
  }

  // Öğrencileri yeni eğitim öğretim yılına aktar (şu anda yorum satırında)
  /*
  Future<Map<String, dynamic>> transferStudentsToNextYear() async {
    final response = await http.post(
      Uri.parse('$baseUrl/egitim-ogretim-yillari/transfer-student'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to transfer students to the next year');
    }
  }
  */
}
