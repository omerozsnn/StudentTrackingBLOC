import '../../api.dart/ogrenciOkulDenemeleriApi.dart';
import '../../models/ogrenci_okul_denemesi_model.dart';

class OgrenciOkulDenemeleriRepository {
  final ApiService apiService;

  OgrenciOkulDenemeleriRepository({required this.apiService});

  // Tüm öğrenci okul denemelerini getir
  Future<List<OgrenciOkulDenemesi>> getAllOgrenciOkulDenemeleri() async {
    return await apiService.getAllOgrenciOkulDenemeleri();
  }

  // Belirli bir öğrencinin deneme sonuçlarını getir
  Future<List<OgrenciOkulDenemesi>> getOgrenciOkulDenemeleriByStudentId(
      int ogrenciId) async {
    return await apiService.getOgrenciOkulDenemeleriByStudentId(ogrenciId);
  }

  // Öğrenci deneme sonucunu oluştur veya güncelle
  Future<OgrenciOkulDenemesi> upsertOgrenciOkulDeneme(
      OgrenciOkulDenemesi data) async {
    return await apiService.upsertOgrenciOkulDeneme(data);
  }

  // Öğrenci deneme sonucunu sil
  Future<void> deleteOgrenciOkulDeneme(int id) async {
    await apiService.deleteOgrenciOkulDeneme(id);
  }

  // Sınıf için okul denemesi ortalamalarını getir
  Future<Map<String, dynamic>> getClassOkulDenemeAverages(
      int sinifId, int ogrenciId) async {
    return await apiService.getClassOkulDenemeAverages(sinifId, ogrenciId);
  }
}
