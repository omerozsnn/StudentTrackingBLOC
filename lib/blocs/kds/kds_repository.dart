import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:ogrenci_takip_sistemi/api.dart/kdsApi.dart';
import 'package:ogrenci_takip_sistemi/models/kds_model.dart';

class KDSRepository {
  final KDSApiService apiService;

  KDSRepository({required this.apiService});

  // Tüm KDS'leri getir
  Future<List<KDS>> getAllKDS() async {
    try {
      final kdsList = await apiService.getAllKDS();
      return kdsList;
    } catch (e) {
      debugPrint('KDS listesi yüklenemedi: $e');
      throw Exception('KDS listesi yüklenemedi: $e');
    }
  }

  // Belirli bir KDS'yi getir
  Future<KDS> getKDSById(int id) async {
    try {
      final kds = await apiService.getKDSById(id);
      return kds;
    } catch (e) {
      throw Exception('KDS yüklenemedi: $e');
    }
  }

  // Yeni bir KDS ekle
  Future<KDS> addKDS(KDS kds) async {
    try {
      final newKDS = await apiService.addKDS(kds);
      return newKDS;
    } catch (e) {
      throw Exception('KDS eklenemedi: $e');
    }
  }

  // KDS güncelle
  Future<KDS> updateKDS(int id, KDS kds) async {
    try {
      final updatedKDS = await apiService.updateKDS(id, kds);
      return updatedKDS;
    } catch (e) {
      throw Exception('KDS güncellenemedi: $e');
    }
  }

  // KDS sil
  Future<bool> deleteKDS(int id) async {
    try {
      await apiService.deleteKDS(id);
      return true;
    } catch (e) {
      throw Exception('KDS silinemedi: $e');
    }
  }

  // Üniteye ait KDS'leri getir
  Future<List<KDS>> getKDSByUnit(int unitId) async {
    try {
      final kdsList = await apiService.getKDSByUnit(unitId);
      return kdsList;
    } catch (e) {
      throw Exception('Üniteye ait KDS listesi yüklenemedi: $e');
    }
  }

  // KDS resimlerini getir
  Future<List<KDSImage>> getKDSImages(int kdsId) async {
    try {
      final images = await apiService.getKDSImages(kdsId);
      return images;
    } catch (e) {
      debugPrint('KDS resimleri yüklenemedi: $e');
      return [];
    }
  }

  // KDS resimlerini yükle
  Future<List<KDSImage>> addKDSImages(int kdsId, List<File> images) async {
    try {
      final uploadedImages = await apiService.addKDSImages(kdsId, images);
      return uploadedImages;
    } catch (e) {
      debugPrint('KDS resimleri yüklenemedi: $e');
      // Hata durumunda boş liste döndürelim, null değil
      return [];
    }
  }

  // KDS resmi sil
  Future<bool> deleteKDSImage(int imageId) async {
    try {
      await apiService.deleteKDSImage(imageId);
      return true;
    } catch (e) {
      throw Exception('KDS resmi silinemedi: $e');
    }
  }

  // KDS resim URL'i döndür
  String getKDSImageUrl(int imageId) {
    return apiService.getKDSImageUrl(imageId);
  }
}
