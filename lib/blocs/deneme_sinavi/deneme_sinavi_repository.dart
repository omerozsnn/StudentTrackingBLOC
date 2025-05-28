import 'dart:io';
import 'package:ogrenci_takip_sistemi/api.dart/denemeSınaviApi.dart';
import 'package:ogrenci_takip_sistemi/models/deneme_sinavi_model.dart';
import 'package:flutter/foundation.dart';

class DenemeSinaviRepository {
  final ApiService apiService;

  DenemeSinaviRepository({required this.apiService});

  // Tüm deneme sınavlarını getir
  Future<List<DenemeSinavi>> getDenemeSinavlari() async {
    try {
      final denemeSinavlari = await apiService.getAllDenemeSinavi();
      return denemeSinavlari;
    } catch (e) {
      debugPrint('Deneme sınavları yüklenemedi: $e');
      return [];
    }
  }

  // Belirli bir deneme sınavını getir
  Future<DenemeSinavi> getDenemeSinaviById(int id) async {
    try {
      final denemeSinavi = await apiService.getDenemeSinaviById(id);
      return denemeSinavi;
    } catch (e) {
      throw Exception('Deneme sınavı yüklenemedi: $e');
    }
  }

  // Belirli bir üniteye ait deneme sınavlarını getir
  Future<List<DenemeSinavi>> getDenemeSinaviByUnit(int unitId) async {
    try {
      final denemeSinavlari = await apiService.getDenemeSinaviByUnit(unitId);
      return denemeSinavlari;
    } catch (e) {
      throw Exception('Üniteye ait deneme sınavları yüklenemedi: $e');
    }
  }

  // Deneme sınavı ekle
  Future<DenemeSinavi> addDenemeSinavi(DenemeSinavi denemeSinavi) async {
    try {
      final newDenemeSinavi = await apiService.createDenemeSinavi(denemeSinavi);
      return newDenemeSinavi;
    } catch (e) {
      throw Exception('Deneme sınavı eklenemedi: $e');
    }
  }

  // Deneme sınavı güncelle
  Future<DenemeSinavi> updateDenemeSinavi(DenemeSinavi denemeSinavi) async {
    try {
      if (denemeSinavi.id == null) {
        throw Exception('Deneme sınavı id boş olamaz!');
      }
      final updatedDenemeSinavi = await apiService.updateDenemeSinavi(denemeSinavi.id!, denemeSinavi);
      return updatedDenemeSinavi;
    } catch (e) {
      throw Exception('Deneme sınavı güncellenemedi: $e');
    }
  }

  // Deneme sınavı sil
  Future<bool> deleteDenemeSinavi(int id) async {
    try {
      final response = await apiService.deleteDenemeSinavi(id);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Deneme sınavı silinemedi: $e');
    }
  }

  // Excel'den deneme sınavlarını içe aktar (opsiyonel)
  Future<bool> importDenemeSinavlariFromExcel(File file) async {
    try {
      // Excel içe aktarma API'si oluşturulmalı
      // await apiService.importDenemeSinavlariFromExcel(file);
      return true;
    } catch (e) {
      throw Exception('Deneme sınavları Excel\'den içe aktarılamadı: $e');
    }
  }
} 