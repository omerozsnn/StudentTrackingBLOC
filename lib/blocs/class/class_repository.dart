import 'dart:io';
import 'package:ogrenci_takip_sistemi/api.dart/classApi.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';

class ClassRepository {
  final ApiService apiService;

  ClassRepository({required this.apiService});

  // Sınıfları getir
  Future<List<Classes>> getClasses({int page = 1, int limit = 10}) async {
    return await apiService.getClasses(page: page, limit: limit);
  }

  // Sınıfları Dropdown için getir
  Future<List<Classes>> getClassesForDropdown() async {
    return await apiService.getClassesForDropdown();
  }

  // Sınıfları Scroll için getir
  Future<List<Classes>> getClassesForScroll(
      {int offset = 0, int limit = 50}) async {
    return await apiService.getClassesForScroll(offset: offset, limit: limit);
  }

  // Sınıfları güncelle
  Future<void> updateClass(int id, Classes classData) async {
    return await apiService.updateClass(id, classData);
  }

  // Sınıf ID'sine göre sınıfı getir
  Future<Classes> getClassById(int id) async {
    return await apiService.getClassById(id);
  }

  // Sınıf adına göre sınıfları getir
  Future<List<Classes>> getClassByName(String name) async {
    return await apiService.getClassesByName(name);
  }

  // Sınıf sil
  Future<void> deleteClass(int id) async {
    return await apiService.deleteClass(id);
  }

  // Excel ile sınıf yükle
  Future<void> uploadClassExcel(File excelFile) async {
    return await apiService.uploadClassExcel(excelFile);
  }

  // Sınıf ekle
  Future<void> addClass(Classes classData, String sinifAdi) async {
    return await apiService.addClass(classData, sinifAdi: sinifAdi);
  }
}
