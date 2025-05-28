import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/daily_tracking_model.dart';

class DailyTrackingAPI {
  final String baseUrl;
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  DailyTrackingAPI({required this.baseUrl});

  Future<dynamic> _handleResponse(
      Future<http.Response> Function() request) async {
    try {
      final response = await request();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return null;
        return json.decode(response.body);
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  // Get all daily trackings
  Future<List<DailyTracking>> getAllDailyTrackings() async {
    final data = await _handleResponse(() =>
        http.get(Uri.parse('$baseUrl/daily-tracking'), headers: _headers));
    return (data as List).map((item) => DailyTracking.fromJson(item)).toList();
  }

  // Get daily tracking by ID
  Future<DailyTracking> getDailyTrackingById(int id) async {
    final data = await _handleResponse(() => http.get(
          Uri.parse('$baseUrl/daily-tracking/$id'),
          headers: _headers,
        ));
    return DailyTracking.fromJson(data);
  }

  // Get daily tracking by date
  Future<List<DailyTracking>> getDailyTrackingByDate(String date) async {
    final data = await _handleResponse(() => http.get(
          Uri.parse('$baseUrl/daily-tracking/date/$date'),
          headers: _headers,
        ));
    return (data as List).map((item) => DailyTracking.fromJson(item)).toList();
  }

  // Get daily trackings by student
  Future<List<DailyTracking>> getDailyTrackingsByStudent(int studentId) async {
    final data = await _handleResponse(() => http.get(
          Uri.parse('$baseUrl/daily-tracking/student/$studentId'),
          headers: _headers,
        ));
    return (data as List).map((item) => DailyTracking.fromJson(item)).toList();
  }

  // Get daily trackings by student and date
  Future<List<DailyTracking>> getDailyTrackingsByStudentAndDate(
      int studentId, String date) async {
    final data = await _handleResponse(() => http.get(
          Uri.parse('$baseUrl/daily-tracking/student/$studentId/date/$date'),
          headers: _headers,
        ));
    return (data as List).map((item) => DailyTracking.fromJson(item)).toList();
  }

  // Weekly totals by student
  Future<Map<String, dynamic>> getWeeklyTotalsByStudent(
      int studentId, String startDate, String endDate) async {
    return await _handleResponse(() => http.get(
          Uri.parse(
              '$baseUrl/daily-tracking/student/$studentId/weekly/$startDate/$endDate'),
          headers: _headers,
        ));
  }

  // Weekly totals by class
  Future<Map<String, dynamic>> getWeeklyTotalsByClass(
      int sinifId, String? startDate, String? endDate) async {
    String url = '$baseUrl/daily-tracking/weekly-totals/class/$sinifId';
    if (startDate != null && endDate != null) {
      url += '/$startDate/$endDate';
    }

    return await _handleResponse(
        () => http.get(Uri.parse(url), headers: _headers));
  }

  Future<Map<String, dynamic>> fetchWeeklyTotalsByClass(int sinifId) async {
    try {
      final startDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 7)));
      final endDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      return await getWeeklyTotalsByClass(sinifId, startDate, endDate);
    } catch (e) {
      print('Haftalık toplamları alırken hata oluştu: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchWeeklyTotalsByStudent(int studentId) async {
    try {
      final startDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().subtract(const Duration(days: 7)));
      final endDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      return await getWeeklyTotalsByStudent(studentId, startDate, endDate);
    } catch (e) {
      print('Haftalık toplamları alırken hata oluştu: $e');
      return {};
    }
  }

  // Get daily trackings by course
  Future<Map<String, List<DailyTracking>>> getDailyTrackingsByCourse(
      String date, int sinifId) async {
    final data = await _handleResponse(() => http.get(
          Uri.parse('$baseUrl/daily-tracking/course/$date/$sinifId'),
          headers: _headers,
        ));

    return Map<String, List<DailyTracking>>.fromEntries(
      (data as Map<String, dynamic>).entries.map((entry) {
        final key = entry.key;
        final value = (entry.value as List)
            .map((e) => DailyTracking.fromJson(e))
            .toList();
        return MapEntry(key, value);
      }),
    );
  }

  // Create new
  Future<DailyTracking> addDailyTracking(DailyTracking tracking) async {
    final data = await _handleResponse(() => http.post(
          Uri.parse('$baseUrl/daily-tracking'),
          headers: _headers,
          body: json.encode(tracking.toJson()),
        ));
    return DailyTracking.fromJson(data);
  }

  // Update
  Future<DailyTracking> updateDailyTracking(
      int id, DailyTracking tracking) async {
    final data = await _handleResponse(() => http.put(
          Uri.parse('$baseUrl/daily-tracking/$id'),
          headers: _headers,
          body: json.encode(tracking.toJson()),
        ));
    return DailyTracking.fromJson(data);
  }

  // Upsert
  Future<DailyTracking> upsertDailyTracking(DailyTracking tracking) async {
    final data = await _handleResponse(() => http.post(
          Uri.parse('$baseUrl/daily-tracking/upsert'),
          headers: _headers,
          body: json.encode(tracking.toJson()),
        ));
    return DailyTracking.fromJson(data);
  }

  // Bulk upsert
  Future<List<DailyTracking>> bulkUpsertDailyTrackings(
      List<DailyTracking> trackings) async {
    final payload = {
      'trackings': trackings.map((e) => e.toJson()).toList(),
    };
    final data = await _handleResponse(() => http.post(
          Uri.parse('$baseUrl/daily-tracking/bulk-upsert'),
          headers: _headers,
          body: json.encode(payload),
        ));

    return (data['results'] as List)
        .map((e) => DailyTracking.fromJson(e))
        .toList();
  }

  // Date range
  Future<List<DailyTracking>> getDailyTrackingByDateRange(
      String startDate, String endDate) async {
    final data = await _handleResponse(() => http.get(
          Uri.parse('$baseUrl/daily-tracking/date-range/$startDate/$endDate'),
          headers: _headers,
        ));
    return (data as List).map((e) => DailyTracking.fromJson(e)).toList();
  }
}
