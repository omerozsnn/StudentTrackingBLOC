import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:3000'; // API base URL
  ApiService({baseUrl});

  // Tüm KDS-Sınıf ilişkilerini listele
  Future<List<dynamic>> getAllKDSClasses() async {
    final response = await http.get(Uri.parse('$baseUrl/kds-class'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load KDS-Class relationships');
    }
  }

  // KDS ile sınıf arasında ilişki oluştur
  Future<void> assignKDSClass(int kdsId, int classId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/kds-class'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'kds_id': kdsId, 'sinif_id': classId}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to assign KDS to class');
    }
  }

  // Belirli bir KDS'ye ait sınıfları listele
  Future<List<dynamic>> getClassesByKDS(int kdsId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/kds-class/kds/$kdsId/class'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load classes for the given KDS');
    }
  }

  // Belirli bir sınıfa ait KDS'leri listele
  Future<List<dynamic>> getKDSByClass(int classId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kds-class/class/$classId/kds'),
      );
      print('getKDSByClass API yanıtı:');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception(
            'Failed to load KDS for class. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('getKDSByClass hata: $e');
      rethrow;
    }
  }

  // KDS ile sınıf arasındaki ilişkiyi sil
  Future<void> deleteKDSClass(int kdsId, int classId) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/kds-class/kds/$kdsId/class/$classId'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete KDS-Class relationship');
    }
  }

  // Tüm 5. sınıflara KDS ataması yap
  Future<void> assignKDSToFifthGrade(int kdsId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/kds-class/assign-kds-to-fifth-grade'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'kds_id': kdsId}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to assign KDS to all fifth-grade classes');
    }
  }

  // Tüm 6. sınıflara KDS ataması yap
  Future<void> assignKDSToSixthGrade(int kdsId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/kds-class/assign-kds-to-sixth-grade'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'kds_id': kdsId}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to assign KDS to all sixth-grade classes');
    }
  }

  // Tüm 7. sınıflara KDS ataması yap
  Future<void> assignKDSToSeventhGrade(int kdsId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/kds-class/assign-kds-to-seventh-grade'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'kds_id': kdsId}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to assign KDS to all seventh-grade classes');
    }
  }

  // Tüm 8. sınıflara KDS ataması yap
  Future<void> assignKDSToEighthGrade(int kdsId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/kds-class/assign-kds-to-eighth-grade'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'kds_id': kdsId}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to assign KDS to all eighth-grade classes');
    }
  }

  // Belirli bir sınıfa ait KDS'yi sil
  Future<void> deleteKDSFromClass(int kdsId, int classId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/kds-class/kds/$kdsId/class/$classId'),
      );

      if (response.statusCode != 204) {
        print('Delete failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to delete KDS from class');
      }
    } catch (e) {
      print('Delete error: $e');
      rethrow;
    }
  }

  // Sınıfa ait tüm KDS'leri sil
  Future<void> deleteAllKDSFromClass(int classId) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/kds-class/class/$classId/kds'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete all KDS from class');
    }
  }
}
