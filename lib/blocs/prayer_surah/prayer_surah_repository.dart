import 'package:ogrenci_takip_sistemi/api.dart/prayerSurahApi.dart';
import 'package:ogrenci_takip_sistemi/models/prayer_surah_model.dart';

class PrayerSurahRepository {
  final PrayerSurahApiService apiService;

  PrayerSurahRepository({required this.apiService});

  Future<List<PrayerSurah>> getAllPrayerSurahs() async {
    try {
      return await apiService.getAllPrayerSurahs();
    } catch (e) {
      throw Exception('Failed to fetch prayer surahs: $e');
    }
  }

  Future<PrayerSurah> addPrayerSurah(PrayerSurah prayerSurah) async {
    try {
      return await apiService.addPrayerSurah(prayerSurah);
    } catch (e) {
      throw Exception('Failed to add prayer surah: $e');
    }
  }

  Future<PrayerSurah> updatePrayerSurah(PrayerSurah prayerSurah) async {
    try {
      return await apiService.updatePrayerSurah(prayerSurah.id!, prayerSurah);
    } catch (e) {
      throw Exception('Failed to update prayer surah: $e');
    }
  }

  Future<bool> deletePrayerSurah(int id) async {
    try {
      return await apiService.deletePrayerSurah(id);
    } catch (e) {
      throw Exception('Failed to delete prayer surah: $e');
    }
  }
}
