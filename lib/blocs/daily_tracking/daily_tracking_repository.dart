import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ogrenci_takip_sistemi/api.dart/daily_tracking_api.dart';
import 'package:ogrenci_takip_sistemi/models/daily_tracking_model.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';
import 'package:intl/intl.dart';
import 'package:ogrenci_takip_sistemi/screens/daily_tracking/daily_tracking_screen.dart';

class DailyTrackingRepository {
  final String baseUrl;
  late final DailyTrackingAPI dailyTrackingAPI;

  DailyTrackingRepository({required this.baseUrl}) {
    dailyTrackingAPI = DailyTrackingAPI(baseUrl: baseUrl);
  }

  // Sınıfları getir
  Future<List<Classes>> getClasses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/class/dropdown'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((c) => Classes.fromJson(c)).toList();
      } else {
        throw Exception('Failed to load classes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading classes: $e');
    }
  }

  // Sınıfa göre öğrencileri getir
  Future<List<Student>> getStudentsByClass(int classId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/student/class/$classId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((s) => Student.fromJson(s)).toList();
      } else {
        throw Exception('Failed to load students: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading students: $e');
    }
  }

  // Belirli tarih aralığında takip verilerini getir
  Future<List<DailyTracking>> getTrackingDataByDateRange(
      String startDate, String endDate) async {
    try {
      return await dailyTrackingAPI.getDailyTrackingByDateRange(
          startDate, endDate);
    } catch (e) {
      throw Exception('Error loading tracking data: $e');
    }
  }

  // Takip verisi kaydet/güncelle
  Future<DailyTracking> saveTrackingData(DailyTracking tracking) async {
    try {
      return await dailyTrackingAPI.upsertDailyTracking(tracking);
    } catch (e) {
      throw Exception('Error saving tracking data: $e');
    }
  }

  // Sınıfa göre takip verilerini getir
  Future<List<DailyTracking>> getTrackingDataByClass(
      int classId, String startDate, String endDate) async {
    try {
      // Önce tüm veriyi al
      final allData = await dailyTrackingAPI.getDailyTrackingByDateRange(
          startDate, endDate);
      
      // Sınıfa göre filtrele
      return allData.where((tracking) => tracking.sinifId == classId).toList();
    } catch (e) {
      throw Exception('Error loading class tracking data: $e');
    }
  }

  // Haftalık toplamları getir
  Future<Map<String, dynamic>> getWeeklyTotalsByClass(int classId) async {
    try {
      return await dailyTrackingAPI.fetchWeeklyTotalsByClass(classId);
    } catch (e) {
      throw Exception('Error loading weekly totals: $e');
    }
  }

  // Öğrenci bazında haftalık toplamları getir
  Future<Map<String, dynamic>> getWeeklyTotalsByStudent(int studentId) async {
    try {
      return await dailyTrackingAPI.fetchWeeklyTotalsByStudent(studentId);
    } catch (e) {
      throw Exception('Error loading student weekly totals: $e');
    }
  }

  // Toplu veri kaydetme
  Future<List<DailyTracking>> bulkUpsertTrackingData(
      List<DailyTracking> trackings) async {
    try {
      return await dailyTrackingAPI.bulkUpsertDailyTrackings(trackings);
    } catch (e) {
      throw Exception('Error bulk saving tracking data: $e');
    }
  }

  // Belirli tarih ve sınıfa göre ders bazında veriyi getir
  Future<Map<String, List<DailyTracking>>> getTrackingDataByCourse(
      String date, int classId) async {
    try {
      return await dailyTrackingAPI.getDailyTrackingsByCourse(date, classId);
    } catch (e) {
      throw Exception('Error loading course tracking data: $e');
    }
  }
} 