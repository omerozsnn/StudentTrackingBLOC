import 'package:ogrenci_takip_sistemi/api.dart/courseClassesApi.dart';
import 'package:ogrenci_takip_sistemi/models/course_classes_model.dart';

class CourseClassRepository {
  final ApiService apiService;

  CourseClassRepository({required this.apiService});

  // Tüm ders-sınıf atamalarını getir
  Future<List<CourseClass>> getCourseClasses() async {
    try {
      final courseClasses = await apiService.getAllCourseClasses();
      return courseClasses;
    } catch (e) {
      throw Exception('Ders-sınıf atamaları yüklenemedi: $e');
    }
  }

  // Sınıf ID'sine göre ders-sınıf atamalarını getir
  Future<List<CourseClass>> getCourseClassesByClassId(int classId) async {
    try {
      final courseClasses = await apiService.getCourseClassesByClassId(classId);
      return courseClasses;
    } catch (e) {
      throw Exception('Sınıfa ait ders atamaları yüklenemedi: $e');
    }
  }

  // Ders-sınıf ataması getir
  Future<CourseClass> getCourseClassById(int id) async {
    try {
      final courseClass = await apiService.getCourseClassById(id);
      return courseClass;
    } catch (e) {
      throw Exception('Ders-sınıf ataması yüklenemedi: $e');
    }
  }

  // Ders-sınıf ataması ekle
  Future<CourseClass> addCourseClass(CourseClass courseClass) async {
    try {
      await apiService.addCourseClass(courseClass);
      // API'den dönen veriyi kullanamadığımız için, eklenen ders-sınıf atamasını elle dönelim
      return courseClass;
    } catch (e) {
      throw Exception('Ders-sınıf ataması eklenemedi: $e');
    }
  }

  // Ders-sınıf ataması güncelle
  Future<CourseClass> updateCourseClass(CourseClass courseClass) async {
    try {
      await apiService.updateCourseClass(courseClass.id, courseClass);
      return courseClass;
    } catch (e) {
      throw Exception('Ders-sınıf ataması güncellenemedi: $e');
    }
  }

  // Ders-sınıf ataması sil
  Future<bool> deleteCourseClass(int id) async {
    try {
      await apiService.deleteCourseClass(id);
      return true;
    } catch (e) {
      throw Exception('Ders-sınıf ataması silinemedi: $e');
    }
  }

  // Sınıf ve ders ID'sine göre ders-sınıf ataması ID'sini getir
  Future<int?> getCourseClassIdByClassAndCourseId(int classId, int courseId) async {
    try {
      final id = await apiService.getCourseClassIdByClassAndCourseId(classId, courseId);
      return id;
    } catch (e) {
      throw Exception('Ders-sınıf ataması ID\'si bulunamadı: $e');
    }
  }
} 