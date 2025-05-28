import '../../models/student_homework_model.dart';
import '../../api.dart/studentHomeworkApi.dart';

class StudentHomeworkRepository {
  final StudentHomeworkApiService _apiService;

  StudentHomeworkRepository({StudentHomeworkApiService? apiService})
      : _apiService = apiService ?? StudentHomeworkApiService();

  // Tüm öğrenci ödevlerini getir
  Future<List<StudentHomework>> getAllStudentHomeworks() async {
    try {
      final studentHomeworksData = await _apiService.getAllStudentHomeworks();
      return studentHomeworksData
          .map((data) => StudentHomework.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to load student homeworks: $e');
    }
  }

  // ID'ye göre öğrenci ödevi getir
  Future<StudentHomework> getStudentHomeworkById(int id) async {
    try {
      final studentHomeworkData = await _apiService.getStudentHomeworkById(id);
      return StudentHomework.fromJson(studentHomeworkData);
    } catch (e) {
      throw Exception('Failed to load student homework: $e');
    }
  }

  // Öğrenci ID'sine göre ödevlerini getir
  Future<List<StudentHomework>> getStudentHomeworksByStudentId(
      int studentId) async {
    try {
      final studentHomeworksData =
          await _apiService.getStudentHomeworksByStudentId(studentId);
      return studentHomeworksData
          .map((data) => StudentHomework.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception(
          'Failed to load student homeworks for student ID $studentId: $e');
    }
  }

  // Yeni öğrenci ödevi ekle
  Future<void> addStudentHomework(StudentHomework studentHomework) async {
    try {
      await _apiService.addStudentHomework(studentHomework.toJson());
    } catch (e) {
      throw Exception('Failed to add student homework: $e');
    }
  }

  // Öğrenci ödevini güncelle
  Future<void> updateStudentHomework(StudentHomework studentHomework) async {
    if (studentHomework.id == null) {
      throw Exception('Cannot update student homework without ID');
    }

    try {
      await _apiService.updateStudentHomework(
          studentHomework.id!, studentHomework.toJson());
    } catch (e) {
      throw Exception('Failed to update student homework: $e');
    }
  }

  // Öğrenci ödevini sil
  Future<void> deleteStudentHomework(int id) async {
    try {
      await _apiService.deleteStudentHomework(id);
    } catch (e) {
      throw Exception('Failed to delete student homework: $e');
    }
  }

  // Sınıf ve ödev ID'sine göre öğrencileri getir
  Future<List<dynamic>> getStudentsByClassAndHomework(
      int classId, int homeworkId) async {
    try {
      return await _apiService.getStudentsByClassAndHomework(
          classId, homeworkId);
    } catch (e) {
      throw Exception('Failed to load students for homework: $e');
    }
  }

  // Toplu öğrenci ödevi güncelleme
  Future<Map<String, dynamic>> bulkUpdateStudentHomework(
      List<Map<String, dynamic>> updates) async {
    try {
      return await _apiService.bulkUpdateStudentHomework(updates);
    } catch (e) {
      throw Exception('Failed to bulk update student homeworks: $e');
    }
  }

  // Belirli öğrencilerin ödevlerini toplu olarak getir
  Future<List<StudentHomework>> bulkGetStudentHomework(
      List<int> studentIds) async {
    try {
      final studentHomeworksData =
          await _apiService.bulkGetStudentHomework(studentIds);
      return studentHomeworksData
          .map((data) => StudentHomework.fromJson(data))
          .toList();
    } catch (e) {
      throw Exception('Failed to bulk get student homeworks: $e');
    }
  }
}
