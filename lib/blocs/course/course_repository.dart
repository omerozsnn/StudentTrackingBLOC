import 'dart:io';
import 'package:ogrenci_takip_sistemi/api.dart/courseApi.dart';
import 'package:ogrenci_takip_sistemi/models/courses_model.dart';

class CourseRepository {
  final ApiService apiService;

  CourseRepository({required this.apiService});

  // Tüm dersleri getir
  Future<List<Course>> getCourses() async {
    try {
      // First debug the raw response
      final rawResponse = await apiService.getCoursesRawResponse();
      print('Raw API response: $rawResponse');
      
      // Now try to get the actual courses
      final courses = await apiService.getCourses();
      return courses;
    } catch (e) {
      print('Dersler yüklenemedi: $e');
      // Return empty list instead of throwing to avoid crashing
      return [];
    }
  }

  // Sayfalandırılmış dersleri getir
  Future<List<Course>> getCoursesWithPagination(int page, int limit) async {
    try {
      final offset = (page - 1) * limit;
      final courses = await apiService.getCoursesForScroll(offset: offset, limit: limit);
      return courses;
    } catch (e) {
      throw Exception('Dersler yüklenemedi: $e');
    }
  }

  // Dropdown için dersleri getir
  Future<List<Course>> getCoursesForDropdown() async {
    try {
      final courses = await apiService.getCoursesForDropdown();
      return courses;
    } catch (e) {
      throw Exception('Dersler yüklenemedi: $e');
    }
  }

  // Ders ara
  Future<List<Course>> searchCourses(String query) async {
    try {
      final courses = await apiService.getCoursesByName(query);
      return courses;
    } catch (e) {
      throw Exception('Dersler aranırken hata oluştu: $e');
    }
  }

  // Ders getir
  Future<Course> getCourseById(int id) async {
    try {
      final course = await apiService.getCourseById(id);
      return course;
    } catch (e) {
      throw Exception('Ders yüklenemedi: $e');
    }
  }

  // Ders ekle
  Future<Course> addCourse(Course course) async {
    try {
      await apiService.addCourse(course);
      // API'den dönen veriyi kullanamadığımız için, eklenen dersi elle dönelim
      // Normal şartlarda API'den yeni eklenen dersin tüm bilgileri dönmelidir
      return course;
    } catch (e) {
      throw Exception('Ders eklenemedi: $e');
    }
  }

  // Ders güncelle
  Future<Course> updateCourse(Course course) async {
    try {
      await apiService.updateCourse(course.id, course);
      return course;
    } catch (e) {
      throw Exception('Ders güncellenemedi: $e');
    }
  }

  // Ders sil
  Future<bool> deleteCourse(int id) async {
    try {
      final response = await apiService.deleteCourse(id);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Ders silinemedi: $e');
    }
  }

  // Excel'den dersleri içe aktar
  Future<bool> importCoursesFromExcel(File file) async {
    try {
      // Excel içe aktarma API'si oluşturulmalı
      // await apiService.importCoursesFromExcel(file);
      return true;
    } catch (e) {
      throw Exception('Dersler Excel\'den içe aktarılamadı: $e');
    }
  }
} 