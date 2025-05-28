import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/api.dart/ogrenciDenemeleriApi.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'dart:typed_data';
import 'api.dart/classApi.dart' as classApi;
import 'api.dart/studentControlApi.dart' as studentControlApi;
import 'api.dart/teacherFeedbackApi.dart' as teacherFeedbackApi;
import 'api.dart/student_misbehaviour_api.dart' as misbehaviorControlApi;
import 'api.dart/prayerSurahTrackingControlApi.dart'
    as prayerSurahTrackingControlApi;
import 'api.dart/homeworkTrackingControlApi.dart' as homeworkTrackingControlApi;
import 'api.dart/studentHomeworkApi.dart' as studentHomeworkApi;
import 'api.dart/homeworkControlApi.dart' as homeworkControlApi;
import 'api.dart/prayerSurahApi.dart' as prayerSurahApi;
import 'package:printing/printing.dart'; // Printing için eklenen paket
import 'package:http/http.dart' as http; // HTTP paketini ekleyin
import 'api.dart/defterKitapControlApi.dart' as defterKitapApi;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'api.dart/grades_api.dart' as notApi;
import 'api.dart/courseApi.dart' as courseApiService;
import 'api.dart/okulDenemeleriApi.dart' as okulDenemeleriApi;
import 'api.dart/ogrenciOkulDenemeleriApi.dart' as ogrenciOkulDenemeleriApi;
import 'api.dart/studentKdsApi.dart' as studentKDSApi;
import 'api.dart/ogrenciDenemeleriApi.dart' as ogrenciDenemeleriApi;
import 'api.dart/ogrenciOkulDenemeleriApi.dart' as ogrenciOkulDenemeleriApi;
import 'api.dart/okulDenemeleriApi.dart' as okulDenemeleriApi;

class KarneEkrani extends StatefulWidget {
  final int studentId; // Gelen öğrenci ID'si
  final String selectedClass; // Seçilen sınıf

  const KarneEkrani(
      {super.key, required this.studentId, required this.selectedClass});

  @override
  _KarneEkraniState createState() => _KarneEkraniState();
}

class _KarneEkraniState extends State<KarneEkrani> {
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
  final homeworkControlApi.ApiService homeworkControl =
      homeworkControlApi.ApiService(baseUrl: 'http://localhost:3000');
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

  int? selectedClassId;

  List<dynamic> classes = [];
  List<Student> students = [];
  Student? selectedStudent;
  Uint8List? studentImage;
  List<dynamic> misbehaviours = [];
  List<dynamic> prayerSurahTrackings = [];
  List<dynamic> studentHomeworks = [];
  List<dynamic> teacherFeedbacks = [];
  Map<int, String> feedbackOptionNames = {}; // Feedback metinleri için
  String? selectedClassName;
  Map<int, String> savedStatuses = {}; // Ödevin değerlendirme durumu
  Map<int, bool> isTrackingAdded = {}; // Ödev takibi eklenmiş mi
  List<Map<String, dynamic>> notebookBookHistory =
      []; // Defter ve kitap geçmişi için
  String? studentName;
  String? studentNumber;
  int selectedDonem = 1; // 📌 Varsayılan olarak 1. Dönem seçili
  List<Map<String, dynamic>> studentGrades = []; // Öğrenci notları için
  Map<String, List<dynamic>> groupedFeedbacks = {};
  final ScrollController _horizontalScrollController = ScrollController();

  List<dynamic> kdsScores = [];
  List<dynamic> denemeler = [];
  List<dynamic> okulDenemeler = [];

  Map<String, dynamic> kdsParticipationData = {};
  Map<String, dynamic> denemeParticipationData =
      {}; // Instead of StudentExamRepository?
  Map<String, dynamic> okulDenemeParticipationData = {};

  @override
  void initState() {
    super.initState();
    _horizontalScrollController.dispose();
    selectedClassName = widget.selectedClass;
    _initializeClassId();
  }

