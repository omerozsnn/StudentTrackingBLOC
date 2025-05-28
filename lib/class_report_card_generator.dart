import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:ogrenci_takip_sistemi/models/grades_model.dart';
import 'package:ogrenci_takip_sistemi/models/ogrenci_denemeleri_model.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// API servisleri için import'lar
import 'api.dart/classApi.dart' as classApi;
import 'api.dart/studentControlApi.dart' as studentControlApi;
import 'api.dart/teacherFeedbackApi.dart' as teacherFeedbackApi;
import 'api.dart/student_misbehaviour_api.dart' as misbehaviorControlApi;
import 'api.dart/prayerSurahTrackingControlApi.dart'
    as prayerSurahTrackingControlApi;
import 'api.dart/homeworkTrackingControlApi.dart' as homeworkTrackingControlApi;
import 'api.dart/studentHomeworkApi.dart' as studentHomeworkApi;
import 'api.dart/prayerSurahApi.dart' as prayerSurahApi;
import 'api.dart/defterKitapControlApi.dart' as defterKitapApi;
import 'api.dart/grades_api.dart' as notApi;
import 'api.dart/courseApi.dart' as courseApiService;
import 'api.dart/okulDenemeleriApi.dart' as okulDenemeleriApi;
import 'api.dart/ogrenciOkulDenemeleriApi.dart' as ogrenciOkulDenemeleriApi;
import 'api.dart/studentKdsApi.dart' as studentKDSApi;
import 'api.dart/ogrenciDenemeleriApi.dart' as ogrenciDenemeleriApi;

class ClassReportCardGenerator {
  final List<Student> students;
  final String className;
  final int classId;
  final int term; // Dönem: 1 veya 2
  final BuildContext context;

  // API servisleri
  final classApi.ApiService classService =
      classApi.ApiService(baseUrl: 'http://localhost:3000');
  final studentControlApi.StudentApiService studentService =
      studentControlApi.StudentApiService(baseUrl: 'http://localhost:3000');
  final misbehaviorControlApi.StudentMisbehaviourApiService misbehaviorService =
      misbehaviorControlApi.StudentMisbehaviourApiService(
          baseUrl: 'http://localhost:3000');
  final prayerSurahTrackingControlApi.ApiService prayerSurahService =
      prayerSurahTrackingControlApi.ApiService(
          baseUrl: 'http://localhost:3000');
  final homeworkTrackingControlApi.ApiService homeworkService =
      homeworkTrackingControlApi.ApiService(baseUrl: 'http://localhost:3000');
  final teacherFeedbackApi.ApiService feedbackService =
      teacherFeedbackApi.ApiService(baseUrl: 'http://localhost:3000');
  final studentHomeworkApi.StudentHomeworkApiService homeworkServis =
      studentHomeworkApi.StudentHomeworkApiService(
          baseUrl: 'http://localhost:3000');
  final prayerSurahApi.PrayerSurahApiService prayerSurahServis =
      prayerSurahApi.PrayerSurahApiService(baseUrl: 'http://localhost:3000');
  final defterKitapApi.ApiService defterKitapService =
      defterKitapApi.ApiService(baseUrl: 'http://localhost:3000');
  final notApi.GradesRepository gradesApiService =
      notApi.GradesRepository(baseUrl: 'http://localhost:3000');
  final courseApiService.ApiService courseApi =
      courseApiService.ApiService(baseUrl: 'http://localhost:3000');
  final okulDenemeleriApi.ApiService okulDenemeleriApiService =
      okulDenemeleriApi.ApiService(baseUrl: 'http://localhost:3000');
  final ogrenciOkulDenemeleriApi.ApiService ogrenciOkulDenemeleriApiService =
      ogrenciOkulDenemeleriApi.ApiService(baseUrl: 'http://localhost:3000');
  final studentKDSApi.ApiService studentKDSApiService =
      studentKDSApi.ApiService(baseUrl: 'http://localhost:3000');
  final ogrenciDenemeleriApi.StudentExamRepository ogrenciDenemeleriApiService =
      ogrenciDenemeleriApi.StudentExamRepository(
          baseUrl: 'http://localhost:3000');

  // Fontlar
  late pw.Font ttf;
  late pw.Font boldTtf;

  ClassReportCardGenerator({
    required this.students,
    required this.className,
    required this.classId,
    required this.term,
    required this.context,
  });

