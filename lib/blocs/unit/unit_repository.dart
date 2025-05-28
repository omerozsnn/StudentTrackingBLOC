import 'dart:io';
import 'package:ogrenci_takip_sistemi/api.dart/unitsApi.dart';
import 'package:ogrenci_takip_sistemi/models/units_model.dart';
import 'package:flutter/foundation.dart';

class UnitRepository {
  final ApiService apiService;

  UnitRepository({required this.apiService});

  // Tüm üniteleri getir
  Future<List<Unit>> getUnits() async {
    try {
      final units = await apiService.getAllUnits();
      return units;
    } catch (e) {
      debugPrint('Üniteler yüklenemedi: $e');
      return [];
    }
  }

  // Belirli bir üniteyi getir
  Future<Unit> getUnitById(int id) async {
    try {
      final unit = await apiService.getUnitById(id);
      return unit;
    } catch (e) {
      throw Exception('Ünite yüklenemedi: $e');
    }
  }

  // Ünite adına göre üniteyi getir
  Future<Unit> getUnitByName(String unitName) async {
    try {
      final unit = await apiService.getUnitByName(unitName);
      return unit;
    } catch (e) {
      throw Exception('Ünite yüklenemedi: $e');
    }
  }

  // Ünite ekle
  Future<Unit> addUnit(Unit unit) async {
    try {
      final newUnit = await apiService.addUnit(unit);
      return newUnit;
    } catch (e) {
      throw Exception('Ünite eklenemedi: $e');
    }
  }

  // Ünite güncelle
  Future<Unit> updateUnit(Unit unit) async {
    try {
      final updatedUnit = await apiService.updateUnit(unit.id!, unit);
      return updatedUnit;
    } catch (e) {
      throw Exception('Ünite güncellenemedi: $e');
    }
  }

  // Ünite sil
  Future<bool> deleteUnit(int id) async {
    try {
      final response = await apiService.deleteUnit(id);
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Ünite silinemedi: $e');
    }
  }

  // Excel'den üniteleri içe aktar (opsiyonel)
  Future<bool> importUnitsFromExcel(File file) async {
    try {
      // Excel içe aktarma API'si oluşturulmalı
      // await apiService.importUnitsFromExcel(file);
      return true;
    } catch (e) {
      throw Exception('Üniteler Excel\'den içe aktarılamadı: $e');
    }
  }

  // Birden fazla ünite ekleme
  Future<List<Unit>> addMultipleUnits(List<String> unitNames) async {
    try {
      final units = await apiService.addMultipleUnits(unitNames);
      return units;
    } catch (e) {
      throw Exception('Üniteler eklenemedi: $e');
    }
  }
} 