  Future<void> _loadStudentDetails(
      int studentId, int selectedDonem, int selectedClassId) async {
    await getStudentDetails(studentId); // Öğrenci detayları ve resmi yüklenecek
    await _loadAssignedMisbehaviours(); // Yaramazlıklar yüklenecek
    await _loadPreviousTrackings(studentId); // Dua/sure takip yüklenecek
    await _loadGroupedFeedbacks(studentId); // Öğretmen görüşleri yüklenecek
    await _loadAssignments(studentId); // Ödevler yüklenecek
    await _loadNotebookAndBookHistory(
        studentId); // Defter ve kitap geçmişi yüklenecek
    await _loadGrades(
        studentId, selectedDonem); // Öğrencinin notları yüklenecek
    await loadFeedback(studentId); // Öğretmen görüşleri y
    await _loadKDSScores(studentId); // KDS puanları yüklenecek
    await _loadDenemeScores(studentId); // Deneme puanları yüklenecek
    await _loadOkulDenemeleri(studentId); // Okul denemeleri yüklenecek
    await _loadStudentImage(studentId); // Öğrenci resmi yüklenecek
    await _loadKDSParticipation(studentId); // KDS katılım verileri yüklenecek
    await _loadDenemeParticipation(
        studentId); // Deneme katılım verileri yüklenecek
    await _loadOkulDenemeleriParticipation(
        studentId, selectedClassId); // Okul deneme katılım verileri yüklenecek
  }

  Future<void> _initializeClassId() async {
    try {
      // API direkt olarak int? döndürüyor
      final classId = await classService.getClassIdByName(widget.selectedClass);

      if (classId != null) {
        setState(() {
          selectedClassId = classId;
          selectedClassName = widget.selectedClass;
        });

        // ID başarıyla alındıktan sonra diğer verileri yükle
        await _loadStudentDetails(widget.studentId, selectedDonem, classId);
      } else {
        print('Geçersiz sınıf ID: null değer döndü');
      }
    } catch (error) {
      print('Sınıf ID alınırken hata: $error');
    }
  }

