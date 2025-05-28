import 'package:ogrenci_takip_sistemi/api.dart/prayerSurahStudentApi.dart';
import 'package:ogrenci_takip_sistemi/models/prayer_surah_student_model.dart';

class PrayerSurahStudentRepository {
  final PrayerSurahStudentApiService apiService;

  PrayerSurahStudentRepository({required this.apiService});

  Future<PrayerSurahStudent> addPrayerSurahStudent(
      PrayerSurahStudent prayerSurahStudent) async {
    try {
      return await apiService.addPrayerSurahStudent(prayerSurahStudent);
    } catch (e) {
      throw Exception('Failed to add prayer surah student: $e');
    }
  }

  Future<List<PrayerSurahStudent>> getAllPrayerSurahStudents() async {
    try {
      return await apiService.getAllPrayerSurahStudents();
    } catch (e) {
      throw Exception('Failed to get all prayer surah students: $e');
    }
  }

  Future<List<PrayerSurahStudent>> getPrayerSurahStudentByStudentId(
      int studentId) async {
    try {
      return await apiService.getPrayerSurahStudentByStudentId(studentId);
    } catch (e) {
      throw Exception('Failed to get prayer surah student by student ID: $e');
    }
  }

  Future<List<PrayerSurahStudent>> getPrayerSurahStudentByClassId(
      int classId) async {
    try {
      return await apiService.getPrayerSurahStudentByClassId(classId);
    } catch (e) {
      throw Exception('Failed to get prayer surah students by class ID: $e');
    }
  }

  Future<PrayerSurahStudent> updatePrayerSurahStudent(
      int id, PrayerSurahStudent prayerSurahStudent) async {
    try {
      return await apiService.updatePrayerSurahStudent(id, prayerSurahStudent);
    } catch (e) {
      throw Exception('Failed to update prayer surah student: $e');
    }
  }

  Future<bool> deletePrayerSurahStudent(int id) async {
    try {
      return await apiService.deletePrayerSurahStudent(id);
    } catch (e) {
      throw Exception('Failed to delete prayer surah student: $e');
    }
  }

  Future<bool> assignPrayerSurahToMultipleStudents(
      int prayerSurahId, List<int> studentIds) async {
    try {
      return await apiService.assignPrayerSurahToMultipleStudents(
          prayerSurahId, studentIds);
    } catch (e) {
      throw Exception('Failed to assign prayer surah to multiple students: $e');
    }
  }
}
