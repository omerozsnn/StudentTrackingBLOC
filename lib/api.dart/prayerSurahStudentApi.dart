import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ogrenci_takip_sistemi/models/prayer_surah_student_model.dart';

class PrayerSurahStudentApiService {
  final String baseUrl;

  PrayerSurahStudentApiService({required this.baseUrl});

  // Yeni bir dua-sure öğrenci kaydı ekle
  Future<PrayerSurahStudent> addPrayerSurahStudent(
      PrayerSurahStudent prayerSurahStudent) async {
    final response = await http.post(
      Uri.parse('$baseUrl/prayerSurahStudent'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(prayerSurahStudent.toJson()),
    );

    if (response.statusCode == 201) {
      return PrayerSurahStudent.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add prayer surah student: ${response.body}');
    }
  }

  // Tüm dua-sure öğrenci kayıtlarını getir
  Future<List<PrayerSurahStudent>> getAllPrayerSurahStudents() async {
    final response = await http.get(Uri.parse('$baseUrl/prayerSurahStudent'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => PrayerSurahStudent.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load prayer surah students: ${response.body}');
    }
  }

  // Tüm dua-sure öğrenci kayıtlarını getir (scroll ile)
  Future<List<PrayerSurahStudent>> getAllPrayerSurahStudentsScroll(
      int limit, int offset) async {
    final response = await http.get(
      Uri.parse('$baseUrl/prayerSurahStudent/$limit/$offset'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => PrayerSurahStudent.fromJson(item)).toList();
    } else {
      throw Exception(
          'Failed to load prayer surah students with scroll: ${response.body}');
    }
  }

  // Belirli bir dua-sure öğrenci kaydını ID'ye göre getir
  Future<List<PrayerSurahStudent>> getPrayerSurahStudentById(
      int studentId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/prayerSurahStudent/student/$studentId'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => PrayerSurahStudent.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load prayer surah students: ${response.body}');
    }
  }

  //ÖĞRENCİNİ İD'SİNE GÖRE DUA-SURE KAYITLARINI GETİR
  Future<List<PrayerSurahStudent>> getPrayerSurahStudentByStudentId(
      int studentId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/prayerSurahStudent/student/$studentId'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => PrayerSurahStudent.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load prayer surah students: ${response.body}');
    }
  }

  // Dua-sure öğrenci kaydını güncelle
  Future<PrayerSurahStudent> updatePrayerSurahStudent(
      int id, PrayerSurahStudent prayerSurahStudent) async {
    final response = await http.put(
      Uri.parse('$baseUrl/prayerSurahStudent/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(prayerSurahStudent.toJson()),
    );

    if (response.statusCode == 200) {
      return PrayerSurahStudent.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to update prayer surah student: ${response.body}');
    }
  }

  // Dua-sure öğrenci kaydını sil
  Future<bool> deletePrayerSurahStudent(int id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/prayerSurahStudent/$id'));

    if (response.statusCode == 204) {
      return true;
    } else {
      throw Exception(
          'Failed to delete prayer surah student: ${response.body}');
    }
  }

  // Sınıf id ye göre dua sure kaydını getir.
  Future<List<PrayerSurahStudent>> getPrayerSurahStudentByClassId(
      int classId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/prayerSurahStudent/class/$classId'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => PrayerSurahStudent.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load prayer surah students: ${response.body}');
    }
  }

  // Batch assignment - multiple students to one prayer/surah
  Future<bool> assignPrayerSurahToMultipleStudents(
      int prayerSurahId, List<int> studentIds) async {
    final List<Map<String, dynamic>> assignments = studentIds.map((studentId) {
      return {
        'dua_sure_id': prayerSurahId,
        'ogrenci_id': studentId,
      };
    }).toList();

    final response = await http.post(
      Uri.parse('$baseUrl/prayerSurahStudent/batch'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'assignments': assignments}),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception(
          'Failed to batch assign prayer surah to students: ${response.body}');
    }
  }
}