  void _generatePdfPreview() async {
    final pdfBytes = await _generatePdf(); // PDF oluşturuluyor

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text("PDF Önizleme")),
          body: PdfPreview(
            build: (format) async => pdfBytes,
            useActions: true, // Üst çubukta butonları göster
            canDebug: false, // Debug paneli kapalı
            canChangePageFormat:
                false, // Kullanıcı sayfa formatını değiştiremez
            pdfFileName: "karne_${DateTime.now().millisecondsSinceEpoch}.pdf",
            actions: [
              IconButton(
                icon: Icon(Icons.download), // Kaydetme butonu
                onPressed: () async {
                  final String? filePath = await FilePicker.platform.saveFile(
                    dialogTitle: 'PDF Olarak Kaydet',
                    fileName:
                        "karne_${DateTime.now().millisecondsSinceEpoch}.pdf",
                  );

                  if (filePath != null) {
                    final file = File(filePath);
                    await file.writeAsBytes(pdfBytes);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('PDF başarıyla kaydedildi: $filePath')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadOkulDenemeleri(int studentId) async {
    try {
      final okulDenemesiData = await ogrenciOkulDenemeleriApiService
          .getOgrenciOkulDenemeleriByStudentId(studentId);
      setState(() {
        okulDenemeler = okulDenemesiData;
      });
    } catch (error) {
      print('Okul Denemeleri yüklenirken hata oluştu: $error');
    }
  }

  Future<void> _loadOkulDenemeleriParticipation(
      int studentId, int selectedClassId) async {
    try {
      print('📍 Okul deneme verisi yükleniyor...');
      print('🔑 StudentId: $studentId, ClassId: $selectedClassId');

      final okulDenemeleriData = await ogrenciOkulDenemeleriApiService
          .getClassOkulDenemeAverages(selectedClassId, studentId);

      print('📦 Ham API yanıtı: $okulDenemeleriData');

      if (okulDenemeleriData != null) {
        print(
            '🔍 API yanıtındaki anahtarlar: ${okulDenemeleriData.keys.toList()}');

        if (okulDenemeleriData.containsKey('statistics')) {
          final statistics = okulDenemeleriData['statistics'];
          print('📊 İstatistik verileri:');
          print('   • Toplam deneme: ${statistics['toplam_deneme']}');
          print('   • Katıldığı deneme: ${statistics['katildigi_deneme']}');
          print('   • Katılım yüzdesi: ${statistics['katilim_yuzdesi']}%');
          print('   • Ortalama net: ${statistics['ortalama_net']}');
        } else {
          print('⚠️ Statistics anahtarı bulunamadı!');
        }

        if (okulDenemeleriData.containsKey('denemeler')) {
          print('📝 Deneme sayısı: ${okulDenemeleriData['denemeler'].length}');
        } else {
          print('⚠️ Denemeler anahtarı bulunamadı!');
        }

        setState(() {
          okulDenemeParticipationData = okulDenemeleriData;
        });
        print('💾 Veri başarıyla state\'e kaydedildi');
      } else {
        print('⛔ API\'den null veri geldi');
      }
    } catch (error, stackTrace) {
      print('❌ Okul deneme verileri yüklenirken hata:');
      print('   • Hata mesajı: $error');
      print('   • Stack trace: $stackTrace');
      print('   • Student ID: $studentId');
      print('   • Class ID: $selectedClassId');
    }
  }

  Future<void> _loadDenemeParticipation(int studentId) async {
    try {
      final denemeData = await ogrenciDenemeleriApiService
          .getStudentExamParticipation(studentId);
      setState(() {
        // Don't cast to StudentExamRepository - this is the problem
        // Instead, store the participation data as a Map<String, dynamic>
        denemeParticipationData = {
          'totalDeneme': denemeData.totalDeneme,
          'katilanDenemeSayisi': denemeData.katilanDenemeSayisi,
          'katilmayanDenemesayisi': denemeData.katilmayanDenemeSayisi,
          'ogrenciAdi': denemeData.ogrenciAdi,
          'ogrenciId': denemeData.ogrenciId,
          'sinifId': denemeData.sinifId,
          'sinifAdi': denemeData.sinifAdi,
          'egitimYiliId': denemeData.egitimYiliId,
          'katilanDenemeler': denemeData.katilanDenemeler
              .map((e) => {
                    'deneme_sinavi_id': e.denemeSinaviId,
                    'deneme_sinavi_adi': e.denemeSinaviAdi,
                    'dogru': e.dogru,
                    'yanlis': e.yanlis,
                    'bos': e.bos,
                    'puan': e.puan,
                  })
              .toList(),
          'katilmayanDenemeler': denemeData.katilmayanDenemeler
              .map((e) => {
                    'deneme_sinavi_id': e.denemeSinaviId,
                    'deneme_sinavi_adi': e.denemeSinaviAdi,
                  })
              .toList(),
        };
      });
    } catch (error) {
      print('Deneme katılım verileri yüklenirken hata oluştu: $error');
    }
  }

  //KDS Katilim verilerini getir
  Future<void> _loadKDSParticipation(int studentId) async {
    try {
      print("📍 KDS verisi yükleniyor... StudentId: $studentId");

      final kdsData = await studentKDSApiService
          .getStudentKDSParticipationDetails(studentId);
      print("📦 Ham KDS verisi: $kdsData");

      if (kdsData != null) {
        print("🔑 Mevcut anahtarlar: ${kdsData.keys.toList()}");

        setState(() {
          kdsParticipationData = kdsData;
        });
        print("💾 Kaydedilen veri: $kdsParticipationData");
      } else {
        print("⚠ KDS verisi null geldi");
      }
    } catch (error, stackTrace) {
      print('❌ KDS veri yükleme hatası: $error');
      print('📚 Hata detayı: $stackTrace');
    }
  }

  Future<void> _loadClasses() async {
    try {
      final classList = await classService.getClassesForDropdown();
      setState(() {
        classes = classList.cast<Map<String, dynamic>>();
      });
    } catch (error) {
      print('Sınıflar yüklenemedi: $error');
    }
  }

  Future<void> getStudentDetails(int studentId) async {
    try {
      final data = await studentService.getStudentById(studentId);
      setState(() {
        selectedStudent = data;
        _loadStudentImage(studentId); // Fotoğraf yükleniyor
      });
    } catch (error) {
      print('Öğrenci detayı yüklenemedi: $error');
    }
  }

  // Öğrenci fotoğrafını yüklemek için
  Future<void> _loadStudentImage(int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/student/$studentId/image'),
        headers: {
          'Accept': 'image/*',
        },
      );

      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        setState(() {
          studentImage = response.bodyBytes;
        });
      } else {
        print('Resim yüklenemedi: ${response.statusCode}');
        setState(() {
          studentImage = null;
        });
      }
    } catch (error) {
      print('Resim yüklenirken hata oluştu: $error');
      setState(() {
        studentImage = null;
      });
    }
  }

  // Öğrenci fotoğrafını API'den GET isteğiyle almak için
  Future<Uint8List> getStudentImage(int id) async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/student/$id/image'));
    if (response.statusCode == 200) {
      return response.bodyBytes; // Resmi binary formatında döndür
    } else {
      throw Exception('Resim yüklenemedi');
    }
  }

  Future<void> loadFeedback(int studentId) async {
    try {
      final feedbackData =
          await feedbackService.getTeacherFeedbackByStudentId(studentId);
      setState(() {
        teacherFeedbacks = feedbackData.map((entry) {
          return {
            'gorus_id': entry['gorus_id'],
            'gorus_metni': entry['gorus_metni'],
            'createdAt': entry['createdAt'],
          };
        }).toList();

        for (var entry in teacherFeedbacks) {
          int gorusId = entry['gorus_id'] ?? 0;
          loadFeedbackOptionName(gorusId);
        }
      });
    } catch (error) {
      print('Öğretmen görüşleri yüklenemedi: $error');
    }
  }

  Future<void> _loadGroupedFeedbacks(int studentId) async {
    try {
      final feedbacksData =
          await feedbackService.getTeacherFeedbackByStudentIdandDate(studentId);

      setState(() {
        groupedFeedbacks = feedbacksData;
      });

      print(
          'Grouped feedbacks loaded successfully: $groupedFeedbacks'); // Debug için
    } catch (error) {
      print('Grouped feedbacks loading error: $error');
      // Hata durumunda boş map ile güncelle
      setState(() {
        groupedFeedbacks = {};
      });
    }
  }

  Future<void> _loadKDSScores(int studentId) async {
    try {
      final kdsData = await studentKDSApiService.getStudentKDSScores(studentId);
      setState(() {
        kdsScores = kdsData;
      });
    } catch (error) {
      print('KDS puanları yüklenemedi: $error');
    }
  }

  Future<void> _loadDenemeScores(int studentId) async {
    try {
      final denemeData = await ogrenciDenemeleriApiService
          .getStudentExamResultsByStudentId(studentId);
      setState(() {
        denemeler = denemeData;
      });
    } catch (error) {
      print('Deneme puanları yüklenemedi: $error');
    }
  }

  Future<void> loadFeedbackOptionName(int optionId) async {
    try {
      final optionName =
          await feedbackService.getTeacherFeedbackByOptionId(optionId);
      setState(() {
        feedbackOptionNames[optionId] = optionName;
      });
    } catch (error) {
      print('Feedback Option Name yüklenemedi: $error');
    }
  }

  Future<void> _loadAssignedMisbehaviours() async {
    if (selectedStudent == null) return;

    try {
      final assignedData = await misbehaviorService
          .getMisbehavioursByStudentId(selectedStudent!.id);
      List<Map<String, dynamic>> loadedMisbehaviours = [];
      for (var misbehaviour in assignedData) {
        loadedMisbehaviours.add({
          'yaramazlık_adi': misbehaviour.misbehaviour?.yaramazlikAdi ??
              'Yaramazlık adı bulunamadı',
          'tarih': misbehaviour.tarih ?? 'Tarih bulunamadı',
        });
      }
      setState(() {
        misbehaviours = loadedMisbehaviours;
      });
    } catch (error) {
      print('Yaramazlıklar yüklenemedi: $error');
    }
  }

  Future<void> _loadPreviousTrackings(int studentId) async {
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
      setState(() {
        prayerSurahTrackings = loadedTrackings;
      });
    } catch (error) {
      print('Dua/sure takip bilgileri yüklenemedi: $error');
    }
  }