  Future<Uint8List> generateClassReportCardPdf() async {
    final pdf = pw.Document();

    // Fontları yükle
    final fontData = await rootBundle.load("assets/DejaVuSans.ttf");
    ttf = pw.Font.ttf(fontData.buffer.asByteData());

    final boldFontData = await rootBundle.load("assets/dejavu-sans-bold.ttf");
    boldTtf = pw.Font.ttf(boldFontData.buffer.asByteData());

    // Öğrencileri numaraya göre sırala
    students.sort((a, b) {
      final aNo = int.tryParse(a.ogrenciNo?.toString() ?? '0') ?? 0;
      final bNo = int.tryParse(b.ogrenciNo?.toString() ?? '0') ?? 0;
      return aNo.compareTo(bNo);
    });

    const batchSize = 3; // Aynı anda en fazla 5 öğrenci işle
    for (int i = 0; i < students.length; i += batchSize) {
      final batch =
          students.sublist(i, (i + batchSize).clamp(0, students.length));

      // 5 öğrenciyi paralel olarak işlerken, her grup arasında 5 saniye bekle
      await Future.wait(batch.map((student) async {
        final studentId = student.id;

        _showProgressMessage(
            '${i + 1}/${students.length} - ${student.adSoyad} öğrencisi için karne hazırlanıyor...');

        try {
          final Map<String, dynamic> studentData =
              await _loadStudentData(studentId, student);

          pdf.addPage(
            pw.MultiPage(
              pageFormat: PdfPageFormat.a4,
              build: (pw.Context context) =>
                  _buildReportCardContent(studentData, student),
            ),
          );
        } catch (e) {
          print(
              'Öğrenci ${student.adSoyad} için karne oluşturulurken hata: $e');

          pdf.addPage(
            pw.MultiPage(
              pageFormat: PdfPageFormat.a4,
              build: (pw.Context context) =>
                  _buildErrorReportContent(student, e.toString()),
            ),
          );
        }
      }));

      // 📌 **Her 5 öğrenciden sonra 5 saniye bekleyelim**
      await Future.delayed(Duration(seconds: 1));
    }

    return pdf.save();
  }

// Hata durumunda basit bir sayfa oluştur
  List<pw.Widget> _buildErrorReportContent(
      Student student, String errorMessage) {
    return [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(
              child: pw.Text('Öğrenci Karnesi',
                  style: pw.TextStyle(font: boldTtf, fontSize: 16))),
          pw.Divider(thickness: 2),
          pw.SizedBox(height: 20),
          pw.Text('Öğrenci: ${student.adSoyad}',
              style: pw.TextStyle(font: boldTtf, fontSize: 14)),
          pw.Text('Numara: ${student.ogrenciNo}',
              style: pw.TextStyle(font: ttf, fontSize: 12)),
          pw.Text('Sınıf: $className',
              style: pw.TextStyle(font: ttf, fontSize: 12)),
          pw.SizedBox(height: 30),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.red50,
              border: pw.Border.all(color: PdfColors.red),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Karne bilgileri yüklenirken bir sorun oluştu',
                    style: pw.TextStyle(
                        font: boldTtf, fontSize: 12, color: PdfColors.red)),
                pw.SizedBox(height: 10),
                pw.Text(
                    'Öğrenci verilerini alırken teknik bir sorun yaşandı. ' +
                        'Lütfen daha sonra tekrar deneyin veya sistem yöneticisine başvurun.',
                    style: pw.TextStyle(font: ttf, fontSize: 10)),
                pw.SizedBox(height: 10),
                pw.Text('Teknik hata detayı: ',
                    style: pw.TextStyle(font: boldTtf, fontSize: 8)),
                pw.Text(errorMessage,
                    style: pw.TextStyle(
                        font: ttf, fontSize: 8, color: PdfColors.grey700)),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  void _showProgressMessage(String message) {
    // Bu fonksiyon sadece debug amaçlı
    print(message);
  }

  Future<Map<String, dynamic>> _loadStudentData(
      int studentId, Student student) async {
    Map<String, dynamic> result = {
      'studentImage': null,
      'groupedFeedbacks': {},
      'misbehaviours': [],
      'prayerSurahTrackings': [],
      'homeworkTrackings': [],
      'notebookBookHistory': [],
      'grades': [],
      'kdsScores': [],
      'kdsParticipationData': {},
      'denemeScores': [],
      'denemeParticipationData': {},
      'okulDenemeleri': [],
      'okulDenemeParticipationData': {},
    };

    try {
      // **1. Paralel olarak yüklenebilecek işlemleri aynı anda çalıştır**
      List<Future<void>> parallelTasks = [];

      parallelTasks.add(Future(() async {
        try {
          result['studentImage'] = await _loadStudentImage(studentId);
          print('${student.adSoyad} için resim yüklendi');
        } catch (e) {
          print('Öğrenci resmi yüklenemedi: $e');
        }
      }));

      parallelTasks.add(Future(() async {
        try {
          result['groupedFeedbacks'] = await _loadGroupedFeedbacks(studentId);
          print('${student.adSoyad} için öğretmen görüşleri yüklendi');
        } catch (e) {
          print('Öğretmen görüşleri yüklenemedi: $e');
        }
      }));

      parallelTasks.add(Future(() async {
        try {
          result['misbehaviours'] = await _loadMisbehaviours(studentId);
          print('${student.adSoyad} için yaramazlıklar yüklendi');
        } catch (e) {
          print('Yaramazlıklar yüklenemedi: $e');
        }
      }));

      parallelTasks.add(Future(() async {
        try {
          result['prayerSurahTrackings'] =
              await _loadPrayerSurahTrackings(studentId);
          print('${student.adSoyad} için dua/sure takibi yüklendi');
        } catch (e) {
          print('Dua/sure takibi yüklenemedi: $e');
        }
      }));

      // **Tüm bağımsız işlemleri aynı anda çalıştır**
      await Future.wait(parallelTasks);

      // **2. İkinci Grup Paralel İşlemler (Bağımsız Olanlar)**
      List<Future<void>> secondaryTasks = [];

      secondaryTasks.add(Future(() async {
        try {
          result['homeworkTrackings'] = await _loadHomeworkTrackings(studentId);
          print('${student.adSoyad} için ödev takibi yüklendi');
        } catch (e) {
          print('Ödev takibi yüklenemedi: $e');
        }
      }));

      secondaryTasks.add(Future(() async {
        try {
          result['notebookBookHistory'] =
              await _loadNotebookAndBookHistory(studentId);
          print('${student.adSoyad} için defter/kitap geçmişi yüklendi');
        } catch (e) {
          print('Defter ve kitap geçmişi yüklenemedi: $e');
        }
      }));

      secondaryTasks.add(Future(() async {
        try {
          result['grades'] = await _loadGrades(studentId);
          print('${student.adSoyad} için notlar yüklendi');
        } catch (e) {
          print('Notlar yüklenemedi: $e');
        }
      }));

      // **İkinci grup işlemleri aynı anda başlat**
      await Future.wait(secondaryTasks);

      // **3. KDS ve Deneme İşlemleri**
      try {
        result['kdsScores'] = await _loadKDSScores(studentId);
        print('${student.adSoyad} için KDS puanları yüklendi');
      } catch (e) {
        print('KDS puanları yüklenemedi: $e');
      }

      try {
        result['kdsParticipationData'] =
            await _loadKDSParticipationData(studentId);
        print('${student.adSoyad} için KDS katılım verileri yüklendi');
      } catch (e) {
        print('KDS katılım verileri yüklenemedi: $e');
      }

      try {
        result['denemeScores'] = await _loadDenemeScores(studentId);
        print('${student.adSoyad} için deneme puanları yüklendi');
      } catch (e) {
        print('Deneme puanları yüklenemedi: $e');
      }

      try {
        result['denemeParticipationData'] =
            await _loadDenemeParticipation(studentId);
        print('${student.adSoyad} için deneme katılım verileri yüklendi');
      } catch (e) {
        print('Deneme katılım verileri yüklenemedi: $e');
      }

      // **4. Okul Denemeleri İşlemleri**
      try {
        result['okulDenemeleri'] = await _loadOkulDenemeleri(studentId);
        print('${student.adSoyad} için okul denemeleri yüklendi');
      } catch (e) {
        print('Okul denemeleri yüklenemedi: $e');
      }

      try {
        result['okulDenemeParticipationData'] =
            await _loadOkulDenemeleriParticipation(studentId);
        print('${student.adSoyad} için okul deneme katılım verileri yüklendi');
      } catch (e) {
        print('Okul deneme katılım verileri yüklenemedi: $e');
      }
    } catch (error) {
      print('Öğrenci verileri yüklenirken hata oluştu: $error');
    }

    return result;
  }

  // Öğrenci fotoğrafını yükle
  Future<Uint8List?> _loadStudentImage(int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/student/$studentId/image'),
        headers: {'Accept': 'image/*'},
      );

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return response.bodyBytes;
      }
      return null;
    } catch (error) {
      print('Öğrenci resmi yüklenemedi: $error');
      return null;
    }
  }

  // Öğretmen görüşlerini yükle
  Future<Map<String, List<dynamic>>> _loadGroupedFeedbacks(
      int studentId) async {
    try {
      final feedbacksData =
          await feedbackService.getTeacherFeedbackByStudentIdandDate(studentId);
      return feedbacksData;
    } catch (error) {
      print('Öğretmen görüşleri yüklenemedi: $error');
      return {};
    }
  }

  // Yaramazlıkları yükle
  Future<List<Map<String, dynamic>>> _loadMisbehaviours(int studentId) async {
    try {
      final assignedData =
          await misbehaviorService.getMisbehavioursByStudentId(studentId);
      List<Map<String, dynamic>> loadedMisbehaviours = [];

      for (var misbehaviour in assignedData) {
        loadedMisbehaviours.add({
          'yaramazlık_adi': misbehaviour.misbehaviour!.yaramazlikAdi,
          'tarih': misbehaviour.tarih,
        });
      }

      return loadedMisbehaviours;
    } catch (error) {
      print('Yaramazlıklar yüklenemedi: $error');
      return [];
    }
  }

  // Dua/sure takiplerini yükle
  Future<List<Map<String, dynamic>>> _loadPrayerSurahTrackings(
      int studentId) async {
    try {
      final trackingsData = await prayerSurahService
          .getPrayerSurahTrackingsByStudentId(studentId);
      List<Map<String, dynamic>> loadedTrackings = [];

      for (var tracking in trackingsData) {
        int? duaSureId = tracking['prayer_surah_student']?['dua_sure_id'];
        if (duaSureId != null) {
          final prayerSurahDetail =
              await prayerSurahServis.getPrayerSurahById(duaSureId);
          loadedTrackings.add({
            'id': tracking['id'],
            'degerlendirme':
                tracking['degerlendirme'] ?? 'Değerlendirme bulunamadı',
            'durum': tracking['durum'] ?? 'Durum bulunamadı',
            'dua_sure_adi': prayerSurahDetail['dua_sure_adi'] ?? 'Adı Yok',
            'createdAt': tracking['createdAt'],
          });
        }
      }

      return loadedTrackings;
    } catch (error) {
      print('Dua/sure takibi yüklenemedi: $error');
      return [];
    }
  }

  // Ödev takiplerini yükle
  Future<List<Map<String, dynamic>>> _loadHomeworkTrackings(
      int studentId) async {
    try {
      final assignmentList =
          await homeworkServis.getStudentHomeworksByStudentId(studentId);
      List<Map<String, dynamic>> loadedAssignments = [];
      Map<int, String> savedStatuses = {};

      for (var studentHomework in assignmentList) {
        var homework = studentHomework['homework'];
        if (homework != null) {
          int assignmentId = studentHomework['id'];

          // Ödev durumunu kontrol et
          final savedTracking = await homeworkService
              .getHomeworkTrackingByStudentHomeworkId(assignmentId);
          if (savedTracking.isNotEmpty) {
            savedStatuses[assignmentId] = savedTracking[0]['durum'];
          } else {
            savedStatuses[assignmentId] = 'Değerlendirme yok';
          }

          loadedAssignments.add({
            'odev_adi': homework['odev_adi'] ?? 'Adı Yok',
            'teslim_tarihi': homework['teslim_tarihi'] ?? 'Teslim Tarihi Yok',
            'id': assignmentId,
            'durum': savedStatuses[assignmentId],
          });
        }
      }

      return loadedAssignments;
    } catch (error) {
      print('Ödev takibi yüklenemedi: $error');
      return [];
    }
  }

  // Defter/kitap takibini yükle
  Future<List<Map<String, dynamic>>> _loadNotebookAndBookHistory(
      int studentId) async {
    try {
      final historyData =
          await defterKitapService.getDefterKitapByStudentId(studentId);
      List<Map<String, dynamic>> loadedHistory = [];

      for (var entry in historyData) {
        // Sadece defter veya kitap durumu 'getirmedi' olanları al
        if (entry.defterDurum?.toLowerCase() == 'getirmedi' ||
            entry.kitapDurum?.toLowerCase() == 'getirmedi') {
          String dersAdi = 'Ders Yok';
          if (entry.courseClasses != null &&
              entry.courseClasses!.isNotEmpty &&
              entry.courseClasses![0]['ders_id'] != null) {
            int dersId = entry.courseClasses![0]['ders_id'];

            try {
              final dersData = await courseApi.getCourseById(dersId);
              dersAdi = dersData.dersAdi ?? 'Ders Adı Bulunamadı';
            } catch (e) {
              print('Ders adı alınamadı: $e');
            }
          }

          loadedHistory.add({
            'tarih': entry.tarih ?? 'Tarih Yok',
            'defter_durum': entry.defterDurum ?? 'Defter Durumu Yok',
            'kitap_durum': entry.kitapDurum ?? 'Kitap Durumu Yok',
            'ders_adi': dersAdi,
          });
        }
      }

      return loadedHistory;
    } catch (error) {
      print('Defter ve kitap geçmişi yüklenemedi: $error');
      return [];
    }
  }

  // Öğrenci notlarını yükle
  Future<List<Map<String, dynamic>>> _loadGrades(int studentId) async {
    try {
      final semesterGrades =
          await gradesApiService.getStudentSemesterGrades(studentId, term);
      final dersler = semesterGrades.dersler;

      final studentGrades = dersler.map((grade) {
        return {
          'ders_adi': grade.dersAdi ?? 'Ders Yok',
          'sinav1': grade.sinav1?.toString() ?? ' - ',
          'sinav2': grade.sinav2?.toString() ?? ' - ',
          'sinav3': grade.sinav3?.toString() ?? ' - ',
          'sinav4': grade.sinav4?.toString() ?? ' - ',
          'proje1': grade.proje1?.toString() ?? ' - ',
          'proje2': grade.proje2?.toString() ?? ' - ',
          'ders_etkinlikleri1': grade.dersEtkinlikleri1?.toString() ?? ' - ',
          'ders_etkinlikleri2': grade.dersEtkinlikleri2?.toString() ?? ' - ',
          'ders_etkinlikleri3': grade.dersEtkinlikleri3?.toString() ?? ' - ',
          'donem_puani': grade.donemPuani?.toString() ?? ' - ',
        };
      }).toList();

      return studentGrades;
    } catch (error) {
      print('Notlar yüklenemedi: $error');
      return [];
    }
  }

  // KDS notlarını yükle
  Future<List<Map<String, dynamic>>> _loadKDSScores(int studentId) async {
    try {
      final kdsData = await studentKDSApiService.getStudentKDSScores(studentId);
      return List<Map<String, dynamic>>.from(kdsData);
    } catch (error) {
      print('KDS puanları yüklenemedi: $error');
      return [];
    }
  }

  // KDS katılım verilerini yükle
  Future<Map<String, dynamic>> _loadKDSParticipationData(int studentId) async {
    try {
      final kdsData = await studentKDSApiService
          .getStudentKDSParticipationDetails(studentId);
      return kdsData;
    } catch (error) {
      print('KDS katılım verileri yüklenemedi: $error');
      return {};
    }
  }

  // Deneme notlarını yükle
  Future<List<Map<String, dynamic>>> _loadDenemeScores(int studentId) async {
    try {
      final denemeData = await ogrenciDenemeleriApiService
          .getStudentExamResultsByStudentId(studentId);
      return List<Map<String, dynamic>>.from(denemeData);
    } catch (error) {
      print('Deneme puanları yüklenemedi: $error');
      return [];
    }
  }

  // Deneme katılım verilerini yükle
  Future<StudentExamParticipation?> _loadDenemeParticipation(
      int studentId) async {
    try {
      final denemeData = await ogrenciDenemeleriApiService
          .getStudentExamParticipation(studentId);
      return denemeData;
    } catch (error) {
      print('Deneme katılım verileri yüklenemedi: $error');
      return null;
    }
  }

  // Okul denemeleri yükle
  Future<List<Map<String, dynamic>>> _loadOkulDenemeleri(int studentId) async {
    try {
      final okulDenemesiData = await ogrenciOkulDenemeleriApiService
          .getOgrenciOkulDenemeleriByStudentId(studentId);
      return List<Map<String, dynamic>>.from(okulDenemesiData);
    } catch (error) {
      print('Okul denemeleri yüklenemedi: $error');
      return [];
    }
  }

  // Okul denemeleri katılım verilerini yükle
  Future<Map<String, dynamic>> _loadOkulDenemeleriParticipation(
      int studentId) async {
    try {
      final okulDenemeleriData = await ogrenciOkulDenemeleriApiService
          .getClassOkulDenemeAverages(classId, studentId);
      return okulDenemeleriData;
    } catch (error) {
      print('Okul deneme katılım verileri yüklenemedi: $error');
      return {};
    }
  }

  // PDF içeriğini oluştur
  List<pw.Widget> _buildReportCardContent(
      Map<String, dynamic> studentData, Student student) {
    pw.MemoryImage? studentPdfImage;
    try {
      if (studentData['studentImage'] != null) {
        studentPdfImage =
            pw.MemoryImage(studentData['studentImage'] as Uint8List);
      }
    } catch (e) {
      print('Öğrenci fotoğrafı PDF için hazırlanamadı: $e');
    }

    return [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Başlık
          pw.Center(
              child: pw.Text('Öğrenci Karnesi',
                  style: pw.TextStyle(font: boldTtf, fontSize: 16))),

          // Başlık altı çizgi
          pw.Divider(thickness: 2),

          // Öğrenci bilgileri
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (studentPdfImage != null)
                pw.Container(
                  width: 80,
                  height: 100,
                  child: pw.ClipRRect(
                    horizontalRadius: 8,
                    verticalRadius: 8,
                    child: pw.Image(studentPdfImage, fit: pw.BoxFit.cover),
                  ),
                ),
              pw.SizedBox(width: 5, height: 20),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Öğrenci: ${student.adSoyad}',
                        style: pw.TextStyle(font: ttf, fontSize: 12)),
                    pw.Text('Numara: ${student.ogrenciNo}',
                        style: pw.TextStyle(font: ttf, fontSize: 12)),
                    pw.Text('Sınıf: $className',
                        style: pw.TextStyle(font: ttf, fontSize: 12)),
                    if (student.anneAdi != null &&
                        student.anneAdi.toString().isNotEmpty)
                      pw.Text('Anne Adı: ${student.anneAdi}',
                          style: pw.TextStyle(font: ttf, fontSize: 12)),
                    if (student.babaAdi != null &&
                        student.babaAdi.toString().isNotEmpty)
                      pw.Text('Baba Adı: ${student.babaAdi}',
                          style: pw.TextStyle(font: ttf, fontSize: 12)),
                    pw.SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),

          // Dönem bilgisi
          pw.Text('${term}. Dönem Karnesi',
              style: pw.TextStyle(font: boldTtf, fontSize: 14)),
          pw.SizedBox(height: 10),

          // Öğretmen Görüşleri
          _buildTeacherFeedbackSection(studentData['groupedFeedbacks']),
          pw.SizedBox(height: 10),

          // Ödev Takibi
          _buildHomeworkSection(studentData['homeworkTrackings']),
          pw.SizedBox(height: 10),

          // Dua/Sure Takibi
          _buildPrayerTrackingSection(studentData['prayerSurahTrackings']),
          pw.SizedBox(height: 10),

          // Defter/Kitap Takibi
          _buildNotebookBookSection(studentData['notebookBookHistory']),
          pw.SizedBox(height: 10),

          // Yaramazlık Takibi
          _buildMisbehaviourSection(studentData['misbehaviours']),
          pw.SizedBox(height: 10),

          // Öğrenci Notları
          _buildGradesSection(studentData['grades']),
          pw.SizedBox(height: 10),

          // KDS Bilgileri
          _buildKdsSection(
              studentData['kdsScores'], studentData['kdsParticipationData']),
          pw.SizedBox(height: 10),

          // Deneme Sınavları
          _buildDenemeSection(studentData['denemeScores'],
              studentData['denemeParticipationData']),
          pw.SizedBox(height: 10),

          // Okul Denemeleri
          _buildOkulDenemeSection(studentData['okulDenemeleri'],
              studentData['okulDenemeParticipationData']),
        ],
      ),
    ];
  }

  // Öğretmen görüşleri bölümünü oluştur
  pw.Widget _buildTeacherFeedbackSection(
      Map<String, List<dynamic>> groupedFeedbacks) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Öğretmen Görüşleri:',
            style: pw.TextStyle(font: boldTtf, fontSize: 12)),
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 2),
        if (groupedFeedbacks.isEmpty)
          pw.Text('Öğretmen görüşü kaydı bulunmamaktadır.',
              style: pw.TextStyle(
                  font: ttf, fontSize: 10, color: PdfColors.grey700)),
        ...groupedFeedbacks.entries.map((entry) {
          String date = entry.key;
          List<dynamic> feedbacks = entry.value;

          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 3),
            padding: const pw.EdgeInsets.all(2),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Tarih: ${formatDate(date)}',
                    style: pw.TextStyle(
                        font: boldTtf,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8)),
                pw.SizedBox(height: 2),
                pw.Wrap(
                  children: List.generate(feedbacks.length, (index) {
                    final feedback = feedbacks[index];
                    return pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text(feedback['gorus_metni'] ?? 'Görüş metni yok',
                            style: pw.TextStyle(font: ttf, fontSize: 6)),
                        if (index < feedbacks.length - 1)
                          pw.Text(' , ',
                              style: pw.TextStyle(font: boldTtf, fontSize: 6)),
                      ],
                    );
                  }),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // Ödev takibi bölümünü oluştur
  pw.Widget _buildHomeworkSection(
      List<Map<String, dynamic>> homeworkTrackings) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Ödev Takibi:',
            style: pw.TextStyle(font: boldTtf, fontSize: 12)),
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 6),
        if (homeworkTrackings.isEmpty)
          pw.Text('Ödev kaydı bulunmamaktadır.',
              style: pw.TextStyle(
                  font: ttf, fontSize: 10, color: PdfColors.grey700)),
        pw.Wrap(
          spacing: 10,
          runSpacing: 6,
          children: homeworkTrackings.map((homework) {
            String status = homework['durum'] ?? 'Değerlendirme yok';
            bool isCompleted = status.toLowerCase() == 'yapti';

            return pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  '[ ${isCompleted ? "+" : "-"} ]',
                  style: pw.TextStyle(
                    font: boldTtf,
                    fontSize: 10,
                  ),
                ),
                pw.SizedBox(width: 5),
                pw.Text(
                  '${homework['odev_adi'] ?? 'Adı Yok'} (${formatDate(homework['teslim_tarihi'])})',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 8,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  // Dua/Sure takibi bölümünü oluştur
  pw.Widget _buildPrayerTrackingSection(
      List<Map<String, dynamic>> prayerTrackings) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Dua/Sure Takibi:',
            style: pw.TextStyle(font: boldTtf, fontSize: 12)),
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 5),
        if (prayerTrackings.isEmpty)
          pw.Text('Dua/Sure kaydı bulunmamaktadır.',
              style: pw.TextStyle(
                  font: ttf, fontSize: 10, color: PdfColors.grey700)),
        pw.Wrap(
          spacing: 12,
          runSpacing: 8,
          children: prayerTrackings.map((tracking) {
            bool isCompleted = tracking['durum'] == 'Okudu';
            return pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  '[ ${isCompleted ? "+" : "-"} ]',
                  style: pw.TextStyle(
                    font: boldTtf,
                    fontSize: 10,
                  ),
                ),
                pw.SizedBox(width: 5),
                pw.Text(
                  tracking['dua_sure_adi'] ?? '',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 8,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  // Defter/Kitap takibi bölümünü oluştur
  pw.Widget _buildNotebookBookSection(
      List<Map<String, dynamic>> notebookBookHistory) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Getirmediği Defter ve Kitaplar:',
            style: pw.TextStyle(font: boldTtf, fontSize: 12)),
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 5),

        if (notebookBookHistory.isEmpty)
          pw.Text('Getirmediği defter/kitap kaydı bulunmamaktadır.',
              style: pw.TextStyle(
                  font: ttf, fontSize: 10, color: PdfColors.grey700)),

        // Özet bilgiyi ekle
        _buildNotebookBookSummary(notebookBookHistory),

        pw.SizedBox(height: 5),

        // Derslere göre grupla
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: groupByCourse(notebookBookHistory).entries.map((entry) {
            String dersAdi = entry.key;
            List<Map<String, dynamic>> dersKayitlari = entry.value;

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('D: Defter, K: Kitap',
                    style: pw.TextStyle(
                        font: boldTtf, fontSize: 8, color: PdfColors.red)),
                pw.SizedBox(height: 5),
                // Ders adı (Bold)
                pw.Text(
                  dersAdi,
                  style: pw.TextStyle(
                    font: boldTtf,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 3),

                // Getirmediği kayıtlar
                pw.Wrap(
                  spacing: 10,
                  runSpacing: 5,
                  children: dersKayitlari.map((kayit) {
                    bool missingNotebook =
                        kayit['defter_durum']?.toLowerCase() == 'getirmedi';
                    bool missingBook =
                        kayit['kitap_durum']?.toLowerCase() == 'getirmedi';
                    String durum = missingNotebook && missingBook
                        ? "D,K"
                        : (missingNotebook ? "D" : "K");

                    return pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          // [ - ] kısmı **Bold**
                          pw.TextSpan(
                            text: '[ - ] ',
                            style: pw.TextStyle(
                              font: boldTtf,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          // Tarih sabit ve normal fontta
                          pw.TextSpan(
                            text: '${formatDate(kayit['tarih'])} ',
                            style: pw.TextStyle(
                              font: ttf,
                              fontSize: 8,
                            ),
                          ),
                          // Defter/Kitap durumu
                          pw.TextSpan(
                            text: '($durum)',
                            style: pw.TextStyle(
                              font: boldTtf,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                pw.SizedBox(height: 8),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  // Yaramazlık takibi bölümünü oluştur
  pw.Widget _buildMisbehaviourSection(
      List<Map<String, dynamic>> misbehaviours) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Yaramazlık Takibi:',
            style: pw.TextStyle(font: boldTtf, fontSize: 12)),
        pw.Divider(thickness: 1.5),
        pw.SizedBox(height: 5),
        if (misbehaviours.isEmpty)
          pw.Text('Yaramazlık kaydı bulunmamaktadır.',
              style: pw.TextStyle(
                  font: ttf, fontSize: 10, color: PdfColors.grey700)),
        pw.Wrap(
          spacing: 10,
          runSpacing: 6,
          children: misbehaviours.map((misbehaviour) {
            String tarih = misbehaviour['tarih'] != null
                ? DateTime.parse(misbehaviour['tarih'])
                    .toLocal()
                    .toString()
                    .split(' ')[0]
                : 'Tarih Yok';

            return pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(
                  '[ ! ] ',
                  style: pw.TextStyle(
                    font: boldTtf,
                    fontSize: 10,
                    color: PdfColors.red,
                  ),
                ),
                pw.Text(
                  '${formatDate(tarih)}: ',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 8,
                  ),
                ),
                pw.Text(
                  misbehaviour['yaramazlık_adi'] ?? 'Belirtilmemiş',
                  style: pw.TextStyle(
                    font: boldTtf,
                    fontSize: 8,
                    color: PdfColors.red,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  // Notlar bölümünü oluştur
  pw.Widget _buildGradesSection(List<Map<String, dynamic>> grades) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Öğrenci Notları:',
            style: pw.TextStyle(font: boldTtf, fontSize: 12)),
        pw.Divider(thickness: 1.5),
        pw.SizedBox(height: 10),
        if (grades.isEmpty)
          pw.Text('Not kaydı bulunmamaktadır.',
              style: pw.TextStyle(
                  font: ttf, fontSize: 10, color: PdfColors.grey700)),
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(1),
            2: pw.FlexColumnWidth(1),
            3: pw.FlexColumnWidth(1),
            4: pw.FlexColumnWidth(1),
            5: pw.FlexColumnWidth(1),
            6: pw.FlexColumnWidth(1),
            7: pw.FlexColumnWidth(1),
            8: pw.FlexColumnWidth(1),
            9: pw.FlexColumnWidth(1),
            10: pw.FlexColumnWidth(1),
            11: pw.FlexColumnWidth(1),
            12: pw.FlexColumnWidth(1),
          },
          children: [
            // Tablo Başlıkları
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text('Ders',
                      style: pw.TextStyle(
                          font: boldTtf,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 6)),
                ),
                pw.Center(
                  child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text('Yazılı 1',
                          style: pw.TextStyle(
                              font: boldTtf,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 6))),
                ),
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text('Yazılı 2',
                        style: pw.TextStyle(
                            font: boldTtf,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 6)),
                  ),
                ),
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text('Yazılı 3',
                        style: pw.TextStyle(
                            font: boldTtf,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 6)),
                  ),
                ),
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text('Yazılı 4',
                        style: pw.TextStyle(
                            font: boldTtf,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 6)),
                  ),
                ),
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text('Etkinlik 1',
                        style: pw.TextStyle(
                            font: boldTtf,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 6)),
                  ),
                ),
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text('Etkinlik 2',
                        style: pw.TextStyle(
                            font: boldTtf,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 6)),
                  ),
                ),
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text('Etkinlik 3',
                        style: pw.TextStyle(
                            font: boldTtf,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 6)),
                  ),
                ),
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text('Proje 1',
                        style: pw.TextStyle(
                            font: boldTtf,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 6)),
                  ),
                ),
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Text('Proje 2',
                        style: pw.TextStyle(
                            font: boldTtf,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 6)),
                  ),
                ),
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 2, top: 1),
                    child: pw.Text('Dönem Puanı',
                        style: pw.TextStyle(
                            font: boldTtf,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 6)),
                  ),
                ),
              ],
            ),

            // Tablo İçeriği
            for (var grade in grades)
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(grade['ders_adi'] ?? '-',
                        style: pw.TextStyle(font: ttf, fontSize: 5)),
                  ),
                  pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(grade['sinav1']?.toString() ?? '0',
                          style: pw.TextStyle(font: ttf, fontSize: 5)),
                    ),
                  ),
                  pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(grade['sinav2']?.toString() ?? '0',
                          style: pw.TextStyle(font: ttf, fontSize: 5)),
                    ),
                  ),
                  pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(grade['sinav3']?.toString() ?? '0',
                          style: pw.TextStyle(font: ttf, fontSize: 5)),
                    ),
                  ),
                  pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(grade['sinav4']?.toString() ?? '0',
                          style: pw.TextStyle(font: ttf, fontSize: 5)),
                    ),
                  ),
                  pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(
                          grade['ders_etkinlikleri1']?.toString() ?? '0',
                          style: pw.TextStyle(font: ttf, fontSize: 5)),
                    ),
                  ),
                  pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(
                          grade['ders_etkinlikleri2']?.toString() ?? '0',
                          style: pw.TextStyle(font: ttf, fontSize: 5)),
                    ),
                  ),
                  pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(
                          grade['ders_etkinlikleri3']?.toString() ?? '0',
                          style: pw.TextStyle(font: ttf, fontSize: 5)),
                    ),
                  ),
                  pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(grade['proje1']?.toString() ?? '0',
                          style: pw.TextStyle(font: ttf, fontSize: 6)),
                    ),
                  ),
                  pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(grade['proje2']?.toString() ?? '0',
                          style: pw.TextStyle(font: ttf, fontSize: 6)),
                    ),
                  ),
                  pw.Center(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Text(grade['donem_puani']?.toString() ?? '0',
                          style: pw.TextStyle(font: ttf, fontSize: 6)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  // KDS bölümünü oluştur
  pw.Widget _buildKdsSection(List<Map<String, dynamic>> kdsScores,
      Map<String, dynamic> kdsParticipationData) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Kazanım Değerlendirme Sınavı (KDS)',
            style: pw.TextStyle(font: boldTtf, fontSize: 12)),
        pw.Divider(thickness: 1.5),
        pw.SizedBox(height: 5),

        if (kdsScores.isEmpty)
          pw.Text('KDS kaydı bulunmamaktadır.',
              style: pw.TextStyle(
                  font: ttf, fontSize: 10, color: PdfColors.grey700)),

        // KDS Tablosu
        _buildKdsTable(kdsScores),
        pw.SizedBox(height: 10),

        // KDS Katılım bilgileri
        _buildKdsParticipationTable(kdsParticipationData),
      ],
    );
  }

  // Deneme sınavları bölümünü oluştur
  pw.Widget _buildDenemeSection(List<Map<String, dynamic>> denemeScores,
      Map<String, dynamic> denemeParticipationData) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Deneme Sınavları:',
            style: pw.TextStyle(font: boldTtf, fontSize: 12)),
        pw.Divider(thickness: 1.5),
        pw.SizedBox(height: 5),

        if (denemeScores.isEmpty)
          pw.Text('Deneme sınavı kaydı bulunmamaktadır.',
              style: pw.TextStyle(
                  font: ttf, fontSize: 10, color: PdfColors.grey700)),

        // Deneme Tablosu
        _buildDenemeTable(denemeScores),
        pw.SizedBox(height: 10),

        // Deneme Katılım bilgileri
        _buildDenemeParticipationTable(denemeParticipationData),
      ],
    );
  }

  // Okul denemeleri bölümünü oluştur
  pw.Widget _buildOkulDenemeSection(List<Map<String, dynamic>> okulDenemeleri,
      Map<String, dynamic> okulDenemeParticipationData) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Okul Denemeleri:',
            style: pw.TextStyle(font: boldTtf, fontSize: 14)),
        pw.Divider(thickness: 2),
        pw.SizedBox(height: 10),

        if (okulDenemeleri.isEmpty)
          pw.Text('Okul denemesi kaydı bulunmamaktadır.',
              style: pw.TextStyle(
                  font: ttf, fontSize: 10, color: PdfColors.grey700)),

        // Okul Denemeleri Tablosu
        _buildOkulDenemeTable(okulDenemeleri),
        pw.SizedBox(height: 10),

        // Okul Denemeleri Katılım bilgileri
        _buildOkulDenemeParticipationTable(okulDenemeParticipationData),
      ],
    );
  }

  // Defter/Kitap özeti tablosu
  pw.Widget _buildNotebookBookSummary(List<Map<String, dynamic>> history) {
    int totalMissingNotebook = history
        .where((h) => h['defter_durum']?.toLowerCase() == 'getirmedi')
        .length;
    int totalMissingBook = history
        .where((h) => h['kitap_durum']?.toLowerCase() == 'getirmedi')
        .length;

    return pw.Column(
      children: [
        // Başlık
        pw.Text(
          ' Getirmediği Defter ve Kitaplar Özeti',
          style: pw.TextStyle(
            font: boldTtf,
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.red,
          ),
        ),
        pw.SizedBox(height: 5),

        // Özet Bilgileri Tablo Halinde Göster
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.red, width: 1),
          columnWidths: {
            0: pw.FlexColumnWidth(2),
            1: pw.FlexColumnWidth(2),
            2: pw.FlexColumnWidth(2),
          },
          children: [
            // Başlık Satırı
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey300),
              children: [
                _buildTableHeaderCell(" Defter Getirmediği"),
                _buildTableHeaderCell(" Kitap Getirmediği"),
                _buildTableHeaderCell(" Toplam Eksik"),
              ],
            ),
            // Veriler
            pw.TableRow(
              children: [
                _buildTableDataCell("$totalMissingNotebook kez"),
                _buildTableDataCell("$totalMissingBook kez"),
                _buildTableDataCell(
                    "${totalMissingNotebook + totalMissingBook} kez"),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Tablo başlık hücresi
  pw.Widget _buildTableHeaderCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          font: boldTtf,
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        ),
      ),
    );
  }

  // Tablo veri hücresi
  pw.Widget _buildTableDataCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: ttf, fontSize: 6),
      ),
    );
  }

  // KDS tablosu
  pw.Widget _buildKdsTable(List<Map<String, dynamic>> kdsScores) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(1),
        4: pw.FlexColumnWidth(1),
      },
      children: [
        // Tablo Başlıkları
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(4),
              child: pw.Text('KDS Adı',
                  style: pw.TextStyle(
                      font: boldTtf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8)),
            ),
            pw.Center(
              child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text('Doğru',
                      style: pw.TextStyle(
                          font: boldTtf,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 8))),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text('Yanlış',
                    style: pw.TextStyle(
                        font: boldTtf,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8)),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text('Boş',
                    style: pw.TextStyle(
                        font: boldTtf,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8)),
              ),
            ),
            pw.Center(
                child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Text('Puan',
                  style: pw.TextStyle(
                      font: boldTtf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8)),
            )),
          ],
        ),

        // Tablo İçeriği
        for (var kds in kdsScores)
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(kds['kds']?['kds_adi'] ?? '-',
                    style: pw.TextStyle(font: ttf, fontSize: 7)),
              ),
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(kds['dogru']?.toString() ?? '0',
                      style: pw.TextStyle(font: ttf, fontSize: 7)),
                ),
              ),
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(kds['yanlis']?.toString() ?? '0',
                      style: pw.TextStyle(font: ttf, fontSize: 7)),
                ),
              ),
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(kds['bos']?.toString() ?? '0',
                      style: pw.TextStyle(font: ttf, fontSize: 7)),
                ),
              ),
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(kds['puan']?.toString() ?? '0',
                      style: pw.TextStyle(font: ttf, fontSize: 7)),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // Deneme tablosu
  pw.Widget _buildDenemeTable(List<Map<String, dynamic>> denemeScores) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(1),
        4: pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: pw.Text('Deneme Adı',
                  style: pw.TextStyle(
                      font: boldTtf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8)),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text('Doğru',
                    style: pw.TextStyle(
                        font: boldTtf,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8)),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text('Yanlış',
                    style: pw.TextStyle(
                        font: boldTtf,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8)),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text('Boş',
                    style: pw.TextStyle(
                        font: boldTtf,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8)),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text('Puan',
                    style: pw.TextStyle(
                        font: boldTtf,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8)),
              ),
            ),
          ],
        ),
        for (var deneme in denemeScores)
          pw.TableRow(
            children: [
              pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: pw.Text(
                    deneme['denemeSinavi']?['deneme_sinavi_adi'] ?? '',
                    style: pw.TextStyle(font: ttf, fontSize: 7)),
              ),
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(deneme['dogru']?.toString() ?? '0',
                      style: pw.TextStyle(font: ttf, fontSize: 7)),
                ),
              ),
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(deneme['yanlis']?.toString() ?? '0',
                      style: pw.TextStyle(font: ttf, fontSize: 7)),
                ),
              ),
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(deneme['bos']?.toString() ?? '0',
                      style: pw.TextStyle(font: ttf, fontSize: 7)),
                ),
              ),
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(deneme['puan']?.toString() ?? '0',
                      style: pw.TextStyle(font: ttf, fontSize: 7)),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // Okul deneme tablosu
  pw.Widget _buildOkulDenemeTable(List<Map<String, dynamic>> okulDenemeleri) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              child: pw.Text('Deneme Adı',
                  style: pw.TextStyle(
                      font: boldTtf,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10)),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text('Doğru',
                    style: pw.TextStyle(
                        font: boldTtf,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10)),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text('Yanlış',
                    style: pw.TextStyle(
                        font: boldTtf,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10)),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text('Net',
                    style: pw.TextStyle(
                        font: boldTtf,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10)),
              ),
            ),
          ],
        ),
        for (var deneme in okulDenemeleri)
          pw.TableRow(
            children: [
              pw.Padding(
                padding:
                    const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: pw.Text(deneme['denemeSinavi']?['sinav_adi'] ?? '',
                    style: pw.TextStyle(font: ttf, fontSize: 8)),
              ),
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(deneme['dogru_sayisi']?.toString() ?? '0',
                      style: pw.TextStyle(font: ttf, fontSize: 8)),
                ),
              ),
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(deneme['yanlis_sayisi']?.toString() ?? '0',
                      style: pw.TextStyle(font: ttf, fontSize: 8)),
                ),
              ),
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(deneme['net']?.toString() ?? '0',
                      style: pw.TextStyle(font: ttf, fontSize: 8)),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // KDS Katılım tablosu
  pw.Widget _buildKdsParticipationTable(
      Map<String, dynamic> kdsParticipationData) {
    try {
      if (kdsParticipationData.isEmpty ||
          !kdsParticipationData.containsKey('totalKDS')) {
        return pw.Text(
          "!! KDS Katılım verisi bulunamadı.",
          style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.red),
        );
      }

      // Katılmadığı KDS sayısını kontrol et
      int katilmayanSayi = int.tryParse(
              kdsParticipationData['katilmayanKDSsayisi']?.toString() ?? '0') ??
          0;

      return pw.Container(
        padding: const pw.EdgeInsets.all(5),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(' KDS Katılım Durumu',
                  style: pw.TextStyle(font: boldTtf, fontSize: 10)),
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                _buildPdfStatBox(
                    'Toplam KDS',
                    kdsParticipationData['totalKDS']?.toString() ?? '0',
                    PdfColors.blue50,
                    PdfColors.blue200,
                    PdfColors.blue900,
                    PdfColors.blue700),
                _buildPdfStatBox(
                    'Katıldığı',
                    kdsParticipationData['katilanKDSsayisi']?.toString() ?? '0',
                    PdfColors.green50,
                    PdfColors.green200,
                    PdfColors.green900,
                    PdfColors.green700),
                _buildPdfStatBox(
                    'Katılmadığı',
                    katilmayanSayi.toString(),
                    PdfColors.red50,
                    PdfColors.red200,
                    PdfColors.red900,
                    PdfColors.red700),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(
                katilmayanSayi == 0
                    ? ' ☑ Tüm KDS\'lere katılım sağlanmıştır.'
                    : '⚠️ Katılım sağlanmayan $katilmayanSayi adet KDS bulunmaktadır.',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 8,
                  color: katilmayanSayi == 0 ? PdfColors.green : PdfColors.red,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return pw.Text(
        "✖ KDS Katılım verisi işlenirken hata oluştu.",
        style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.red),
      );
    }
  }

  // Deneme Katılım tablosu
  pw.Widget _buildDenemeParticipationTable(
      Map<String, dynamic> denemeParticipationData) {
    try {
      if (denemeParticipationData.isEmpty ||
          !denemeParticipationData.containsKey('totalDeneme')) {
        return pw.Text(
          "!! Deneme Katılım verisi bulunamadı.",
          style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.red),
        );
      }
      return pw.Container(
        padding: const pw.EdgeInsets.all(5),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text('Deneme Katılım Durumu',
                  style: pw.TextStyle(font: boldTtf, fontSize: 10)),
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildPdfStatBox(
                    'Toplam Deneme',
                    denemeParticipationData['totalDeneme']?.toString() ?? '0',
                    PdfColors.blue50,
                    PdfColors.blue200,
                    PdfColors.blue900,
                    PdfColors.blue700),
                _buildPdfStatBox(
                    'Katıldığı',
                    denemeParticipationData['katilanDenemeSayisi']
                            ?.toString() ??
                        '0',
                    PdfColors.green50,
                    PdfColors.green200,
                    PdfColors.green900,
                    PdfColors.green700),
                _buildPdfStatBox(
                    'Katılmadığı',
                    denemeParticipationData['katilmayanDenemesayisi']
                            ?.toString() ??
                        '0',
                    PdfColors.red50,
                    PdfColors.red200,
                    PdfColors.red900,
                    PdfColors.red700),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(
                denemeParticipationData['katilmayanDenemeSayisi'] == 0
                    ? ' ☑ Tüm denemelere katılım sağlanmıştır.'
                    : '⚠️ Katılım sağlanmayan ${denemeParticipationData['katilmayanDenemesayisi']} adet deneme bulunmaktadır.',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 6,
                  color: denemeParticipationData['katilmayanDenemeSayisi'] == 0
                      ? PdfColors.green
                      : PdfColors.red,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return pw.Text(
        "!! Deneme Katılım verisi işlenirken hata oluştu.",
        style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.red),
      );
    }
  }

  // Okul Deneme Katılım tablosu
  pw.Widget _buildOkulDenemeParticipationTable(
      Map<String, dynamic> okulDenemeParticipationData) {
    try {
      if (okulDenemeParticipationData.isEmpty) {
        return pw.Text(
          "!! Okul Deneme Katılım verisi bulunamadı.",
          style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.red),
        );
      }

      // Sadece katılan öğrenci sayısı > 0 olan denemeleri al
      final denemeler =
          (okulDenemeParticipationData['denemeler'] as List<dynamic>)
              .where((deneme) => deneme['katilan_ogrenci'] > 0)
              .toList();

      // Yeni istatistikleri hesapla
      final int toplamGecerliDeneme = denemeler.length;
      final int katildigiDeneme =
          denemeler.where((deneme) => deneme['ogrenci_katildi'] == true).length;
      final int katilmayanDeneme = toplamGecerliDeneme - katildigiDeneme;

      // Eğer geçerli deneme yoksa uyarı mesajı göster
      if (toplamGecerliDeneme == 0) {
        return pw.Text(
          "Bu sınıfa henüz atanmış okul denemesi bulunmamaktadır.",
          style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.orange),
        );
      }

      return pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Okul Deneme Katılım Durumu',
                style: pw.TextStyle(font: boldTtf, fontSize: 12)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildPdfStatBox(
                    'Yapılan Deneme',
                    toplamGecerliDeneme.toString(),
                    PdfColors.blue50,
                    PdfColors.blue200,
                    PdfColors.blue900,
                    PdfColors.blue700),
                _buildPdfStatBox(
                    'Katıldığı',
                    katildigiDeneme.toString(),
                    PdfColors.green50,
                    PdfColors.green200,
                    PdfColors.green900,
                    PdfColors.green700),
                _buildPdfStatBox(
                    'Katılmadığı',
                    katilmayanDeneme.toString(),
                    PdfColors.red50,
                    PdfColors.red200,
                    PdfColors.red900,
                    PdfColors.red700),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    katilmayanDeneme == 0
                        ? '☑ Tüm okul denemelerine katılım sağlanmıştır.'
                        : '⚠️ Katılım sağlanmayan $katilmayanDeneme adet okul deneme bulunmaktadır.',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 8,
                      color: katilmayanDeneme == 0
                          ? PdfColors.green
                          : PdfColors.red,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                  if (toplamGecerliDeneme !=
                      (okulDenemeParticipationData['denemeler'] as List).length)
                    pw.Text(
                      'Not: Sınıfa atanmamış ${(okulDenemeParticipationData['denemeler'] as List).length - toplamGecerliDeneme} adet deneme değerlendirmeye alınmamıştır.',
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 6,
                        color: PdfColors.grey700,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return pw.Text(
        "!! Okul Deneme Katılım verisi işlenirken hata oluştu: $e",
        style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.red),
      );
    }
  }

  // İstatistik kutusu
  pw.Widget _buildPdfStatBox(String label, String value, PdfColor bgColor,
      PdfColor borderColor, PdfColor valueColor, PdfColor labelColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      decoration: pw.BoxDecoration(
        color: bgColor,
        border: pw.Border.all(color: borderColor),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              font: ttf,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: valueColor,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            label,
            style: pw.TextStyle(
              font: ttf,
              fontSize: 8,
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }

  // Derslere göre grouplandırma
  Map<String, List<Map<String, dynamic>>> groupByCourse(
      List<Map<String, dynamic>> history) {
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var item in history) {
      String dersAdi = item['ders_adi'] ?? 'Bilinmeyen Ders';
      bool missingNotebook = item['defter_durum']?.toLowerCase() == 'getirmedi';
      bool missingBook = item['kitap_durum']?.toLowerCase() == 'getirmedi';

      if (missingNotebook || missingBook) {
        if (!grouped.containsKey(dersAdi)) {
          grouped[dersAdi] = [];
        }
        grouped[dersAdi]!.add(item);
      }
    }

    return grouped;
  }

  // Tarih formatla
  String formatDate(String? dateStr) {
    if (dateStr == null) return 'Tarih belirtilmemiş';
    try {
      final date = DateTime.parse(dateStr);
      // Türkçe ay isimleri
      final aylar = [
        'Ocak',
        'Şubat',
        'Mart',
        'Nisan',
        'Mayıs',
        'Haziran',
        'Temmuz',
        'Ağustos',
        'Eylül',
        'Ekim',
        'Kasım',
        'Aralık'
      ];
      // Ayları 0'dan başladığı için month-1 kullanıyoruz
      return '${date.day} ${aylar[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr; // Eğer tarih parse edilemezse orijinal string'i döndür
    }
  }
}
