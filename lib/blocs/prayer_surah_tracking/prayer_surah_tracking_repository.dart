import 'dart:typed_data';
import 'package:ogrenci_takip_sistemi/api.dart/prayerSurahTrackingControlApi.dart'
    as prayerSurahTrackingControlApi;
import 'package:ogrenci_takip_sistemi/api.dart/prayerSurahApi.dart';
import 'package:ogrenci_takip_sistemi/api.dart/prayerSurahStudentApi.dart';
import 'package:ogrenci_takip_sistemi/api.dart/studentControlApi.dart';
import 'package:ogrenci_takip_sistemi/api.dart/classApi.dart';
import 'package:ogrenci_takip_sistemi/models/prayer_surah_tracking_model.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:http/http.dart' as http;

class PrayerSurahTrackingRepository {
  final prayerSurahTrackingControlApi.ApiService prayerSurahTrackingApiService;
  final PrayerSurahApiService prayerSurahApiService;
  final PrayerSurahStudentApiService prayerSurahStudentApiService;
  final StudentApiService studentApiService;
  final ApiService classApiService;
  final String baseUrl;

  PrayerSurahTrackingRepository({
    required this.prayerSurahTrackingApiService,
    required this.prayerSurahApiService,
    required this.prayerSurahStudentApiService,
    required this.studentApiService,
    required this.classApiService,
    this.baseUrl = 'http://localhost:3000',
  });

  Future<List<String>> getClasses() async {
    try {
      final data = await classApiService.getClassesForDropdown();
      return data.map<String>((c) => c.sinifAdi).toList();
    } catch (error) {
      throw Exception('Classes could not be loaded: $error');
    }
  }