  Future<void> _loadAssignments(int studentId) async {
    try {
      final assignmentList =
          await homeworkServis.getStudentHomeworksByStudentId(studentId);
      List<Map<String, dynamic>> loadedAssignments = [];

      for (var studentHomework in assignmentList) {
        var homework = studentHomework['homework'];
        if (homework != null) {
          loadedAssignments.add({
            'odev_adi': homework['odev_adi'] ?? 'Adı Yok',
            'teslim_tarihi': homework['teslim_tarihi'] ?? 'Teslim Tarihi Yok',
            'id': studentHomework['id'],
            'durum': studentHomework['durum'],
          });
          _loadSavedStatus(studentHomework['id']);
        }
      }
      setState(() {
        studentHomeworks = loadedAssignments;
      });
    } catch (error) {
      print('Ödevler yüklenemedi: $error');
    }
  }

  Future<void> _loadSavedStatus(int assignmentId) async {
    try {
      final savedTracking = await homeworkService
          .getHomeworkTrackingByStudentHomeworkId(assignmentId);
      if (savedTracking.isNotEmpty) {
        setState(() {
          savedStatuses[assignmentId] = savedTracking[0]['durum'];
          isTrackingAdded[assignmentId] = true;
        });
      } else {
        setState(() {
          savedStatuses[assignmentId] = 'Değerlendirme yok';
          isTrackingAdded[assignmentId] = false;
        });
      }
    } catch (error) {
      print('Ödev takibi kontrol edilemedi: $error');
    }
  }

