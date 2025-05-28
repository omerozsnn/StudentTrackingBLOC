import 'package:ogrenci_takip_sistemi/api.dart/defterKitapControlApi.dart';
import 'package:ogrenci_takip_sistemi/models/defter_kitap_model.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:ogrenci_takip_sistemi/api.dart/studentControlApi.dart';

class DefterKitapRepository {
  final ApiService defterKitapApi;
  final StudentApiService studentApi;

  DefterKitapRepository({
    required this.defterKitapApi,
    required this.studentApi,
  });

  // Get all dates for a specific course class ID
  Future<List<String>> getDatesByCourseClassId(int courseClassId) async {
    try {
      final List<dynamic> dates =
          await defterKitapApi.getDatesByCourseClassId(courseClassId);

      // Format dates to DD-MM-YYYY format
      final List<String> formattedDates = dates.map((date) {
        try {
          final DateTime parsedDate = DateTime.parse(date['tarih'] as String);
          return '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
        } catch (e) {
          return date['tarih'] as String;
        }
      }).toList();

      return formattedDates;
    } catch (error) {
      // 404 hatası durumunda boş liste dönder, bu bir hata değil normal durum
      if (error.toString().contains('404')) {
        print('Bu sınıf-ders için henüz kayıtlı tarih bulunmuyor (404)');
        return [];
      }
      throw Exception('Tarihler yüklenemedi: $error');
    }
  }

  // Get records for a specific date and course class
  Future<List<Map<String, dynamic>>> getDefterKitapByDateAndCourseClass(
      String date, int courseClassId) async {
    try {
      final result = await defterKitapApi.getDefterKitapByDateAndCourseClass(
          date, courseClassId);

      // Her bir DefterKitap nesnesini Map<String, dynamic>'e dönüştür
      List<Map<String, dynamic>> recordsAsMaps = result.map((defterKitap) {
        return {
          'id': defterKitap.id,
          'tarih': defterKitap.tarih,
          'defter_durum': defterKitap.defterDurum,
          'kitap_durum': defterKitap.kitapDurum,
          'egitimOgretimYiliId': defterKitap.egitimOgretimYiliId,
          'students': defterKitap.students,
          'courseClasses': defterKitap.courseClasses,
        };
      }).toList();

      return recordsAsMaps;
    } catch (error) {
      throw Exception('Defter-Kitap kayıtları yüklenemedi: $error');
    }
  }

  // Add or update defter-kitap record
  Future<void> addOrUpdateDefterKitap(
      Map<String, dynamic> defterKitapData) async {
    try {
      await defterKitapApi.addOrUpdateDefterKitap(defterKitapData);
    } catch (error) {
      throw Exception('Defter-Kitap kaydı güncellenemedi: $error');
    }
  }

  // Get students by class name
  Future<List<Student>> getStudentsByClassName(String className) async {
    try {
      print('StudentsByClassName çağrılıyor: [$className]');
      // Sınıf adı kontrolü - boşluk formatı kullanıldığından emin olalım
      // Eğer sınıf adı "6-A" formatında ise "6 A" formatına çevirelim
      if (className.contains('-')) {
        final parts = className.split('-');
        if (parts.length == 2) {
          className = '${parts[0]} ${parts[1]}';
          print('Sınıf adı formatı düzeltildi: $className');
        }
      }

      return await studentApi.getStudentsByClassName(className);
    } catch (error) {
      print('Öğrenciler yüklenirken hata: $error');
      // Hata durumunda boş liste dön
      return [];
    }
  }

  // Add or update multiple defter-kitap records at once
  Future<void> addOrUpdateMultipleDefterKitap(
      List<Map<String, dynamic>> defterKitapDataList) async {
    try {
      for (var defterKitapData in defterKitapDataList) {
        await defterKitapApi.addOrUpdateDefterKitap(defterKitapData);
      }
    } catch (error) {
      throw Exception('Defter-Kitap kayıtları güncellenemedi: $error');
    }
  }
}