  Future<List<Student>> getStudentsByClassName(String className) async {
    try {
      return await studentApiService.getStudentsByClassName(className);
    } catch (error) {
      throw Exception('Students could not be loaded: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getAssignedSurahDua(
      String className) async {
    try {
      final int? classId = await classApiService.getClassIdByName(className);
      if (classId == null) {
        throw Exception('Class ID could not be found');
      }

      // Get assigned prayer/surah IDs for the class
      final assignedData = await prayerSurahStudentApiService
          .getPrayerSurahStudentByClassId(classId);

      // Get prayer/surah details with names
      final surahDuaDetails =
          await prayerSurahApiService.getPrayerSurahIdsWithNames();

      // Create ID -> name mapping
      final Map<int, String> surahDuaMap = {};
      for (var surah in surahDuaDetails) {
        if (surah is Map<String, dynamic>) {
          surahDuaMap[surah.id!] = surah.duaSureAdi;
        }
      }

      // Track already added IDs to avoid duplicates
      Set<int> addedSurahDuaIds = {};

      // Create the matched list
      List<Map<String, dynamic>> surahDuaList = [];
      for (var surah in assignedData) {
        if (surah is Map<String, dynamic>) {
          final int surahDuaId = surah.id!;

          if (!addedSurahDuaIds.contains(surahDuaId) &&
              surahDuaMap.containsKey(surahDuaId)) {
            surahDuaList.add({
              'dua_sure_id': surahDuaId,
              'dua_sure_adi': surahDuaMap[surahDuaId],
            });

            addedSurahDuaIds.add(surahDuaId);
          }
        }
      }

      return surahDuaList;
    } catch (error) {
      throw Exception(
          'Assigned prayers and surahs could not be loaded: $error');
    }
  }

  Future<Map<int, Map<String, dynamic>>> getStudentTrackings(
      List<Student> students, int? surahDuaId) async {
    Map<int, Map<String, dynamic>> trackingData = {};

    if (surahDuaId != null) {
      for (var student in students) {
        try {
          final trackings = await prayerSurahTrackingApiService
              .getPrayerSurahTrackingsByStudentId(student.id);

          // Default tracking status
          trackingData[student.id] = {
            'durum': 'Okumadı',
            'ekgorus': '',
            'degerlendirme': null,
          };

          // If there's a record for the selected prayer/surah, update the values
          if (trackings.isNotEmpty) {
            Map<String, dynamic>? trackingRecord;

            for (var tracking in trackings) {
              if (tracking is Map<String, dynamic> &&
                  tracking['prayer_surah_student'] is Map<String, dynamic> &&
                  tracking['prayer_surah_student']['dua_sure_id'] ==
                      surahDuaId) {
                trackingRecord = tracking;
                break;
              }
            }

            if (trackingRecord != null && trackingRecord.isNotEmpty) {
              trackingData[student.id] = {
                'durum': trackingRecord['durum'] ?? 'Okumadı',
                'ekgorus': trackingRecord['ekgorus'] ?? '',
                'degerlendirme': trackingRecord['degerlendirme'],
              };
            }
          }
        } catch (e) {
          // On error, use default values
          trackingData[student.id] = {
            'durum': 'Okumadı',
            'ekgorus': '',
            'degerlendirme': null,
          };
        }
      }
    }

    return trackingData;
  }

  Future<void> bulkUpdatePrayerSurahTracking(List<Student> students,
      int surahDuaId, Map<int, Map<String, dynamic>> studentTrackings) async {
    try {
      final classId = await classApiService
          .getClassIdByName(students.first.sinifId.toString());
      if (classId == null) {
        throw Exception('Class ID could not be found');
      }

      final allPrayerSurahData = await prayerSurahStudentApiService
          .getPrayerSurahStudentByClassId(classId);

      List<Map<String, dynamic>> trackingDataList = [];

      for (var student in students) {
        final int studentId = student.id;

        // Find the prayer/surah record for the student
        Map<String, dynamic>? studentPrayerSurah;

        for (var ps in allPrayerSurahData) {
          if (ps.duaSureId == surahDuaId && ps.ogrenciId == studentId) {
            studentPrayerSurah = ps.toJson();
            break;
          }
        }

        if (studentPrayerSurah == null) {
          continue; // Skip if no prayer/surah student record exists
        }

        // Get the tracking data for the student
        final tracking = studentTrackings[studentId];
        if (tracking == null) {
          continue;
        }

        // Prepare the data to send
        final trackingData = {
          'dua_sure_ogrenci_id': studentPrayerSurah['id'],
          'ekgorus': tracking['ekgorus'] ?? '',
          'durum': tracking['durum'],
          'degerlendirme': tracking['degerlendirme'],
        };

        trackingDataList.add(trackingData);
      }

      if (trackingDataList.isEmpty) {
        throw Exception('No records to update');
      }

      // Bulk API call
      await prayerSurahTrackingApiService
          .bulkUpdatePrayerSurahTracking(trackingDataList);
    } catch (error) {
      throw Exception('Bulk update failed: $error');
    }
  }

  Future<List<Map<String, dynamic>>> getPreviousTrackings(int studentId,
      {int? selectedSurahDuaId}) async {
    try {
      final List<dynamic> trackingsData = await prayerSurahTrackingApiService
          .getPrayerSurahTrackingsByStudentId(studentId);

      List<Map<String, dynamic>> loadedTrackings = [];

      for (var tracking in trackingsData) {
        if (tracking is Map<String, dynamic> &&
            tracking['prayer_surah_student'] is Map<String, dynamic> &&
            tracking['prayer_surah_student']['ogrenci_id'] == studentId) {
          // Apply filter if a surah/dua is selected
          if (selectedSurahDuaId == null ||
              tracking['prayer_surah_student']['dua_sure_id'] ==
                  selectedSurahDuaId) {
            final prayerSurah = tracking['prayer_surah_student']['prayer_surah']
                as Map<String, dynamic>?;

            final trackingData = {
              'id': tracking['id'],
              'degerlendirme':
                  tracking['degerlendirme'] ?? 'Değerlendirme bulunamadı',
              'dua_sure_adi': prayerSurah?['dua_sure_adi'] ?? 'Adı Bulunamadı',
              'createdAt': tracking['createdAt'],
              'ekgorus': tracking['ekgorus'] ?? '',
              'durum': tracking['durum'] ?? 'Durum bulunamadı',
            };
            loadedTrackings.add(trackingData);
          }
        }
      }

      return loadedTrackings;
    } catch (error) {
      throw Exception('Previous evaluations could not be loaded: $error');
    }
  }

  Future<Uint8List?> getStudentImage(int studentId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/student/$studentId/image'));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (error) {
      throw Exception('Student image could not be loaded: $error');
    }
  }
}
