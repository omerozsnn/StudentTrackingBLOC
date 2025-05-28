import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ogrenci_takip_sistemi/models/prayer_surah_model.dart';

class PrayerSurahApiService {
  final String baseUrl;

  PrayerSurahApiService({required this.baseUrl});

  // Dua veya sure ekle
  Future<PrayerSurah> addPrayerSurah(PrayerSurah prayerSurah) async {
    final response = await http.post(
      Uri.parse('$baseUrl/prayer-surah'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(prayerSurah.toJson()),
    );

    if (response.statusCode == 201) {
      return PrayerSurah.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add prayer or surah');
    }
  }

  // Tüm dua ve sureleri getir (Sayfalama ile)
  Future<List<PrayerSurah>> getAllPrayerSurahs(
      {int page = 1, int limit = 50}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/prayer-surah?page=$page&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final data = responseData['data'] as List;
      return data.map((surah) => PrayerSurah.fromJson(surah)).toList();
    } else {
      throw Exception('Failed to load all prayers or surahs');
    }
  }

  // Dua ve sureleri getir (Scroll ile)
  Future<List<PrayerSurah>> getPrayerSurahsScroll(
      {int limit = 10, int offset = 0}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/prayer-surah/scroll?limit=$limit&offset=$offset'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((surah) => PrayerSurah.fromJson(surah)).toList();
    } else {
      throw Exception('Failed to load prayers or surahs with scroll');
    }
  }

  // Dua veya sureyi getir (Drop-down için)
  Future<List<PrayerSurah>> getPrayerSurahsDropdown() async {
    final response =
        await http.get(Uri.parse('$baseUrl/prayer-surah/dropdown'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((surah) => PrayerSurah.fromJson(surah)).toList();
    } else {
      throw Exception('Failed to load prayer or surah dropdown');
    }
  }

  // Dua veya surenin adına göre id getir
  Future<int> getPrayerSurahIdByName(String name) async {
    final response =
        await http.get(Uri.parse('$baseUrl/prayer-surah/name/$name'));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['id']; // ID'yi döndür
    } else {
      throw Exception('Failed to load prayer or surah id by name');
    }
  }

  // Dua veya sureyi ID'ye göre getir
  Future<PrayerSurah> getPrayerSurahById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/prayer-surah/$id'));

    if (response.statusCode == 200) {
      return PrayerSurah.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load prayer or surah by ID');
    }
  }

  // Dua veya sureyi güncelle
  Future<PrayerSurah> updatePrayerSurah(int id, PrayerSurah prayerSurah) async {
    final response = await http.put(
      Uri.parse('$baseUrl/prayer-surah/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(prayerSurah.toJson()),
    );

    if (response.statusCode == 200) {
      return PrayerSurah.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update prayer or surah');
    }
  }

  // Dua veya sureyi sil
  Future<bool> deletePrayerSurah(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/prayer-surah/$id'));

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 404) {
      throw Exception('Dua sure bulunamadı.');
    } else {
      throw Exception('Dua sure silinirken bir hata oluştu.');
    }
  }

  // Dua ve sure transfer et
  Future<void> transferPrayerSurahs(int fromYearId, int toYearId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/prayer-surah/transfer'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'fromYearId': fromYearId, 'toYearId': toYearId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to transfer prayer or surah');
    }
  }

  Future<List<PrayerSurah>> getPrayerSurahIdsWithNames() async {
    final response = await http.get(Uri.parse('$baseUrl/prayer-surah/list'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((surah) => PrayerSurah.fromJson(surah)).toList();
    } else {
      throw Exception('Failed to load prayer or surah IDs with names');
    }
  }
}
