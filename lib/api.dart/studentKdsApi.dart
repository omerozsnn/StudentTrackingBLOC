import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io'; // For handling File in Excel upload
import 'package:http_parser/http_parser.dart'; // For MediaType

class ApiService {
  final String baseUrl = 'http://localhost:3000';
  ApiService({baseUrl});

  // Tüm öğrenci-KDS atamalarını listele
  Future<List<dynamic>> getAllStudentKDS() async {
    final response = await http.get(Uri.parse('$baseUrl/student-kds'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Öğrenci-KDS listesi getirilemedi.');
    }
  }

  // Excel import için yardımcı metod - Güncellendi
  Map<String, int> parseExcelScores(dynamic row) {
    return {
      'dogru': row['dogru'] ?? 0,
      'yanlis': row['yanlis'] ?? 0,
      'bos': row['bos'] ?? 0,
      'puan': row['puan'] ?? 0,
    };
  }

  // Belirli bir öğrenci-KDS atamasını ID ile getir
  Future<Map<String, dynamic>> getStudentKDSById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/student-kds/$id'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Öğrenci-KDS ataması getirilemedi.');
    }
  }

  // Yeni bir öğrenciye KDS ataması yap - Güncellendi
  Future<void> addStudentKDS(
      int kdsId, int studentId, Map<String, int> scores) async {
    final response = await http.post(
      Uri.parse('$baseUrl/student-kds'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'kds_id': kdsId,
        'ogrenci_id': studentId,
        'dogru': scores['dogru'] ?? 0,
        'yanlis': scores['yanlis'] ?? 0,
        'bos': scores['bos'] ?? 0,
        'puan': scores['puan'] ?? 0,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Öğrenci-KDS ataması eklenemedi.');
    }
  }

  // Öğrencinin KDS puanını güncelle - Güncellendi
  Future<void> updateStudentKDSScores(
      int studentId, int kdsId, Map<String, int> scores) async {
    final response = await http.put(
      Uri.parse('$baseUrl/student-kds/$studentId/kds/$kdsId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'dogru': scores['dogru'] ?? 0,
        'yanlis': scores['yanlis'] ?? 0,
        'bos': scores['bos'] ?? 0,
        'puan': scores['puan'] ?? 0,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Öğrenci-KDS puanı güncellenemedi.');
    }
  }

  // Öğrenciden KDS atamasını kaldır (sil)
  Future<void> deleteStudentKDSForStudent(int studentId, int kdsId) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/student-kds/$studentId/kds/$kdsId'));

    if (response.statusCode != 204) {
      throw Exception('Öğrenci-KDS ataması silinemedi.');
    }
  }

  // Belirli bir KDS'ye atanmış tüm öğrencileri listele
  Future<List<dynamic>> getStudentsForKDS(int kdsId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/student-kds/kds/$kdsId/students'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('KDS\'ye atanmış öğrenciler getirilemedi.');
    }
  }

  // Belirli bir öğrenciye ait tüm KDS puanlarını listele
  Future<List<dynamic>> getStudentKDSScores(int studentId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/student-kds/student/$studentId/kds/scores'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Öğrenciye ait KDS puanları getirilemedi.');
    }
  }

  Future<List<dynamic>> getKDSByStudent(int studentId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/student-kds/$studentId/kds'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Öğrenciye ait KDS atamaları getirilemedi.');
    }
  }

  // Belirli bir KDS'ye atanmış tüm öğrencilerin puanlarını listele
  Future<List<dynamic>> getStudentsScoresForKDS(int kdsId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/student-kds/kds/$kdsId/scores'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('KDS\'ye ait öğrenci puanları getirilemedi.');
    }
  }

  // Birden fazla öğrenciye toplu KDS ataması yap - Güncellendi
  Future<void> assignMultipleStudentsKDS(
      List<int> studentIds, int kdsId, Map<String, int> scores) async {
    final response = await http.post(
      Uri.parse('$baseUrl/student-kds/assign-multiple'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'ogrenci_id_list': studentIds,
        'kds_id': kdsId,
        'dogru': scores['dogru'] ?? 0,
        'yanlis': scores['yanlis'] ?? 0,
        'bos': scores['bos'] ?? 0,
        'puan': scores['puan'] ?? 0,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Birden fazla öğrenciye KDS ataması yapılamadı.');
    }
  }

  // Sınıf bazlı metodlar
  Future<List<dynamic>> getClassParticipation(int classId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/student-kds/class/$classId/not-joined'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Sınıf katılım bilgileri getirilemedi: ${response.body}');
      }
    } catch (error) {
      print('getClassParticipation error: $error');
      throw Exception('Sınıf katılım bilgileri getirilemedi');
    }
  }

  Future<List<dynamic>> getNonParticipatingStudents(int kdsId) async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/student-kds/kds/$kdsId/non-participating-students'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Katılmayan öğrenciler getirilemedi: ${response.body}');
      }
    } catch (error) {
      print('getNonParticipatingStudents error: $error');
      throw Exception('Katılmayan öğrenciler getirilemedi');
    }
  }

  // Excel'den öğrenci-KDS atamalarını veritabanına aktar

  Future<void> importKDSPointsFromExcel(File excelFile) async {
    // MIME türünü belirleyin
    final mimeType = excelFile.path.endsWith('.xlsx')
        ? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        : 'application/vnd.ms-excel';

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/student-kds/excel'),
    );

    // Dosya yüklerken MIME türünü manuel olarak belirtin
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      excelFile.path,
      contentType: MediaType.parse(mimeType), // Doğru MIME türü
    ));

    final response = await request.send();

    if (response.statusCode == 200) {
      print("Dosya başarıyla yüklendi.");
    } else {
      print("Dosya yükleme hatası: ${response.statusCode}");
    }
  }

  Future<Map<String, dynamic>> getStudentKDSParticipationDetails(
      int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student-kds/student/$studentId/kds-participation'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          // API'den gelen Map'i String key'li Map'e dönüştür
          Map<String, dynamic> convertedData = {
            'student_id': data['student_id']?.toString(),
            'student_name': data['student_name']?.toString(),
            'sinif_id': data['sinif_id']?.toString(),
            'sinif_adi': data['sinif_adi']?.toString(),
            'egitim_yili_id': data['egitim_yili_id']?.toString(),
            'totalKDS': data['totalKDS']?.toString(),
            'katilanKDSsayisi': data['katilanKDSsayisi']?.toString(),
            'katilmayanKDSsayisi': data['katilmayanKDSsayisi']?.toString(),
            'katilanKDSler': (data['katilanKDSler'] as List?)
                    ?.map((kds) => {
                          ...Map<String, dynamic>.from(kds),
                          'dogru': kds['dogru']?.toString() ?? '0',
                          'yanlis': kds['yanlis']?.toString() ?? '0',
                          'bos': kds['bos']?.toString() ?? '0',
                          'puan': kds['puan']?.toString() ?? '0',
                        })
                    .toList() ??
                [],
            'katilmayanKDSler': (data['katilmayanKDSler'] as List?)
                    ?.map((kds) => Map<String, dynamic>.from(kds))
                    .toList() ??
                [],
          };

          print("✅ Dönüştürülmüş veri: $convertedData"); // Debug için
          return convertedData;
        } else {
          throw Exception(data['error'] ?? 'Bilinmeyen bir hata oluştu');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
            errorData['error'] ?? 'KDS katılım detayları getirilemedi');
      }
    } catch (error) {
      print('getStudentKDSParticipationDetails error: $error');
      throw Exception('KDS katılım detayları getirilemedi: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getClassKDSAverages(
      int sinifId, int ogrenciId) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/student-kds/class/$sinifId/student/$ogrenciId/avarages'),
      );

      print("📌 API Response: ${response.body}"); // Yanıtı yazdır

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is! Map || !data.containsKey('kdsAverages')) {
          throw Exception(
              "Geçersiz JSON formatı! API yanıtı: ${response.body}");
        }

        return List<Map<String, dynamic>>.from(data['kdsAverages']);
      } else {
        throw Exception(
            "API Hatası: ${response.statusCode} - ${response.body}");
      }
    } catch (error) {
      print('❌ getClassKDSAverages error: $error');
      throw Exception('Sınıf ortalamaları getirilemedi: $error');
    }
  }
}
