import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ogrenci_takip_sistemi/models/student_misbehaviour_model.dart';

class StudentMisbehaviourApiService {
  final String baseUrl;

  StudentMisbehaviourApiService({required this.baseUrl});

  // Yeni bir öğrenci yaramazlık kaydı ekle
  Future<StudentMisbehaviour> addStudentMisbehaviour(
      int ogrenciId, String tarih, int misbehaviourId,
      {String? aciklama}) async {
    final studentMisbehaviour = StudentMisbehaviour(
      ogrenciId: ogrenciId,
      yaramazlikId: misbehaviourId,
      tarih: tarih,
      aciklama: aciklama,
    );

    final response = await http.post(
      Uri.parse('$baseUrl/student-misbehaviour'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(studentMisbehaviour.toJson()),
    );

    if (response.statusCode == 201) {
      return StudentMisbehaviour.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add student misbehaviour: ${response.body}');
    }
  }

  // Öğrenci yaramazlık kaydını güncelle
  Future<StudentMisbehaviour> updateStudentMisbehaviour(
      int id, StudentMisbehaviour studentMisbehaviour) async {
    final response = await http.put(
      Uri.parse('$baseUrl/student-misbehaviour/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(studentMisbehaviour.toJson()),
    );

    if (response.statusCode == 200) {
      return StudentMisbehaviour.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to update student misbehaviour: ${response.body}');
    }
  }

  // Öğrenci yaramazlık kaydını sil
  Future<void> deleteStudentMisbehaviour(int id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/student-misbehaviour/$id'));

    if (response.statusCode != 204) {
      throw Exception(
          'Failed to delete student misbehaviour: ${response.body}');
    }
  }

  // Tüm öğrenci yaramazlık kayıtlarını getir
  Future<List<StudentMisbehaviour>> getAllStudentMisbehaviours() async {
    final response = await http.get(Uri.parse('$baseUrl/student-misbehaviour'));

    if (response.statusCode == 200) {
      List<dynamic> responseBody = json.decode(response.body);
      return responseBody
          .map((json) => StudentMisbehaviour.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load student misbehaviours: ${response.body}');
    }
  }

  // Öğrenci ID'sine göre yaramazlık kayıtlarını getir
  Future<List<StudentMisbehaviour>> getMisbehavioursByStudentId(
      int studentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/student-misbehaviour/student/$studentId'),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseBody = json.decode(response.body);
      return responseBody
          .map((json) => StudentMisbehaviour.fromJson(json))
          .toList();
    } else {
      throw Exception(
          'Failed to load misbehaviours by student ID: ${response.body}');
    }
  }

  // ID'ye göre öğrenci yaramazlık kaydını getir
  Future<StudentMisbehaviour> getStudentMisbehaviourById(int id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/student-misbehaviour/$id'));

    if (response.statusCode == 200) {
      return StudentMisbehaviour.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to load student misbehaviour by ID: ${response.body}');
    }
  }

  // Yaramazlık kayıtlarını tarihe göre gruplanmış olarak getir
  Future<Map<String, dynamic>> getMisbehavioursGroupedByDate(
      int studentId) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/student-misbehaviour/student/$studentId/grouped-by-date'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to load misbehaviours grouped by date: ${response.body}');
    }
  }
}
