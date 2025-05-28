import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:ogrenci_takip_sistemi/models/teacher_model.dart';
import 'package:ogrenci_takip_sistemi/service/teacher_service.dart';

class TeacherApiService {
  final String baseUrl;

  TeacherApiService({required this.baseUrl});

  // Ogretmenleri getirme
  Future<List<Teacher>> getTeachers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/teachers'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch teachers');
    }
  }

  // Ogretmen getirmek
  Future<Teacher> getTeacher(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/teachers/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // 📌 Backend'den gelen JSON'u Teacher nesnesine çevir
      if (data.containsKey('teacher')) {
        return Teacher.fromJson(data['teacher']);
      } else {
        throw Exception('Invalid response format from backend');
      }
    } else {
      throw Exception('Failed to fetch teacher');
    }
  }

  // Ogretmen resmini getirme
  Future<String?> getTeacherImage(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/teachers/$id/image'));

      if (response.statusCode == 200) {
        return '$baseUrl/teachers/$id/image'; // ✅ URL döndür
      } else {
        return null;
      }
    } catch (e) {
      print('Resim getirme hatası: $e');
      return null;
    }
  }

  // Ogretmen olusturma
  Future<Teacher> createTeacher(Map<String, dynamic> teacherData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/teachers'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(teacherData),
      );

      if (response.statusCode == 201) {
        // Backend'den gelen yanıtı düzgün şekilde parse et
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('teacher')) {
          return Teacher.fromJson(data['teacher']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to create teacher: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in createTeacher: $e'); // Debugging için
      throw Exception('Failed to create teacher: $e');
    }
  }

  Future<String> uploadTeacherImage(int id, File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/teachers/$id/upload-image'),
      );

      var multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      );

      request.files.add(multipartFile);
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseData.body);
        return jsonResponse['imageUrl']; // ✅ Resim URL’sini döndür
      } else {
        throw Exception('Resim yüklenemedi: ${responseData.body}');
      }
    } catch (e) {
      print('Resim yükleme hatası: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Ogretmen guncelleme
  // 🟢 Öğretmen bilgilerini güncelleme
  Future<bool> updateTeacherInfo(int id, String name, File? imageFile) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/teachers/$id'),
      );

      request.fields['teacher_name'] = name;

      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        print('✅ Öğretmen başarıyla güncellendi!');
        return true;
      } else {
        print('❌ Hata: ${responseData.body}');
        return false;
      }
    } catch (e) {
      print('🚨 Güncelleme hatası: $e');
      return false;
    }
  }

  // Teacher delete
  Future<bool> deleteTeacher(int id) async {
    try {
      // API'den öğretmeni sil
      final response = await http.delete(
        Uri.parse('$baseUrl/teachers/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // SharedPreferences'dan öğretmen verilerini temizle
        final teacherService = TeacherService();
        await teacherService.clearAllData();

        print('✅ Öğretmen başarıyla silindi ve yerel veriler temizlendi');
        return true;
      } else {
        print('❌ Öğretmen silinirken hata oluştu: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('🚨 Silme işlemi sırasında hata: $e');
      return false;
    }
  }
}