  Future<void> _loadNotebookAndBookHistory(int studentId) async {
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

      setState(() {
        notebookBookHistory = loadedHistory;
      });
    } catch (error) {
      print('Defter ve kitap geçmişi yüklenemedi: $error');
    }
  }

  Future<void> _loadGrades(int studentId, int donem) async {
    try {
      final semesterGrades = await gradesApiService.getStudentSemesterGrades(
          studentId, donem); // Use the passed "donem"

      setState(() {
        final dersler = semesterGrades.dersler;

        studentGrades = dersler.map((grade) {
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

        // Update the student details
        studentName = semesterGrades.ogrenciAdi;
        studentNumber = semesterGrades.ogrenciNo;
      });
    } catch (error) {
      print('Notlar yüklenemedi: $error');
    }
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
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
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr; // Eğer tarih parse edilemezse orijinal string'i döndür
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Karne Önizleme')),
      body: Column(
        children: [
          // 📌 Kullanıcının dönem seçmesini sağlayan dropdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<int>(
              value: selectedDonem,
              items: const [
                DropdownMenuItem(value: 1, child: Text('1. Dönem')),
                DropdownMenuItem(value: 2, child: Text('2. Dönem')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedDonem = value;
                  });
                  _loadStudentDetails(
                      widget.studentId, selectedDonem, selectedClassId!);
                }
              },
            ),
          ),

          // 📌 PDF Önizleme butonu
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () => _generatePdfPreview(),
                child: Text('PDF Önizleme'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();

    // Türkçe karakterleri destekleyen bir font yükle
    final fontData = await rootBundle.load("assets/DejaVuSans.ttf");
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    final boldFontData = await rootBundle.load("assets/dejavu-sans-bold.ttf");
    final boldTtf = pw.Font.ttf(boldFontData.buffer.asByteData());
    pw.MemoryImage? studentPdfImage;
    try {
      if (studentImage != null) {
        studentPdfImage = pw.MemoryImage(studentImage!);
      }
    } catch (e) {
      print('Öğrenci fotoğrafı PDF için hazırlanamadı: $e');
    }
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Ogrenci Karnesi Adinda Baslik Bold Karakterli
              pw.Center(
                  child: pw.Text('Öğrenci Karnesi',
                      style: pw.TextStyle(font: boldTtf, fontSize: 16))),
              // Bold karakterli Duz Cizgi Ayirmak icin
              pw.Divider(thickness: 2),
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
                        pw.Text('Öğrenci: ${selectedStudent!.adSoyad}',
                            style: pw.TextStyle(font: ttf, fontSize: 12)),
                        pw.Text('Numara: ${selectedStudent!.ogrenciNo}',
                            style: pw.TextStyle(font: ttf, fontSize: 12)),
                        pw.Text('Sınıf: $selectedClassName',
                            style: pw.TextStyle(font: ttf, fontSize: 12)),
                        if (selectedStudent!.anneAdi != null &&
                            selectedStudent!.anneAdi.toString().isNotEmpty)
                          pw.Text('Anne Adı: ${selectedStudent!.anneAdi}',
                              style: pw.TextStyle(font: ttf, fontSize: 12)),
                        if (selectedStudent!.babaAdi != null &&
                            selectedStudent!.babaAdi.toString().isNotEmpty)
                          pw.Text('Baba Adı: ${selectedStudent!.babaAdi}',
                              style: pw.TextStyle(font: ttf, fontSize: 12)),
                        pw.SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              // Öğretmen Görüşleri
              pw.Text('Öğretmen Görüşleri:',
                  style: pw.TextStyle(font: boldTtf, fontSize: 12)),
              pw.Divider(thickness: 1),

              pw.SizedBox(height: 2),

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
                              pw.Text(
                                  feedback['gorus_metni'] ?? 'Görüş metni yok',
                                  style: pw.TextStyle(font: ttf, fontSize: 6)),
                              if (index < feedbacks.length - 1)
                                pw.Text(' , ',
                                    style: pw.TextStyle(
                                        font: boldTtf, fontSize: 6)),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                );
              }).toList(),
              pw.SizedBox(height: 10),

              // Ödev Takibi
              pw.Text('Ödev Takibi:',
                  style: pw.TextStyle(font: boldTtf, fontSize: 12)),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 6),

              pw.Wrap(
                spacing: 10,
                runSpacing: 6,
                children: studentHomeworks
                    .map((homework) =>
                        _buildHomeworkCard(homework, ttf, boldTtf))
                    .toList(),
              ),

              pw.SizedBox(height: 10),

              // Dua/Sure Takibi
              pw.Text('Dua/Sure Takibi:',
                  style: pw.TextStyle(font: boldTtf, fontSize: 12)),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 5),

              pw.Wrap(
                spacing: 12,
                runSpacing: 8,
                children: prayerSurahTrackings.map((tracking) {
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

              pw.SizedBox(height: 10),

              pw.Text('Getirmediği Defter ve Kitaplar:',
                  style: pw.TextStyle(font: boldTtf, fontSize: 12)),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 5),

              // Özet bilgiyi ekle
              _buildSummary(notebookBookHistory, ttf, boldTtf),

              pw.SizedBox(height: 5),

              // Derslere göre grupla
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children:
                    groupByCourse(notebookBookHistory).entries.map((entry) {
                  String dersAdi = entry.key;
                  List<Map<String, dynamic>> dersKayitlari = entry.value;

                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('D: Defter, K: Kitap',
                          style: pw.TextStyle(
                              font: boldTtf,
                              fontSize: 8,
                              color: PdfColors.red)),
                      pw.SizedBox(height: 5),
                      // 📌 Ders adı (Bold)
                      pw.Text(
                        dersAdi,
                        style: pw.TextStyle(
                          font: boldTtf,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 3),

                      // 📌 Getirmediği kayıtlar
                      pw.Wrap(
                        spacing: 10,
                        runSpacing: 5,
                        children: dersKayitlari.map((kayit) {
                          bool missingNotebook =
                              kayit['defter_durum']?.toLowerCase() ==
                                  'getirmedi';
                          bool missingBook =
                              kayit['kitap_durum']?.toLowerCase() ==
                                  'getirmedi';
                          String durum = missingNotebook && missingBook
                              ? "D,K"
                              : (missingNotebook ? "D" : "K");

                          pw.SizedBox(height: 5);

                          return pw.RichText(
                            text: pw.TextSpan(
                              children: [
                                // 📌 [ - ] kısmı **Bold**
                                pw.TextSpan(
                                  text: '[ - ] ',
                                  style: pw.TextStyle(
                                    font: boldTtf,
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                // 📌 Tarih sabit ve normal fontta
                                pw.TextSpan(
                                  text: '${formatDate(kayit['tarih'])} ',
                                  style: pw.TextStyle(
                                    font: ttf,
                                    fontSize: 8,
                                  ),
                                ),
                                // 📌 Defter/Kitap durumu
                                pw.TextSpan(
                                  text: '($durum)',
                                  style: pw.TextStyle(
                                    font: boldTtf,
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors
                                        .red, // Daha dikkat çekici olsun
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
              pw.SizedBox(height: 10),

              // Yaramazlık Takibi (Yıl-Ay-Gün formatında tarih ile birlikte)
              pw.Text('Yaramazlık Takibi:',
                  style: pw.TextStyle(font: boldTtf, fontSize: 12)),
              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 5),

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

              pw.SizedBox(height: 15),

              // Öğrenci Notları (tüm sınavlar, etkinlikler, projeler ve puanlar)
              pw.Text('Öğrenci Notları:',
                  style: pw.TextStyle(font: boldTtf, fontSize: 12)),
              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 10),

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

                  // **Tablo İçeriği**
                  for (var grade in studentGrades)
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
                            child: pw.Text(
                                grade['donem_puani']?.toString() ?? '0',
                                style: pw.TextStyle(font: ttf, fontSize: 6)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              pw.SizedBox(height: 15),

              pw.Text('Kazanım Değerlendirme Sınavı (KDS)',
                  style: pw.TextStyle(font: boldTtf, fontSize: 12)),
              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 5),

              // KDS Tablosu
              _buildKdsTable(
                  kdsScores.cast<Map<String, dynamic>>(), ttf, boldTtf),

              pw.SizedBox(height: 10),

              _buildKDSParticipationTable(kdsParticipationData, ttf, boldTtf),

              pw.SizedBox(height: 20),

              // Deneme Tablosunu ekleyelim
              pw.Text('Deneme Sınavları:',
                  style: pw.TextStyle(font: boldTtf, fontSize: 12)),
              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 5),

              _buildDenemeTable(
                  denemeler.cast<Map<String, dynamic>>(), ttf, boldTtf),
              pw.SizedBox(height: 10),

              _buildDenemeParticipationTable(
                  denemeParticipationData, ttf, boldTtf),

              pw.SizedBox(height: 20),

              //Okul Denemeleri
              pw.Text('Okul Denemeleri:',
                  style: pw.TextStyle(font: boldTtf, fontSize: 14)),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10),

              _buildOkulDenemeTable(
                  okulDenemeler.cast<Map<String, dynamic>>(), ttf, boldTtf),
              pw.SizedBox(height: 20),
              _buildOkulDenemeleriParticipationTable(
                  okulDenemeParticipationData, ttf, boldTtf),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildKDSParticipationTable(
      Map<String, dynamic> kdsparticipationData, pw.Font ttf, pw.Font boldTtf) {
    try {
      if (kdsparticipationData.isEmpty ||
          !kdsparticipationData.containsKey('totalKDS')) {
        return pw.Text(
          "!! KDS Katılım verisi bulunamadı.",
          style: pw.TextStyle(font: ttf, fontSize: 12, color: PdfColors.red),
        );
      }

      // Katılmadığı KDS sayısını kontrol et
      int katilmayanSayi = int.tryParse(
              kdsparticipationData['katilmayanKDSsayisi']?.toString() ?? '0') ??
          0;

      return pw.Container(
        padding: const pw.EdgeInsets.all(5), // Reduced padding
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey),
          borderRadius: pw.BorderRadius.circular(6), // Reduced border radius
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(' KDS Katılım Durumu',
                  style: pw.TextStyle(font: boldTtf, fontSize: 10)),
            ),
            pw.SizedBox(height: 5), // Reduced spacing
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment
                  .spaceEvenly, // Changed to spaceEvenly for less spacing
              children: [
                _buildPdfStatBox(
                    'Toplam KDS',
                    kdsparticipationData['totalKDS']?.toString() ?? '0',
                    ttf,
                    PdfColors.blue50,
                    PdfColors.blue200,
                    PdfColors.blue900,
                    PdfColors.blue700),
                _buildPdfStatBox(
                    'Katıldığı',
                    kdsparticipationData['katilanKDSsayisi']?.toString() ?? '0',
                    ttf,
                    PdfColors.green50,
                    PdfColors.green200,
                    PdfColors.green900,
                    PdfColors.green700),
                _buildPdfStatBox(
                    'Katılmadığı',
                    katilmayanSayi.toString(),
                    ttf,
                    PdfColors.red50,
                    PdfColors.red200,
                    PdfColors.red900,
                    PdfColors.red700),
              ],
            ),
            pw.SizedBox(height: 4), // Reduced spacing
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

  pw.Widget _buildDenemeParticipationTable(
    Map<String, dynamic> denemeParticipationData,
    pw.Font ttf,
    pw.Font boldTtf,
  ) {
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
                    ttf,
                    PdfColors.blue50,
                    PdfColors.blue200,
                    PdfColors.blue900,
                    PdfColors.blue700),
                _buildPdfStatBox(
                    'Katıldığı',
                    denemeParticipationData['katilanDenemeSayisi']
                            ?.toString() ??
                        '0',
                    ttf,
                    PdfColors.green50,
                    PdfColors.green200,
                    PdfColors.green900,
                    PdfColors.green700),
                _buildPdfStatBox(
                    'Katılmadığı',
                    denemeParticipationData['katilmayanDenemesayisi']
                            ?.toString() ??
                        '0',
                    ttf,
                    PdfColors.red50,
                    PdfColors.red200,
                    PdfColors.red900,
                    PdfColors.red700),
              ],
            ),
            pw.SizedBox(height: 4),
            // Katılım durumu notu
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

  pw.Widget _buildOkulDenemeleriParticipationTable(
    Map<String, dynamic> okulDenemeParticipationData,
    pw.Font ttf,
    pw.Font boldTtf,
  ) {
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
                    ttf,
                    PdfColors.blue50,
                    PdfColors.blue200,
                    PdfColors.blue900,
                    PdfColors.blue700),
                _buildPdfStatBox(
                    'Katıldığı',
                    katildigiDeneme.toString(),
                    ttf,
                    PdfColors.green50,
                    PdfColors.green200,
                    PdfColors.green900,
                    PdfColors.green700),
                _buildPdfStatBox(
                    'Katılmadığı',
                    katilmayanDeneme.toString(),
                    ttf,
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

  pw.Widget _buildPdfStatBox(
      String label,
      String value,
      pw.Font ttf,
      PdfColor bgColor,
      PdfColor borderColor,
      PdfColor valueColor,
      PdfColor labelColor) {
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

  pw.Widget _buildOkulDenemeTable(
      List<Map<String, dynamic>> okulDenemeleri, pw.Font font, pw.Font bold) {
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
                      font: bold,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10)),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text('Doğru',
                    style: pw.TextStyle(
                        font: bold,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10)),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text('Yanlış',
                    style: pw.TextStyle(
                        font: bold,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10)),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text('Net',
                    style: pw.TextStyle(
                        font: bold,
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
                    style: pw.TextStyle(font: font, fontSize: 8)),
              ),
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(deneme['dogru_sayisi']?.toString() ?? '0',
                      style: pw.TextStyle(font: font, fontSize: 8)),
                ),
              ),
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(deneme['yanlis_sayisi']?.toString() ?? '0',
                      style: pw.TextStyle(font: font, fontSize: 8)),
                ),
              ),
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(deneme['net']?.toString() ?? '0',
                      style: pw.TextStyle(font: font, fontSize: 8)),
                ),
              ),
            ],
          ),
      ],
    );
  }

  pw.Widget _buildKdsTable(
      List<Map<String, dynamic>> kdsScores, pw.Font ttf, pw.Font boldTtf) {
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

        // **Tablo İçeriği**
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

  pw.Widget _buildDenemeTable(
      List<Map<String, dynamic>> denemeScores, pw.Font font, pw.Font bold) {
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
                      font: bold, fontWeight: pw.FontWeight.bold, fontSize: 8)),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text('Doğru',
                    style: pw.TextStyle(
                        font: bold,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8)),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text('Yanlış',
                    style: pw.TextStyle(
                        font: bold,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8)),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text('Boş',
                    style: pw.TextStyle(
                        font: bold,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8)),
              ),
            ),
            pw.Center(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Text('Puan',
                    style: pw.TextStyle(
                        font: bold,
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
                    style: pw.TextStyle(font: font, fontSize: 7)),
              ),
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(deneme['dogru']?.toString() ?? '0',
                      style: pw.TextStyle(font: font, fontSize: 7)),
                ),
              ),
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(deneme['yanlis']?.toString() ?? '0',
                      style: pw.TextStyle(font: font, fontSize: 7)),
                ),
              ),
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(deneme['bos']?.toString() ?? '0',
                      style: pw.TextStyle(font: font, fontSize: 7)),
                ),
              ),
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Text(deneme['puan']?.toString() ?? '0',
                      style: pw.TextStyle(font: font, fontSize: 7)),
                ),
              ),
            ],
          ),
      ],
    );
  }

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

  pw.Widget _buildSummary(
      List<Map<String, dynamic>> history, pw.Font ttf, pw.Font boldTtf) {
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
                _buildTableHeaderCell(" Defter Getirmediği", ttf, boldTtf),
                _buildTableHeaderCell(" Kitap Getirmediği", ttf, boldTtf),
                _buildTableHeaderCell(" Toplam Eksik", ttf, boldTtf),
              ],
            ),
            // Veriler
            pw.TableRow(
              children: [
                _buildTableDataCell("$totalMissingNotebook kez", boldTtf),
                _buildTableDataCell("$totalMissingBook kez", boldTtf),
                _buildTableDataCell(
                    "${totalMissingNotebook + totalMissingBook} kez", boldTtf),
              ],
            ),
          ],
        ),
      ],
    );
  }

// Tablo Başlık Hücreleri
  pw.Widget _buildTableHeaderCell(String text, pw.Font ttf, pw.Font bold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          font: bold,
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        ),
      ),
    );
  }

// Tablo Veri Hücreleri
  pw.Widget _buildTableDataCell(String text, pw.Font ttf) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: ttf, fontSize: 6),
      ),
    );
  }

  // Ödev kartı oluşturma fonksiyonunu _KarneEkraniState sınıfına ekleyin:
  pw.Widget _buildHomeworkCard(
      Map<String, dynamic> homework, pw.Font ttf, pw.Font boldTtf) {
    String status = savedStatuses[homework['id']] ?? 'Değerlendirme yok';
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
  }
}
