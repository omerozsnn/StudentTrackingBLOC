// lib/blocs/student/student_repository.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:ogrenci_takip_sistemi/api.dart/studentControlApi.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';

class StudentRepository {
  final StudentApiService apiService;

  StudentRepository({required this.apiService});

  // Sayfalı öğrenci listesi getir
  Future<Map<String, dynamic>> getStudents(
      {int page = 1, int limit = 10}) async {
    return await apiService.getStudents(page: page, limit: limit);
  }

  // Tüm öğrencileri getir (dropdown için)
  Future<List<Student>> getStudentsForDropdown() async {
    return await apiService.getStudentsForDropdown();
  }

  // Sonsuz kaydırma için öğrencileri getir
  Future<List<Student>> getStudentsForScroll(
      {int limit = 10, int offset = 0}) async {
    return await apiService.getStudentsForScroll(limit: limit, offset: offset);
  }

  // Öğrencileri numaraya göre sırala
  Future<List<Student>> sortStudentsByNumber() async {
    return await apiService.sortStudentsByNumber();
  }

  // ID'ye göre öğrenci getir
  Future<Student> getStudentById(int id) async {
    return await apiService.getStudentById(id);
  }

  // ID'ye göre öğrenci numarası getir
  Future<String> getStudentNumberById(int id) async {
    return await apiService.getStudentNumberById(id);
  }

  // ID'ye göre öğrenci adı getir
  Future<String> getStudentNameById(int id) async {
    return await apiService.getStudentNameById(id);
  }

  // Sınıf ID'sine göre öğrencileri getir
  Future<List<Student>> getStudentsByClassId(int classId) async {
    return await apiService.getStudentsByClassId(classId);
  }

  // Sınıf adına göre öğrencileri getir
  Future<List<Student>> getStudentsByClassName(String className) async {
    try {
      print('Repository: Sınıfa göre öğrenciler getiriliyor: $className');
      final result = await apiService.getStudentsByClassName(className);
      print('Repository: ${result.length} öğrenci alındı');
      return result;
    } catch (e) {
      print('Repository: Sınıfa göre öğrenciler yüklenirken hata: $e');
      // Hata olursa boş liste döndür
      return [];
    }
  }

  // İsme göre öğrenci getir (kısmi eşleşme)
  Future<List<Student>> getStudentsByName(String name) async {
    return await apiService.getStudentsByName(name);
  }

  // Genel arama fonksiyonu (UI'da kullanılır)
  Future<List<Student>> searchStudents(String query) async {
    try {
      print('Repository: Arama yapılıyor: "$query"');
      if (query.isEmpty) {
        // Arama sorgusu boş ise, genel öğrenci listesini getir
        final result = await apiService.getStudents();
        print('Repository: Boş arama - ${(result['data'] as List).length} öğrenci bulundu');
        return result['data'] as List<Student>;
      }
      
      // İsme göre arama yap
      final results = await apiService.getStudentsByName(query);
      print('Repository: "$query" araması - ${results.length} öğrenci bulundu');
      return results;
    } catch (e) {
      print('Repository: Arama sırasında hata: $e');
      // Hata durumunda boş liste döndür
      return [];
    }
  }

  // Numaraya göre öğrenci getir
  Future<Student> getStudentByNumber(String studentNumber) async {
    return await apiService.getStudentByNumber(studentNumber);
  }

  // Yeni öğrenci ekle
  Future<Student> addStudent(Map<String, dynamic> studentData) async {
    return await apiService.addStudent(studentData);
  }

  // Öğrenci güncelle
  Future<Student> updateStudent(
      int id, Map<String, dynamic> studentData) async {
    return await apiService.updateStudent(id, studentData);
  }

  // Öğrenci sil
  Future<bool> deleteStudent(int id) async {
    return await apiService.deleteStudent(id);
  }

  // Öğrenci fotoğrafı yükle
  Future<String> uploadStudentPhoto(int id, File imageFile) async {
    return await apiService.uploadStudentImage(id, imageFile);
  }

  // Öğrenci fotoğrafını getir
  Future<Uint8List?> getStudentPhoto(int id) async {
    return await apiService.getStudentImage(id);
  }

  // Fotoğraf ile birlikte öğrenci getir
  Future<Student> getStudentWithImage(int id) async {
    return await apiService.getStudentWithImage(id);
  }

  // Excel'den öğrencileri içe aktar
  Future<bool> importStudentsFromExcel(File excelFile) async {
    return await apiService.importStudentsFromExcel(excelFile);
  }

  // Excel'den öğrencileri güncelle
  Future<bool> updateStudentsFromExcel(File excelFile) async {
    return await apiService.updateStudentsFromExcel(excelFile);
  }
}
