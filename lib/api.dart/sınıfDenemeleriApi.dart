import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:3000'; // API base URL

  ApiService({baseUrl});

  // Tüm sınıf-deneme ilişkilerini getir
  Future<List<dynamic>> getAllSinifDenemeleri() async {
    final response = await http.get(Uri.parse('$baseUrl/sinif-denemeleri'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load sinif-denemeleri');
    }
  }

  // Belirli bir sınıf ve deneme sınavı ilişkisini getir
  Future<Map<String, dynamic>> getSinifDenemeleriById(
      int sinifId, int denemeSinaviId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/sinif-denemeleri/$sinifId/$denemeSinaviId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load sinif-denemeleri');
    }
  }

  // Yeni bir sınıf ve deneme sınavı ilişkisi oluştur
  Future<void> createSinifDenemeleri(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sinif-denemeleri'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      print('Sınıf-Deneme sınavı ilişkisi başarıyla oluşturuldu');
    } else if (response.statusCode == 400) {
      throw Exception('Sınıf ve Deneme Sınavı zaten ilişkilendirilmiş.');
    } else {
      throw Exception('Failed to create sinif-denemeleri: ${response.body}');
    }
  }

  // Bir sınıf ve deneme sınavı ilişkisini güncelle
  Future<void> updateSinifDenemeleri(
      int sinifId, int denemeSinaviId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/sinif-denemeleri/$sinifId/$denemeSinaviId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update sinif-denemeleri');
    }
  }

  // Bir sınıf ve deneme sınavı ilişkisini sil
  Future<void> deleteSinifDenemeleri(int sinifId, int denemeSinaviId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/sinif-denemeleri/$sinifId/$denemeSinaviId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete sinif-denemeleri');
    }
  }

  // Belirli bir deneme sınavına ait sınıfları getir
  Future<List<dynamic>> getClassesByExam(int denemeSinaviId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/sinif-denemeleri/deneme/$denemeSinaviId/siniflar'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load classes by exam');
    }
  }

  // Belirli bir sınıfa ait deneme sınavlarını getir
  Future<List<dynamic>> getExamsByClass(int sinifId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/sinif-denemeleri/sinif/$sinifId/denemeler'));

      print('API Yanıt Status: ${response.statusCode}');
      print('API Yanıt Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception(
            'Failed to load exams by class: ${response.statusCode}');
      }
    } catch (e) {
      print('getExamsByClass error: $e');
      rethrow;
    }
  }

  // Tüm 6. sınıflara Deneme Sınavı ataması yap
  Future<void> assignExamToSixthGrade(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sinif-denemeleri/assign-exam/sixth-grade'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to assign exam to sixth grade');
    }
  }

  // Tüm 5. sınıflara Deneme Sınavı ataması yap
  Future<void> assignExamToFifthGrade(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sinif-denemeleri/assign-exam/fifth-grade'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to assign exam to fifth grade');
    }
  }

  // Tüm 7. sınıflara Deneme Sınavı ataması yap
  Future<void> assignExamToSeventhGrade(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sinif-denemeleri/assign-exam/seventh-grade'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to assign exam to seventh grade');
    }
  }

  // Tüm 8. sınıflara Deneme Sınavı ataması yap
  Future<void> assignExamToEighthGrade(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sinif-denemeleri/assign-exam/eighth-grade'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to assign exam to eighth grade');
    }
  }

  // Belirli bir sınıfa deneme sınavı ataması yap
  Future<void> assignExamToSpecificClass(int examId, int classId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/sinif-denemeleri/assign-exam/specific-class'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'deneme_sinavi_id': examId, 'sinif_id': classId}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to assign exam to specific class');
    }
  }
}
