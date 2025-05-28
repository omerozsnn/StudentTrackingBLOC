import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart' show FilePicker;
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ogrenci_takip_sistemi/class_report_card_generator.dart';
import 'package:ogrenci_takip_sistemi/image_cache_manager.dart';
import 'package:ogrenci_takip_sistemi/karne.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';
import 'package:ogrenci_takip_sistemi/models/ogrenci_denemeleri_model.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:ogrenci_takip_sistemi/teacherControlCharts/analysis/denemeAnalysisChart.dart';
import 'package:ogrenci_takip_sistemi/teacherControlCharts/analysis/okulDenemeleriAnalysisChart.dart';
import 'package:printing/printing.dart';
import '/api.dart/prayerSurahApi.dart';
import '/api.dart/prayerSurahStudentApi.dart';
import '/api.dart/studentHomeworkApi.dart';
import 'api.dart/grades_api.dart' as gradesApi;
import 'api.dart/studentControlApi.dart' as studentControlApi;
import 'api.dart/classApi.dart' as classApi;
import 'api.dart/teacherFeedbackApi.dart' as teacherFeedbackApi;
import 'api.dart/prayerSurahTrackingControlApi.dart'
    as prayerSurahTrackingControlApi;
import 'api.dart/homeworkTrackingControlApi.dart' as homeworkTrackingControlApi;
import 'api.dart/defterKitapControlApi.dart' as defterKitapApi;
import 'api.dart/studentKdsApi.dart' as studentKDSApi;
import 'api.dart/ogrenciDenemeleriApi.dart' as ogrenciDenemeleriApi;
import 'teacherControlCharts/analysis/duaSureAnalizChart.dart';
import 'teacherControlCharts/analysis/homeworkAnalysisChart.dart';
import 'teacherControlCharts/analysis/gradeAnalysisPopup.dart';
import 'api.dart/courseApi.dart' as courseApi;
import 'teacherControlCharts/analysis/notebookAnalysisChart.dart';
import 'teacherControlCharts/analysis/kdsAnalysisChart.dart';
import 'api.dart/okulDenemeleriApi.dart' as okulDenemeleriApi;
import 'api.dart/ogrenciOkulDenemeleriApi.dart' as ogrenciOkulDenemeleriApi;
import 'package:http/http.dart' as http;
import 'api.dart/student_misbehaviour_api.dart' as misbehaviorControlApi;

class TeacherControl extends StatefulWidget {
  const TeacherControl({super.key});
  @override
  State<TeacherControl> createState() => _TeacherControlState();
}

class _TeacherControlState extends State<TeacherControl>
    with SingleTickerProviderStateMixin {
  final classApi.ApiService classService =
      classApi.ApiService(baseUrl: 'http://localhost:3000');
  final studentControlApi.StudentApiService studentService =
      studentControlApi.StudentApiService(baseUrl: 'http://localhost:3000');
  final studentKDSApi.ApiService studentKDSApiService =
      studentKDSApi.ApiService(baseUrl: 'http://localhost:3000');
  final ogrenciDenemeleriApi.StudentExamRepository ogrenciDenemeleriApiService =
      ogrenciDenemeleriApi.StudentExamRepository(
          baseUrl: 'http://localhost:3000');
  final gradesApi.GradesRepository gradesService =
      gradesApi.GradesRepository(baseUrl: 'http://localhost:3000');
  final teacherFeedbackApi.ApiService teacherFeedbackService =
      teacherFeedbackApi.ApiService(baseUrl: 'http://localhost:3000');
  final prayerSurahTrackingControlApi.ApiService
      prayerSurahTrackingControlService =
      prayerSurahTrackingControlApi.ApiService(
          baseUrl: 'http://localhost:3000');
  final homeworkTrackingControlApi.ApiService homeworkTrackingControlService =
      homeworkTrackingControlApi.ApiService(baseUrl: 'http://localhost:3000');
  final defterKitapApi.ApiService defterKitapService =
      defterKitapApi.ApiService(baseUrl: 'http://localhost:3000');
  final StudentHomeworkApiService studentHomeworkApiService =
      StudentHomeworkApiService(baseUrl: 'http://localhost:3000');
  final PrayerSurahStudentApiService prayerSurahStudentApiService =
      PrayerSurahStudentApiService(baseUrl: 'http://localhost:3000');
  final PrayerSurahApiService prayerSurahApiService =
      PrayerSurahApiService(baseUrl: 'http://localhost:3000');
  final courseApi.ApiService courseService =
      courseApi.ApiService(baseUrl: 'http://localhost:3000');
  final okulDenemeleriApi.ApiService okulDenemeleriApiService =
      okulDenemeleriApi.ApiService(baseUrl: 'http://localhost:3000');
  final ogrenciOkulDenemeleriApi.ApiService ogrenciOkulDenemeleriApiService =
      ogrenciOkulDenemeleriApi.ApiService(baseUrl: 'http://localhost:3000');
  final misbehaviorControlApi.StudentMisbehaviourApiService
      misbehaviorControlService =
      misbehaviorControlApi.StudentMisbehaviourApiService(
          baseUrl: 'http://localhost:3000');

  TextEditingController searchController = TextEditingController();

  List<dynamic> kdsScores = [];
  List<dynamic> denemeler = [];
  List<dynamic> okulDenemeler = [];
  List<Student> students = [];
  List<Classes> classes = [];
  List<Map<String, dynamic>> feedbacks = [];
  List<Map<String, dynamic>> prayerSurahTracking = [];
  List<Map<String, dynamic>> homeworkTracking = [];
  List<Map<String, dynamic>> grades = [];
  String? selectedTerm = "1. Dönem"; // Varsayılan dönem
  int selectedTabIndex = 0; // Seçili sekmeyi takip etmek için
  List<Map<String, dynamic>> studentHomeworks = [];
  List<Map<String, dynamic>> notebookBookHistory = [];
  String? selectedClass;
  Student? selectedStudent;
  int? selectedClassId;
  String? selectedClassName;
  Map<int, String> savedStatuses = {};
  Map<int, bool> isTrackingAdded = {};
  Map<String, List<Map<String, dynamic>>> groupedGrades = {};
  Map<String, List<dynamic>> groupedFeedbacks = {};
  Map<String, bool> expandedDates = {};
  Uint8List? studentImage;
  Key imageKey = UniqueKey();
  Map<int, Key> studentImageKeys = {};
  Map<Student, Uint8List?> studentImages = {};

  Map<String, dynamic> kdsParticipationDetails = {};

  Map<String, dynamic> denemeParticipationDetails = {};
  static const Duration connectionTimeout = Duration(seconds: 30);

  late TabController _tabController;
  // Her tab için yükleme durumunu tutan değişkenler
  bool _isFeedbacksLoaded = false;
  bool _isPrayerTrackingLoaded = false;
  bool _isHomeworkLoaded = false;
  bool _isNotebookLoaded = false;
  bool _isGradesLoaded = false;
  bool _isKDSLoaded = false;
  bool _isDenemeLoaded = false;
  bool _isOkulDenemeLoaded = false;
  bool _isMisbehavioursLoaded = false;

  List<Map<String, dynamic>> misbehaviours = [];
  Map<String, List<dynamic>> groupedMisbehaviours = {};
  Map<String, bool> expandedMisbehaviourDates = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadClasses();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      // Tab değiştiğinde sadece o tab'ın verisini yükle
      _loadTabData(_tabController.index);
    }
  }

  void _resetAllData() {
    setState(() {
      kdsScores = [];
      denemeler = [];
      okulDenemeler = [];
      feedbacks = [];
      prayerSurahTracking = [];
      homeworkTracking = [];
      grades = [];
      studentHomeworks = [];
      notebookBookHistory = [];
      groupedGrades = {};
      groupedFeedbacks = {};
      kdsParticipationDetails = {};
      denemeParticipationDetails = {};

      // Yükleme durumlarını sıfırla
      _isFeedbacksLoaded = false;
      _isPrayerTrackingLoaded = false;
      _isHomeworkLoaded = false;
      _isNotebookLoaded = false;
      _isGradesLoaded = false;
      _isKDSLoaded = false;
      _isDenemeLoaded = false;
      _isOkulDenemeLoaded = false;
    });
  }

  // Yaramazlık verilerini yüklemek için yeni fonksiyon
  Future<void> _loadStudentMisbehaviours(int studentId) async {
    try {
      final data =
          await misbehaviorControlService.getMisbehavioursGroupedByDate(
              studentId); // studentId is already an int

      if (data is Map<String, dynamic>) {
        // API yanıtından groupedByDate listesini al
        final List<dynamic> groupedByDate = data['groupedByDate'] ?? [];

        // Tarihe göre gruplandırılmış veriyi map'e dönüştür
        Map<String, List<dynamic>> formattedData = {};

        for (var group in groupedByDate) {
          String tarih = group['tarih']; // Tarihi al
          List<dynamic> yaramazliklar =
              group['yaramazliklar']; // O tarihteki yaramazlıkları al

          // Her tarih için yaramazlıkları map'e ekle
          formattedData[tarih] = yaramazliklar
              .map((yaramazlik) => {
                    'id': yaramazlik['id'],
                    'ogrenci_id': yaramazlik['ogrenci']['id'],
                    'ogrenci_adi': yaramazlik['ogrenci']['ad_soyad'],
                    'yaramazlik_id': yaramazlik['yaramazlik']['id'],
                    'yaramazlik_metni': yaramazlik['yaramazlik']['adi'],
                    'tarih': yaramazlik['tarih'],
                  })
              .toList();
        }

        setState(() {
          groupedMisbehaviours = formattedData;
          _isMisbehavioursLoaded = true;
        });

        // Debug bilgisi
        print('Toplam Kayıt: ${data['totalRecords']}');
        print('Öğrenci: ${data['student']['ad_soyad']}');
        print('Eğitim Yılı: ${data['currentYear']}');
      } else {
        throw Exception('Geçersiz veri formatı');
      }
    } catch (error) {
      print('Yaramazlık verileri yüklenemedi: $error');
      setState(() {
        _isMisbehavioursLoaded = true;
        groupedMisbehaviours = {};
      });
    }
  }

  Future<void> _loadTabData(int index) async {
    if (!mounted || selectedStudent == null) return;

    final studentId = selectedStudent!.id;
    bool success = false;

    try {
      setState(() {
        // İlgili tab için loading göstergesi
        switch (index) {
          case 0:
            _isFeedbacksLoaded = false;
            break;
          case 1:
            _isMisbehavioursLoaded = false;
            break;
          case 2:
            _isPrayerTrackingLoaded = false;
            break;
          case 3:
            _isHomeworkLoaded = false;
            break;
          case 4:
            _isNotebookLoaded = false;
            break;
          case 5:
            _isGradesLoaded = false;
            break;
          case 6:
            _isKDSLoaded = false;
            break;
          case 7:
            _isDenemeLoaded = false;
            break;
          case 8:
            _isOkulDenemeLoaded = false;
            break;
        }
      });

      switch (index) {
        case 0:
          if (!_isFeedbacksLoaded) {
            await _loadGroupedFeedbacks(studentId);
            success = true;
          }
          break;
        case 1: // Yaramazlık tab'ı için yeni case
          if (!_isMisbehavioursLoaded) {
            await _loadStudentMisbehaviours(selectedStudent!.id);
            success = true;
          }
          break;
        case 2:
          if (!_isPrayerTrackingLoaded) {
            await _loadStudentPrayerSurahTracking(studentId);
            success = true;
          }
          break;
        case 3:
          if (!_isHomeworkLoaded) {
            await _loadStudentHomeworkTracking(studentId);
            success = true;
          }
          break;
        case 4:
          if (!_isNotebookLoaded) {
            await _loadNotebookAndBookHistory(studentId);
            success = true;
          }
          break;
        case 5:
          if (!_isGradesLoaded) {
            await _loadStudentGradesBySemester(
                studentId, int.parse(selectedTerm!.split('.').first));
            success = true;
          }
          break;
        case 6:
          if (!_isKDSLoaded) {
            await Future.wait([
              _loadKDSScores(studentId),
              _loadKDSData(studentId),
            ]);
            success = true;
          }
          break;
        case 7:
          if (!_isDenemeLoaded) {
            await Future.wait([
              _loadDenemeScores(studentId),
              _loadDenemeParticipationData(studentId),
            ]);
            success = true;
          }
          break;
        case 8:
          if (!_isOkulDenemeLoaded) {
            await _loadOkulDenemeleri(studentId);
            success = true;
          }
          break;
      }

      if (mounted && success) {
        setState(() {
          switch (index) {
            case 0:
              _isFeedbacksLoaded = true;
              break;
            case 1:
              _isMisbehavioursLoaded = true;
              break;
            case 2:
              _isPrayerTrackingLoaded = true;
              break;
            case 3:
              _isHomeworkLoaded = true;
              break;
            case 4:
              _isNotebookLoaded = true;
              break;
            case 5:
              _isGradesLoaded = true;
              break;
            case 6:
              _isKDSLoaded = true;
              break;
            case 7:
              _isDenemeLoaded = true;
              break;
            case 8:
              _isOkulDenemeLoaded = true;
              break;
          }
        });
      }
    } catch (e) {
      print('Tab verisi yüklenirken hata: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veriler yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

// 3. Öğrenci seçiminde çağrılacak yeni fonksiyon
  void _onStudentSelected(Student student) async {
    // Önce tüm verileri temizle
    _resetAllData();

    // Yeni öğrenciyi seç
    setState(() {
      selectedStudent = student;
      imageKey = UniqueKey();
    });

    try {
      // Öğrenci resmini yükle
      final imageBytes = await getStudentImage(student.id);
      if (mounted) {
        setState(() {
          studentImages[student] = imageBytes;
        });
      }

      // Sadece aktif tab'ın verisini yükle
      await _loadTabData(_tabController.index);
    } catch (e) {
      print('Öğrenci verisi yüklenirken hata: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veriler yüklenirken hata oluştu')),
        );
      }
    }
  }

  // Deneme Sinavi Katilim verilerini yükle
  Future<void> _loadDenemeParticipationData(int studentId) async {
    try {
      final data = await ogrenciDenemeleriApiService
          .getStudentExamParticipation(studentId);

      // Convert StudentExamParticipation to Map<String, dynamic>
      Map<String, dynamic> participationMap = {
        'ogrenciId': data.ogrenciId,
        'ogrenciAdi': data.ogrenciAdi,
        'sinifId': data.sinifId,
        'sinifAdi': data.sinifAdi,
        'egitimYiliId': data.egitimYiliId,
        'totalDeneme': data.totalDeneme,
        'katilanDenemeSayisi': data.katilanDenemeSayisi,
        'katilmayanDenemeSayisi': data.katilmayanDenemeSayisi,
        'katilanDenemeler': data.katilanDenemeler
            .map((e) => {
                  'denemeSinaviId': e.denemeSinaviId,
                  'denemeSinaviAdi': e.denemeSinaviAdi,
                  'dogru': e.dogru,
                  'yanlis': e.yanlis,
                  'bos': e.bos,
                  'puan': e.puan,
                })
            .toList(),
        'katilmayanDenemeler': data.katilmayanDenemeler
            .map((e) => {
                  'denemeSinaviId': e.denemeSinaviId,
                  'denemeSinaviAdi': e.denemeSinaviAdi,
                })
            .toList(),
      };

      setState(() {
        denemeParticipationDetails = participationMap;
      });
    } catch (e) {
      print('Deneme verileri yüklenemedi: $e');
    }
  }

  // KDS Participation verilerini yükle
  Future<void> _loadKDSData(int studentId) async {
    try {
      final data = await studentKDSApiService
          .getStudentKDSParticipationDetails(studentId);
      setState(() {
        kdsParticipationDetails = data;
      });
    } catch (e) {
      print('KDS verileri yüklenemedi: $e');
    }
  }

  //Sınıfa göre Öğrencileri listele
  Future<void> _loadStudentsByClass(String className) async {
    try {
      final studentsData =
          await studentService.getStudentsByClassName(className);

      setState(() {
        // Önce mevcut image key'leri temizle
        studentImageKeys.clear();

        students = studentsData;

        for (var student in students) {
          // Her öğrenci için yeni bir key oluştur
          studentImageKeys[student.id] = UniqueKey();
        }
        selectedStudent = null;
        studentImage = null;
      });

      // Öğrenci resimlerini yükle
      for (var student in students) {
        _loadStudentImage(student.id);
      }
    } catch (error) {
      print('Öğrenciler yüklenemedi: $error');
    }
  }

  Future<Uint8List?> getStudentImage(int id) async {
    try {
      final response = await http
          .get(
            Uri.parse('http://localhost:3000/student/$id/image'),
          )
          .timeout(connectionTimeout);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else if (response.statusCode == 404) {
        print('Resim bulunamadı: $id');
        return null;
      } else {
        throw Exception('Resim getirme hatası: ${response.statusCode}');
      }
    } on TimeoutException {
      print('Resim getirme zaman aşımı: $id');
      return null;
    } catch (e) {
      print('Resim getirme hatası: $e');
      return null;
    }
  }

  Future<void> _loadStudentImage(int studentId) async {
    try {
      final imageBytes = await getStudentImage(studentId);

      if (!mounted) return;

      setState(() {
        studentImage = imageBytes;
      });
    } catch (error) {
      print('Resim yüklenemedi: $error');
      if (!mounted) return;

      setState(() {
        studentImage = null;
      });
    }
  }

  Future<void> searchStudents() async {
    try {
      if (selectedClass != null) {
        // Önce sınıftaki tüm öğrencileri al
        final List<Student> allStudents =
            await studentService.getStudentsByClassName(selectedClass!);

        // Arama metnine göre filtreleme
        String searchText = searchController.text.toLowerCase();
        List<Student> filteredStudents = allStudents.where((student) {
          return student.adSoyad.toLowerCase().contains(searchText);
        }).toList();

        // Öğrenci numarasına göre sıralama
        filteredStudents.sort((a, b) {
          final aNo = int.tryParse(a.ogrenciNo ?? '') ?? 0;
          final bNo = int.tryParse(b.ogrenciNo ?? '') ?? 0;
          return aNo.compareTo(bNo);
        });

        setState(() {
          students = filteredStudents;
        });
      }
    } catch (error) {
      print('Öğrenciler yüklenemedi: $error');
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

  //Sınıfları listele
  Future<void> _loadClasses() async {
    try {
      final List<Classes> classesData =
          await classService.getClassesForDropdown();

      setState(() {
        classes = List<Classes>.from(classesData);
      });
    } catch (error) {
      print('Sınıflar yüklenemedi: $error');
    }
  }

  // Gruplanmıs Öğrenci Öğretmen görüşlerini getir
  Future<void> _loadGroupedFeedbacks(int studentId) async {
    try {
      final feedbacksData = await teacherFeedbackService
          .getTeacherFeedbackByStudentIdandDate(studentId);

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

  Future<String> _loadClassNameByClassId(classId) async {
    try {
      final classData = await classService.getClassById(classId);
      setState(() {
        selectedClassName = classData.sinifAdi;
      });
      return classData.sinifAdi;
    } catch (error) {
      print('Sınıf adı yüklenirken hata: $error');
      throw Exception('Sınıf adı yüklenemedi');
    }
  }

  Future<void> _loadStudentGradesBySemester(int studentId, int term) async {
    try {
      final responseData =
          await gradesService.getStudentSemesterGrades(studentId, term);

      if (responseData.dersler == null) {
        throw Exception('API yanıtında "dersler" bulunamadı.');
      }

      final List<Map<String, dynamic>> fetchedGrades =
          List<Map<String, dynamic>>.from(responseData.dersler);

      setState(() {
        grades = fetchedGrades;
        groupedGrades = _groupedGradesByCourse(); // Derslere göre grupla
      });
    } catch (error) {
      print('⛔ Notlar yüklenirken hata oluştu: $error');
    }
  }

  Map<String, List<Map<String, dynamic>>> _groupedGradesByCourse() {
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var grade in grades) {
      String courseName = grade['ders_adi'] ?? 'Bilinmeyen Ders';

      if (!grouped.containsKey(courseName)) {
        grouped[courseName] = [];
      }
      grouped[courseName]!.add(grade);
    }

    return grouped;
  }

  // Öğrenciye ait Dua Sure Kayıtlarını getir
  Future<void> _loadStudentPrayerSurahTracking(int studentId) async {
    try {
      print('Dua/Sure takibi yükleniyor... StudentID: $studentId');

      // 1. Önce öğrenciye atanmış tüm dua/sureleri alalım
      final assignedPrayerSurahs = await prayerSurahStudentApiService
          .getPrayerSurahStudentByStudentId(studentId);

      // 2. Takip verilerini alalım
      final trackingData = await prayerSurahTrackingControlService
          .getPrayerSurahTrackingsByStudentId(studentId);

      // 3. Her bir atanmış dua/sure için detay bilgilerini çekelim
      List<Map<String, dynamic>> processedData = [];

      for (var assigned in assignedPrayerSurahs) {
        try {
          final duaSureId = assigned['dua_sure_id'];
          if (duaSureId != null) {
            // Dua/Sure detayını çek
            final duaSureDetail =
                await prayerSurahApiService.getPrayerSurahById(duaSureId);

            // Bu dua/sure için takip kaydı var mı kontrol et
            var tracking = trackingData.firstWhere(
              (track) =>
                  track['prayer_surah_student']?['dua_sure_id'] == duaSureId,
              orElse: () => {},
            );

            // Durumu kontrol et
            bool isPositive = tracking != null && tracking['durum'] == 'Okudu';

            processedData.add({
              'id': assigned['id'],
              'dua_sure_id': duaSureId.toString(),
              'dua_sure_adi': duaSureDetail['dua_sure_adi'] ?? 'İsimsiz',
              'durum': tracking?['durum'] ?? 'Okumadı',
              'degerlendirme': tracking?['degerlendirme'] ?? '',
              'createdAt':
                  tracking?['createdAt'] ?? DateTime.now().toIso8601String(),
              'isPositive': isPositive,
            });
          }
        } catch (detailError) {
          print('Dua/Sure detay yükleme hatası: $detailError');
        }
      }

      setState(() {
        prayerSurahTracking = processedData;
      });

      print('İşlenmiş veriler: $prayerSurahTracking');
    } catch (error) {
      print('Dua/Sure takibi yüklenirken hata: $error');
    }
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

  Future<void> _loadStudentHomeworkTracking(int studentId) async {
    try {
      // Öğrenciye atanmış tüm ödevleri al
      final homeworkData = await studentHomeworkApiService
          .getStudentHomeworksByStudentId(studentId);

      List<Map<String, dynamic>> processedData = [];

      for (var homework in homeworkData) {
        // Student Homework ID'yi alıyoruz
        final studentHomeworkId = homework['id']; // Student Homework ID

        // Takip verilerini alırken doğru ID'yi kullanıyoruz
        final trackingData = await homeworkTrackingControlService
            .getHomeworkTrackingByStudentHomeworkId(studentHomeworkId);

        // Ödev durumunu belirleyin
        final isPositive =
            trackingData.isNotEmpty && trackingData[0]['durum'] == 'yapti';

        processedData.add({
          'id': studentHomeworkId,
          'odev_adi': homework['homework']['odev_adi'] ?? 'Adı Yok',
          'teslim_tarihi': homework['homework']['teslim_tarihi'] ?? 'Tarih Yok',
          'durum': isPositive ? '+' : '-',
        });
      }

      setState(() {
        homeworkTracking = processedData;
      });
    } catch (e) {
      print('Ödev takibi yüklenirken hata oluştu: $e');
    }
  }

  // Öğrenciye ait Kitap Defter Kayıtlarını getir
  Future<void> _loadNotebookAndBookHistory(int studentId) async {
    try {
      final historyData =
          await defterKitapService.getDefterKitapByStudentId(studentId);
      List<Map<String, dynamic>> loadedHistory = [];

      for (var entry in historyData) {
        if (entry.courseClasses?.isNotEmpty ?? false) {
          final dersId = entry.courseClasses![0]['ders_id'];
          final courseData = await courseService.getCourseById(dersId);

          loadedHistory.add({
            'tarih': entry.tarih,
            'defter_durum': entry.defterDurum,
            'kitap_durum': entry.kitapDurum,
            'courseClasses': entry.courseClasses,
            'ders_adi': courseData.dersAdi
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

  Map<String, dynamic> _getNotebookBookAnalysis() {
    int totalMissingNotebook = 0;
    int totalMissingBook = 0;
    int totalRecords = notebookBookHistory.length;

    for (var record in notebookBookHistory) {
      if (record['defter_durum'] == 'getirmedi') {
        totalMissingNotebook++;
      }
      if (record['kitap_durum'] == 'getirmedi') {
        totalMissingBook++;
      }
    }

    return {
      'totalMissingNotebook': totalMissingNotebook,
      'totalMissingBook': totalMissingBook,
      'totalRecords': totalRecords,
    };
  }

  void _showNotebookBookAnalysis() {
    final analysis = _getNotebookBookAnalysis();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: 1000,
          height: 1000,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Defter ve Kitap Analizi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: NotebookBookAnalysisChart(analysis: analysis),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Kapat',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> uploadStudentImage(int studentId) async {
    try {
      final imagePicker = ImagePicker();
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resim seçilmedi.')),
        );
        return;
      }

      // Http client oluştur ve timeout ayarla
      final client = http.Client();
      try {
        // MultipartRequest oluştur
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('http://localhost:3000/student/$studentId/upload-image'),
        );

        // Dosyayı ekle
        final file = await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType('image', image.path.split('.').last),
        );
        request.files.add(file);

        // İsteği gönder ve timeout ile yönet
        final response = await client.send(request).timeout(connectionTimeout);
        final responseData = await http.Response.fromStream(response);

        if (!mounted) return;

        if (responseData.statusCode == 200) {
          // Önbelleği temizle
          StudentImageCache().removeFromCache(studentId);

          // UI'ı güncelle
          setState(() {
            imageKey = UniqueKey();
            _loadStudentImage(studentId);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Resim başarıyla yüklendi.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception(
              'Resim yükleme başarısız: ${responseData.statusCode}');
        }
      } finally {
        client.close(); // Client'ı temizle
      }
    } catch (e) {
      if (!mounted) return;

      print('Resim yükleme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resim yüklenirken hata oluştu: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, int> _getPrayerSurahAnalysis() {
    int okunan =
        prayerSurahTracking.where((tracking) => tracking['isPositive']).length;
    int okunmayan = prayerSurahTracking.length - okunan;

    return {'okunan': okunan, 'okunmayan': okunmayan};
  }

  Future<void> _printClassReportCards() async {
    if (selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen önce bir sınıf seçin')),
      );
      return;
    }

    try {
      // Önce sınıf ID'sini al
      if (selectedClassId == null) {
        final classIdString =
            await classService.getClassIdByName(selectedClass!);
        selectedClassId = int.tryParse(classIdString.toString());
      }

      if (selectedClassId == null) {
        throw Exception('Sınıf ID bulunamadı');
      }

      // Yükleniyor göstergesi
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                    "Sınıf karneleri hazırlanıyor...\nBu işlem birkaç dakika sürebilir."),
              ],
            ),
          ),
        ),
      );

      // Seçili sınıftaki tüm öğrencileri getir
      final studentsData =
          await studentService.getStudentsByClassName(selectedClass!);

      // Öğrenci listesini düzenle
      final List<Student> classStudents = studentsData.map((student) {
        return Student(
          id: student.id,
          adSoyad: student.adSoyad ?? '',
          ogrenciNo: student.ogrenciNo ?? '',
          sinifId: selectedClassId!,
        );
      }).toList();

      if (classStudents.isEmpty) {
        // Yükleniyor göstergesini kapat
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sınıfta öğrenci bulunmamaktadır')),
        );
        return;
      }

      // Öğrenci numarasına göre sırala
      classStudents.sort((a, b) {
        final aNo = int.tryParse(a.ogrenciNo?.toString() ?? '') ?? 0;
        final bNo = int.tryParse(b.ogrenciNo?.toString() ?? '') ?? 0;
        return aNo.compareTo(bNo);
      });

      if (classStudents.isEmpty) {
        // Yükleniyor göstergesini kapat
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sınıfta öğrenci bulunmamaktadır')),
        );
        return;
      }

      // Dönem seçimi için dialog göster
      final selectedTerm = await _showTermSelectionDialog();

      if (selectedTerm == null) {
        // Kullanıcı dialog'u iptal ettiyse
        Navigator.pop(context); // Yükleniyor göstergesini kapat
        return;
      }

      // ClassReportCardGenerator sınıfını kullanarak tüm öğrencilerin karnelerini oluştur
      final karneGenerator = ClassReportCardGenerator(
        students: classStudents,
        className: selectedClass!,
        classId: selectedClassId!,
        term: selectedTerm, // Kullanıcının seçtiği dönem
        context: context,
      );

      // PDF oluştur
      final pdfBytes = await karneGenerator.generateClassReportCardPdf();

      // Yükleniyor göstergesini kapat
      Navigator.pop(context);

      // PDF önizleme sayfasını aç
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(
                  "$selectedClass Sınıfı Karneleri - ${selectedTerm == 1 ? '1. Dönem' : '2. Dönem'}"),
            ),
            body: PdfPreview(
              build: (format) => pdfBytes,
              useActions: true,
              canDebug: false,
              canChangePageFormat: false,
              pdfFileName:
                  "${selectedClass}_sinifi_karneleri_${selectedTerm}_donem_${DateTime.now().millisecondsSinceEpoch}.pdf",
              actions: [
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () async {
                    final String? filePath = await FilePicker.platform.saveFile(
                      dialogTitle: 'PDF Olarak Kaydet',
                      fileName:
                          "${selectedClass}_sinifi_karneleri_${selectedTerm}_donem_${DateTime.now().millisecondsSinceEpoch}.pdf",
                    );

                    if (filePath != null) {
                      final file = File(filePath);
                      await file.writeAsBytes(pdfBytes);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('PDF başarıyla kaydedildi: $filePath')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      // Yükleniyor göstergesini kapat (hata durumunda)
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Karneler oluşturulurken hata oluştu: $e')),
      );
    }
  }

// Dönem seçimi dialog'unu gösteren metot
  Future<int?> _showTermSelectionDialog() async {
    return await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dönem Seçimi'),
        content: const Text('Hangi dönem için karne hazırlamak istiyorsunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 1),
            child: const Text('1. Dönem'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 2),
            child: const Text('2. Dönem'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPrayerSurahAnalysis() {
    final analysis = _getPrayerSurahAnalysis();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20), // Kenar boşlukları
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Köşeleri yuvarlama
        ),
        child: SizedBox(
          width: 500, // Genişlik
          height: 500, // Yükseklik
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Dua ve Sure Analizi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: PrayerSurahAnalysisChart(analysis: analysis),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Kapat',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, int> _getHomeworkAnalysis() {
    int completed =
        homeworkTracking.where((tracking) => tracking['durum'] == '+').length;
    int incomplete = homeworkTracking.length - completed;

    return {'completed': completed, 'incomplete': incomplete};
  }

  void _showHomeworkAnalysis() {
    final analysis = _getHomeworkAnalysis();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SizedBox(
          width: 500,
          height: 500,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Ödev Analizi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: HomeworkAnalysisChart(analysis: analysis),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Kapat',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(8.0), // Padding azaltıldı
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Öğrenci Takip Sistemi',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18, // Font boyutu küçültüldü
                ),
          ),
          const SizedBox(height: 4), // Boşluk azaltıldı
          Text(
            'Sınıf seçerek öğrencileri görüntüleyebilirsiniz',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 14, // Font boyutu küçültüldü
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelector() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Padding azaltıldı
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sınıf Seçimi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 16, // Font boyutu küçültüldü
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8), // Padding azaltıldı
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              value: selectedClass,
              hint: const Text('Sınıf Seçiniz'),
              items: classes.map((classData) {
                return DropdownMenuItem<String>(
                  value: classData.sinifAdi.toString(),
                  child: Text(classData.sinifAdi.toString()),
                );
              }).toList(),
              onChanged: (String? newValue) async {
                if (newValue != null) {
                  // Önce sınıf ID'sini al
                  final classIdString =
                      await classService.getClassIdByName(newValue);
                  final classId = int.tryParse(classIdString.toString());

                  setState(() {
                    selectedClass = newValue;
                    selectedClassId = classId; // Sınıf ID'sini kaydet
                    selectedStudent = null;
                    _loadStudentsByClass(newValue);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassSelectorWithPrintOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildClassSelector(), // Mevcut sınıf seçici

        // Sınıf seçildiğinde ve öğrenci listesi yüklendiğinde gösterilecek toplu yazdırma butonu
        if (selectedClass != null && students.isNotEmpty)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton.icon(
              onPressed: _printClassReportCards,
              icon: const Icon(Icons.print_rounded),
              label: const Text("Sınıf Bazında Karne Yazdır"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Öğrenci Ara...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          // Arama ikonunu ekle
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              // Arama alanını temizle ve tüm öğrencileri yeniden yükle
              searchController.clear();
              if (selectedClass != null) {
                _loadStudentsByClass(selectedClass!);
              }
            },
          ),
        ),
        onChanged: (value) {
          // Her karakter değişiminde arama yap
          searchStudents();
        },
      ),
    );
  }

  Widget _buildStudentList() {
    return Expanded(
      child: students.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz öğrenci seçilmedi',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lütfen bir sınıf seçin',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final isSelected = selectedStudent?.id == student.id;

                return Card(
                  elevation: isSelected ? 2 : 0,
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    selected: isSelected,
                    // Burada StudentImageWidget kullanımı
                    leading: StudentImageWidget(
                      key: studentImageKeys[
                          student.id], // Her öğrenci için unique key
                      studentId: student.id,
                      width: 55,
                      height: 55,
                      shape: StudentImageShape.circle,
                    ),
                    title: Text(
                      '${student.ogrenciNo} - ${student.adSoyad}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      _onStudentSelected(student);
                    },
                  ),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Öğretmen Öğrenci Takip'),
        actions: [
          // Mevcut refresh butonu
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (selectedClass != null) {
                _loadStudentsByClass(selectedClass!);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          children: [
            // Sol Panel (Mevcut kod)
            SizedBox(
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildHeader(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildClassSelectorWithPrintOption(),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildSearchBar(),
                  ),
                  const SizedBox(height: 16),
                  _buildStudentList(),
                ],
              ),
            ),

            // Dikey Çizgi
            VerticalDivider(color: Colors.grey[300], width: 1),

            // Sağ Panel (Öğrenci Detayları)
            if (selectedStudent != null)
              Expanded(
                child: _buildStudentDetails(),
              )
            else
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outline,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Öğrenci seçilmedi',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Detayları görüntülemek için bir öğrenci seçin',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDetails() {
    // Seçili öğrenciyi bul
    final student = selectedStudent!;

    return DefaultTabController(
      length: 8,
      child: Column(
        children: [
          // Öğrenci Başlık Kartı
          Container(
            padding: const EdgeInsets.all(15),
            color: Colors.white,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    width: 130,
                    height: 140,
                    child: selectedStudent != null
                        ? StudentImageWidget(
                            key: imageKey, // Her öğrenci değişiminde yeni key
                            studentId: selectedStudent!.id,
                            width: 130,
                            height: 140,
                            shape: StudentImageShape.rectangle,
                            fit: BoxFit.cover,
                            onTap: () async {
                              await uploadStudentImage(selectedStudent!.id);
                              setState(() {
                                imageKey =
                                    UniqueKey(); // Resim yüklemesi sonrası yeni key
                              });
                            },
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.photo_library,
                                    size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Fotoğraf yok'),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 15),
                // Ogrenci Bilgileri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.adSoyad ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Öğrenci No: ${student.ogrenciNo}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sınıf: $selectedClassName',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                // Karne yazdir Butonu
                Container(
                  padding: const EdgeInsets.only(left: 20),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (selectedStudent != null && selectedClass != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KarneEkrani(
                              studentId: selectedStudent!.id,
                              selectedClass: selectedClass!,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lütfen bir öğrenci ve sınıf seçin!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.print_rounded, size: 24),
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Seçili Öğrenci için",
                          style: TextStyle(fontSize: 12),
                        ),
                        const Text(
                          "Karne Yazdır",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      backgroundColor: const Color.fromARGB(255, 48, 201, 155),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Öğretmen Görüşleri'),
                Tab(text: 'Yaramazlık Kontrolü'), // Yeni tab
                Tab(text: 'Dua ve Sure Takibi'),
                Tab(text: 'Ödev Takibi'),
                Tab(text: 'Kitap Defter Takibi'),
                Tab(text: 'Notlar'),
                Tab(text: 'KDS'),
                Tab(text: 'Denemeler'),
                Tab(text: 'Okul Denemeleri'),
              ],
            ),
          ),

          // Tab İçerikleri
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLoadingWrapper(
                    _isFeedbacksLoaded, _buildTeacherFeedbackTab()),
                _buildLoadingWrapper(_isMisbehavioursLoaded,
                    _buildMisbehavioursTab()), // Yeni tab içeriği
                _buildLoadingWrapper(
                    _isPrayerTrackingLoaded, _buildPrayerTrackingTab()),
                _buildLoadingWrapper(
                    _isHomeworkLoaded, _buildHomeworkTrackingTab()),
                _buildLoadingWrapper(
                    _isNotebookLoaded, _buildBookNotebookTab()),
                _buildLoadingWrapper(_isGradesLoaded, _buildGradesTab()),
                _buildLoadingWrapper(_isKDSLoaded, _buildKDSTab()),
                _buildLoadingWrapper(_isDenemeLoaded, _buildDenemeTab()),
                _buildLoadingWrapper(
                    _isOkulDenemeLoaded, _buildOkulDenemesiTab()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWrapper(bool isLoaded, Widget child) {
    return isLoaded
        ? child
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C8997)),
                ),
                SizedBox(height: 16),
                Text(
                  'Veriler yükleniyor...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                )
              ],
            ),
          );
  }

  Widget _buildTeacherFeedbackTab() {
    if (selectedStudent == null) {
      return _buildEmptyStateWidget(
        'Öğrenci seçilmedi',
        'Lütfen sol menüden bir öğrenci seçin',
        Icons.person_outline,
      );
    }

    if (!_isFeedbacksLoaded) {
      return _buildLoadingWrapper(_isFeedbacksLoaded, Container());
    }

    if (groupedFeedbacks.isEmpty) {
      return _buildEmptyStateWidget(
        'Henüz görüş girilmemiş',
        'Bu öğrenci için öğretmen görüşü bulunmuyor',
        Icons.feedback_outlined,
      );
    }

    final sortedDates = groupedFeedbacks.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final feedbacks = groupedFeedbacks[date]!;
        final isExpanded =
            expandedDates[date] ?? true; // Varsayılan olarak açık

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tıklanabilir Tarih başlığı
            InkWell(
              onTap: () {
                setState(() {
                  expandedDates[date] = !(expandedDates[date] ?? true);
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 48, 201, 155),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    Icon(
                      isExpanded ? Icons.expand_more : Icons.chevron_right,
                      color: Colors.white,
                      size: 24,
                    ),
                    Icon(Icons.calendar_today, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(date),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${feedbacks.length} görüş',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 48, 201, 155),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Görüşler grid yapısında
            if (isExpanded)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: feedbacks.map((feedback) {
                    return Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width > 800
                            ? (MediaQuery.of(context).size.width - 96) /
                                3 // Maksimum genişlik - 3 kolon
                            : (MediaQuery.of(context).size.width - 72) /
                                2, // Maksimum genişlik - 2 kolon
                        minWidth: 200, // Minimum genişlik
                      ),
                      child: IntrinsicWidth(
                        // İçeriğe göre genişliği ayarlar
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.blue.shade50,
                                      child: Icon(
                                        Icons.comment_outlined,
                                        size: 18,
                                        color:
                                            Color.fromARGB(255, 48, 201, 155),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        TimeOfDay.fromDateTime(DateTime.parse(
                                                feedback['tarih']))
                                            .format(context),
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  feedback['gorus_metni'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (feedback['ek_gorus'] != null &&
                                    feedback['ek_gorus']
                                        .toString()
                                        .isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: Text(
                                      feedback['ek_gorus'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 24), // Tarih grupları arası boşluk
          ],
        );
      },
    );
  }

  // Yaramazlık tab içeriğini oluşturan yeni widget
  Widget _buildMisbehavioursTab() {
    if (selectedStudent == null) {
      return _buildEmptyStateWidget(
        'Öğrenci seçilmedi',
        'Lütfen sol menüden bir öğrenci seçin',
        Icons.person_outline,
      );
    }

    if (!_isMisbehavioursLoaded) {
      return _buildLoadingWrapper(_isMisbehavioursLoaded, Container());
    }

    if (groupedMisbehaviours.isEmpty) {
      return _buildEmptyStateWidget(
        'Yaramazlık kaydı bulunamadı',
        'Bu öğrenci için henüz yaramazlık kaydı girilmemiş',
        Icons.warning_outlined,
      );
    }

    final sortedDates = groupedMisbehaviours.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final misbehaviours = groupedMisbehaviours[date]!;
        final isExpanded = expandedMisbehaviourDates[date] ?? true;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  expandedMisbehaviourDates[date] = !isExpanded;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 175, 39, 53),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color.fromARGB(255, 235, 115, 115)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isExpanded ? Icons.expand_more : Icons.chevron_right,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      size: 24,
                    ),
                    Icon(Icons.calendar_today,
                        color: const Color.fromARGB(255, 255, 255, 255),
                        size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(date),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${misbehaviours.length} kayıt',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 169, 0, 0),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: misbehaviours.map((misbehaviour) {
                    return Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width > 800
                            ? (MediaQuery.of(context).size.width - 96) / 3
                            : (MediaQuery.of(context).size.width - 72) / 2,
                        minWidth: 200,
                      ),
                      child: Card(
                        elevation: 4,
                        color: const Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                              color: const Color.fromARGB(255, 255, 255, 255)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.red[100],
                                    child: Icon(
                                      Icons.warning_outlined,
                                      size: 18,
                                      color: const Color.fromARGB(
                                          255, 251, 176, 14),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      TimeOfDay.fromDateTime(DateTime.parse(
                                              misbehaviour['tarih']))
                                          .format(context),
                                      style: TextStyle(
                                        color:
                                            const Color.fromARGB(255, 0, 0, 0),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                misbehaviour['yaramazlik_metni'] ?? '',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildPrayerTrackingTab() {
    if (selectedStudent == null) {
      return _buildEmptyStateWidget(
        'Öğrenci seçilmedi',
        'Lütfen sol menüden bir öğrenci seçin',
        Icons.person_outline,
      );
    }

    if (!_isPrayerTrackingLoaded) {
      return _buildLoadingWrapper(_isPrayerTrackingLoaded, Container());
    }

    if (prayerSurahTracking.isEmpty) {
      return _buildEmptyStateWidget(
        'Dua/Sure kaydı bulunamadı',
        'Bu öğrenci için henüz dua/sure takibi yapılmamış',
        Icons.menu_book_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.analytics),
            label: const Text('Analiz Görüntüle'),
            onPressed: _showPrayerSurahAnalysis,
          ),
        ),
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  Colors.grey[100],
                ),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Dua/Sure Adı',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Tarih',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Durum',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Değerlendirme',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: prayerSurahTracking.map((tracking) {
                  return DataRow(
                    cells: [
                      DataCell(Text(tracking['dua_sure_adi'] ?? '')),
                      DataCell(Text(_formatDate(tracking['createdAt']))),
                      DataCell(
                        tracking['isPositive']
                            ? Icon(Icons.check_circle, color: Colors.green[700])
                            : Icon(Icons.cancel, color: Colors.red[700]),
                      ),
                      DataCell(Text(tracking['degerlendirme'] ?? '')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeworkTrackingTab() {
    if (selectedStudent == null) {
      return _buildEmptyStateWidget(
        'Öğrenci seçilmedi',
        'Lütfen sol menüden bir öğrenci seçin',
        Icons.person_outline,
      );
    }

    if (!_isHomeworkLoaded) {
      return _buildLoadingWrapper(_isHomeworkLoaded, Container());
    }

    if (homeworkTracking.isEmpty) {
      return _buildEmptyStateWidget(
        'Ödev kaydı bulunamadı',
        'Bu öğrenci için henüz ödev takibi yapılmamış',
        Icons.assignment_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.analytics),
            label: const Text('Ödev Analizini Görüntüle'),
            onPressed: _showHomeworkAnalysis,
          ),
        ),
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  Colors.grey[100],
                ),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Ödev Adı',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Teslim Tarihi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Durum',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: homeworkTracking.map((tracking) {
                  return DataRow(
                    cells: [
                      DataCell(Text(tracking['odev_adi'] ?? '')),
                      DataCell(Text(tracking['teslim_tarihi'] ?? '')),
                      DataCell(
                        tracking['durum'] == '+'
                            ? Icon(Icons.check_circle, color: Colors.green[700])
                            : Icon(Icons.cancel, color: Colors.red[700]),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookNotebookTab() {
    if (selectedStudent == null) {
      return _buildEmptyStateWidget(
        'Öğrenci seçilmedi',
        'Lütfen sol menüden bir öğrenci seçin',
        Icons.person_outline,
      );
    }

    if (!_isNotebookLoaded) {
      return _buildLoadingWrapper(_isNotebookLoaded, Container());
    }

    if (notebookBookHistory.isEmpty) {
      return _buildEmptyStateWidget(
        'Defter/Kitap kaydı bulunamadı',
        'Bu öğrenci için henüz defter/kitap kontrolü yapılmamış',
        Icons.book_outlined,
      );
    }
    Map<int, List<Map<String, dynamic>>> groupedHistory = {};

    for (var record in notebookBookHistory) {
      int classId = record['courseClasses']?[0]?['id'] ?? 0;
      if (!groupedHistory.containsKey(classId)) {
        groupedHistory[classId] = [];
      }
      groupedHistory[classId]!.add(record);
    }

    return Column(
      // Column ekliyoruz
      children: [
        // Analiz butonu buraya ekleniyor
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.analytics),
            label: const Text('Defter/Kitap Analizini Görüntüle'),
            onPressed: _showNotebookBookAnalysis,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedHistory.length,
            itemBuilder: (context, index) {
              int classId = groupedHistory.keys.elementAt(index);
              List<Map<String, dynamic>> records = groupedHistory[classId]!;
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: FutureBuilder(
                    future: courseService.getCourseById(
                        records[0]['courseClasses'][0]['ders_id']),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(
                          snapshot.data?.dersAdi ?? 'Ders Adı Yok',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        );
                      }
                      return Text('Yükleniyor...');
                    },
                  ),
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: records.length,
                      separatorBuilder: (context, index) => Divider(),
                      itemBuilder: (context, recordIndex) {
                        final record = records[recordIndex];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 150,
                                child: Text(
                                  _formatDate(record['tarih']),
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              SizedBox(width: 24),
                              Row(
                                children: [
                                  Icon(
                                    record['defter_durum'] == 'getirmedi'
                                        ? Icons.cancel
                                        : Icons.check_circle,
                                    color: record['defter_durum'] == 'getirmedi'
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Defter'),
                                ],
                              ),
                              SizedBox(width: 24),
                              Row(
                                children: [
                                  Icon(
                                    record['kitap_durum'] == 'getirmedi'
                                        ? Icons.cancel
                                        : Icons.check_circle,
                                    color: record['kitap_durum'] == 'getirmedi'
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Kitap'),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGradesTab() {
    ScrollController verticalScrollController = ScrollController();
    ScrollController horizontalScrollController = ScrollController();
    if (selectedStudent == null) {
      return _buildEmptyStateWidget(
        'Öğrenci seçilmedi',
        'Lütfen sol menüden bir öğrenci seçin',
        Icons.person_outline,
      );
    }

    if (!_isGradesLoaded) {
      return _buildLoadingWrapper(_isGradesLoaded, Container());
    }

    if (grades.isEmpty) {
      return _buildEmptyStateWidget(
        'Not kaydı bulunamadı',
        'Bu öğrenci için henüz not girişi yapılmamış',
        Icons.grade_outlined,
      );
    }

    return Column(
      children: [
        _buildTermSelector(), // Dönem seçimi dropdown'u

        // 🎯 Not Analizini Görüntüle Butonu
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.bar_chart),
            label: const Text('Not Analizini Görüntüle'),
            onPressed:
                _showGradesAnalysisPopup, // Analiz ekranını açan fonksiyon
          ),
        ),

        Expanded(
          child: Scrollbar(
            controller: horizontalScrollController,
            thumbVisibility: true,
            thickness: 10,
            radius: const Radius.circular(8),
            child: SingleChildScrollView(
              controller: horizontalScrollController,
              scrollDirection: Axis.horizontal,
              child: Scrollbar(
                controller: verticalScrollController,
                thumbVisibility: true,
                thickness: 10,
                radius: const Radius.circular(8),
                child: SingleChildScrollView(
                  controller: verticalScrollController,
                  scrollDirection: Axis.vertical,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 1000, // Min genişlik artırıldı
                      maxWidth: double.infinity,
                    ),
                    child: grades.isNotEmpty
                        ? DataTable(
                            headingRowColor:
                                MaterialStateProperty.all(Colors.grey[200]),
                            columnSpacing: 24,
                            border: TableBorder.all(
                                color: Colors.grey.shade300, width: 1),
                            columns: const [
                              DataColumn(
                                  label: Text('Ders Adı',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('1. Yazılı')),
                              DataColumn(label: Text('2. Yazılı')),
                              DataColumn(label: Text('3. Yazılı')),
                              DataColumn(label: Text('4. Yazılı')),
                              DataColumn(label: Text('Ders İçi Performans 1')),
                              DataColumn(label: Text('Ders İçi Performans 2')),
                              DataColumn(label: Text('Proje 1')),
                              DataColumn(label: Text('Proje 2')),
                              DataColumn(label: Text('Dönem Puanı')),
                            ],
                            rows: _groupedGradesByCourse().entries.map((entry) {
                              String courseName = entry.key;
                              List<Map<String, dynamic>> courseGrades =
                                  entry.value;

                              return DataRow(
                                cells: [
                                  DataCell(Text(courseName)),
                                  _buildGradeCell(courseGrades, 'sinav1'),
                                  _buildGradeCell(courseGrades, 'sinav2'),
                                  _buildGradeCell(courseGrades, 'sinav3'),
                                  _buildGradeCell(courseGrades, 'sinav4'),
                                  _buildGradeCell(
                                      courseGrades, 'ders_etkinlikleri1'),
                                  _buildGradeCell(
                                      courseGrades, 'ders_etkinlikleri2'),
                                  _buildGradeCell(courseGrades, 'proje1'),
                                  _buildGradeCell(courseGrades, 'proje2'),
                                  _buildGradeCell(courseGrades, 'donem_puani'),
                                ],
                              );
                            }).toList(),
                          )
                        : const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                "Bu dönem için not bulunamadı",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black54),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKDSTab() {
    if (selectedStudent == null) {
      return _buildEmptyStateWidget(
        'Öğrenci seçilmedi',
        'Lütfen sol menüden bir öğrenci seçin',
        Icons.person_outline,
      );
    }

    if (!_isKDSLoaded) {
      return _buildLoadingWrapper(_isKDSLoaded, Container());
    }

    if (kdsScores.isEmpty) {
      return _buildEmptyStateWidget(
        'KDS kaydı bulunamadı',
        'Bu öğrenci henüz hiçbir KDS sınavına girmemiş',
        Icons.assignment_outlined,
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Başlık ve Analiz Butonu
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.indigo,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'KDS Listesi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showKDSAnalysis,
                  icon: const Icon(Icons.analytics, color: Colors.indigo),
                  label: const Text(
                    'KDS Analizini Görüntüle',
                    style: TextStyle(color: Colors.indigo),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tablo başlıkları
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.grey[100],
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      'KDS Adı',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Doğru',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Yanlış',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Boş',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Puan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(width: 16),
              ],
            ),
          ),
          // Tablo içeriği
          Expanded(
            child: ListView.builder(
              itemCount: kdsScores.length,
              itemBuilder: (context, index) {
                final kds = kdsScores[index];
                final bool isEven = index.isEven;

                return Container(
                  color: isEven ? Colors.grey[50] : Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(kds['kds']?['kds_adi'] ?? ''),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Center(
                          child: Text(kds['dogru']?.toString() ?? '0'),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(kds['yanlis']?.toString() ?? '0'),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(kds['bos']?.toString() ?? '0'),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              kds['puan']?.toString() ?? '0',
                              style: TextStyle(
                                color: Colors.indigo[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDenemeTab() {
    if (selectedStudent == null) {
      return _buildEmptyStateWidget(
        'Öğrenci seçilmedi',
        'Lütfen sol menüden bir öğrenci seçin',
        Icons.person_outline,
      );
    }

    if (denemeler.isEmpty) {
      return _buildEmptyStateWidget(
        'Deneme kaydı bulunamadı',
        'Bu öğrenci henüz hiçbir deneme sınavına girmemiş',
        Icons.assignment_outlined,
      );
    }
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Başlık ve Analiz Butonu
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.orangeAccent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Deneme Listesi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showDenemeAnalysis,
                  icon: const Icon(Icons.analytics, color: Colors.orangeAccent),
                  label: const Text(
                    'Deneme Analizini Görüntüle',
                    style: TextStyle(color: Colors.orangeAccent),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tablo başlıkları
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.grey[100],
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      'Deneme Adı',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Doğru',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Yanlış',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Boş',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Puan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(width: 16),
              ],
            ),
          ),
          // Tablo içeriği
          Expanded(
            child: ListView.builder(
              itemCount: denemeler.length,
              itemBuilder: (context, index) {
                final deneme = denemeler[index];
                final bool isEven = index.isEven;

                return Container(
                  color: isEven ? Colors.grey[50] : Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            deneme['deneme_sinavi_adi'] ??
                                deneme['denemeSinavi']?['deneme_sinavi_adi'] ??
                                'Bilinmeyen Deneme',
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Center(
                          child: Text(deneme['dogru']?.toString() ?? '0'),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(deneme['yanlis']?.toString() ?? '0'),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(deneme['bos']?.toString() ?? '0'),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              deneme['puan']?.toString() ?? '0',
                              style: TextStyle(
                                color: Colors.orangeAccent[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOkulDenemesiTab() {
    if (selectedStudent == null) {
      return _buildEmptyStateWidget(
        'Öğrenci seçilmedi',
        'Lütfen sol menüden bir öğrenci seçin',
        Icons.person_outline,
      );
    }

    if (!_isOkulDenemeLoaded) {
      return _buildLoadingWrapper(_isOkulDenemeLoaded, Container());
    }

    if (okulDenemeler.isEmpty) {
      return _buildEmptyStateWidget(
        'Okul Denemesi kaydı bulunamadı',
        'Bu öğrenci henüz hiçbir KDS sınavına girmemiş',
        Icons.assignment_outlined,
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Başlık ve Analiz Butonu
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.purpleAccent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Okul Denemeleri',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showOkulDenemeAnalysis,
                  icon: const Icon(Icons.analytics, color: Colors.purpleAccent),
                  label: const Text(
                    'Deneme Analizini Görüntüle',
                    style: TextStyle(color: Colors.purpleAccent),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Tablo başlıkları
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.grey[100],
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Text(
                      'Deneme Adı',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Center(
                    child: Text(
                      'Doğru',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Yanlış',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'Net',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(width: 16),
              ],
            ),
          ),
          // Tablo içeriği
          Expanded(
            child: ListView.builder(
              itemCount: okulDenemeler.length,
              itemBuilder: (context, index) {
                final deneme = okulDenemeler[index];
                final bool isEven = index.isEven;

                return Container(
                  color: isEven ? Colors.grey[50] : Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            deneme['denemeSinavi']['sinav_adi'] ??
                                'Bilinmeyen Deneme',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Center(
                          child:
                              Text(deneme['dogru_sayisi']?.toString() ?? '0'),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child:
                              Text(deneme['yanlis_sayisi']?.toString() ?? '0'),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              deneme['net']?.toString() ?? '0',
                              style: TextStyle(
                                color: Colors.purpleAccent[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showKDSAnalysis() async {
    if (selectedClass == null || selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sınıf ve öğrenci seçilmeden analiz görüntülenemez'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Ensure `selectedClassId` is an integer
      if (selectedClassId == null) {
        final classIdString =
            await classService.getClassIdByName(selectedClass!);
        selectedClassId = int.tryParse(classIdString.toString()) ?? 0;
      }

      final studentId = selectedStudent!.id;

      if (studentId == 0 || selectedClassId == 0) {
        throw Exception("Geçersiz öğrenci veya sınıf ID'si");
      }

      // Fetch KDS data
      final List<Map<String, dynamic>> classAverages =
          await studentKDSApiService.getClassKDSAverages(
        selectedClassId!,
        studentId,
      );

      if (classAverages == null || classAverages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('KDS verisi bulunamadı'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // **Diyalog açılırken kontrol et**
      showDialog(
        context: context,
        builder: (context) => Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 1200,
            height: 1000,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'KDS Analizi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: KDSAnalysisChart(
                      kdsScores: List<Map<String, dynamic>>.from(kdsScores),
                      classAverages: classAverages,
                      participationDetails: kdsParticipationDetails),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Kapat',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      print('KDS Analiz Hatası: $error'); // Debug için
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analiz yüklenirken bir hata oluştu: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDenemeAnalysis() async {
    if (selectedClass == null || selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sınıf ve öğrenci seçilmeden analiz görüntülenemez'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Ensure `selectedClassId` is an integer
      if (selectedClassId == null) {
        final classIdString =
            await classService.getClassIdByName(selectedClass!);
        selectedClassId = int.tryParse(classIdString.toString()) ?? 0;
      }

      // Convert `selectedStudent` to int safely
      final studentId = selectedStudent!.id;

      if (studentId == 0 || selectedClassId == 0) {
        throw Exception("Geçersiz öğrenci veya sınıf ID'si");
      }

      // Fetch KDS data
      final ClassDenemeAverages classAverages =
          await ogrenciDenemeleriApiService.getClassDenemeAverages(
        selectedClassId!,
        studentId,
      );

      if (classAverages == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deneme verisi bulunamadı'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // **Diyalog açılırken kontrol et**
      showDialog(
        context: context,
        builder: (context) => Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 1200,
            height: 1000,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Deneme Analizi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: DenemeAnalysischart(
                    denemeler: List<Map<String, dynamic>>.from(denemeler),
                    classAverages: classAverages,
                    participationDetails: denemeParticipationDetails,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Kapat',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      print('Deneme Analiz Hatası: $error'); // Debug için
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analiz yüklenirken bir hata oluştu: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showOkulDenemeAnalysis() async {
    if (selectedClass == null || selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sınıf ve öğrenci seçilmeden analiz görüntülenemez'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      if (selectedClassId == null) {
        final classIdString =
            await classService.getClassIdByName(selectedClass!);
        selectedClassId = int.tryParse(classIdString.toString()) ?? 0;
      }

      final studentId = selectedStudent!.id;

      final data =
          await ogrenciOkulDenemeleriApiService.getClassOkulDenemeAverages(
        selectedClassId!,
        studentId,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => Dialog(
          insetPadding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 1200,
            height: 1000,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Okul Denemeleri Analizi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: OkulDenemeleriAnalysisChart(
                    denemeler:
                        List<Map<String, dynamic>>.from(data['denemeler']),
                    statistics: data['statistics'],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Kapat',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (error) {
      print('Okul Deneme Analiz Hatası: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analiz yüklenirken bir hata oluştu: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showGradesAnalysisPopup() async {
    if (selectedClass == null || selectedTerm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sınıf ve dönem seçilmelidir")),
      );
      return;
    }

    try {
      selectedClassId = await classService.getClassIdByName(selectedClass!);

      final response = await gradesService.getClassGradesByClassId(
          selectedClassId!, int.parse(selectedTerm!.split('.').first));

      print("📌 API'den gelen yanıt: $response"); // Debug için

      // 🔥 API yanıtını düzenle
      if (response is Map<String, dynamic> &&
          response.dersler.containsKey('dersler')) {
        // `dersler` nesnesini listeye çevir
        final List<Map<String, dynamic>> formattedGrades = [];

        response.dersler.forEach((dersAdi, dersBilgisi) {
          formattedGrades.add({
            "ders_adi": dersBilgisi.dersAdi,
            "sinif_ortalama": dersBilgisi.sinifOrtalama,
            "ogrenciler": dersBilgisi.ogrenciler
          });
        });

        print("✅ Düzenlenmiş Not Verisi: $formattedGrades"); // Debug

        // **Diyalog açılırken bu veriyi kullan**
        showDialog(
          context: context,
          builder: (context) => GradesAnalysisPopup(
            sinifId: selectedClassId!,
            donem: int.parse(selectedTerm!.split('.').first),
            grades: formattedGrades,
            // 🎯 Güncellenmiş veri
          ),
        );
      } else {
        print("⛔ Beklenmeyen veri formatı: $response");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veri formatı hatalı!")),
        );
      }
    } catch (error) {
      print("⛔ Hata oluştu: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Not verisi yüklenirken hata: $error")),
      );
    }
  }

  DataCell _buildGradeCell(
      List<Map<String, dynamic>> gradesList, String field) {
    return DataCell(
      Center(
        child: Text(
          gradesList.isNotEmpty
              ? (gradesList.first[field]?.toString() ?? '-')
              : '-',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildTermSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DropdownButtonFormField<int>(
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        value: int.tryParse(selectedTerm!.split(" ").first), // '1. Dönem' -> 1
        hint: const Text('Dönem Seçiniz'),
        items: [
          DropdownMenuItem(value: 1, child: Text("1. Dönem")),
          DropdownMenuItem(value: 2, child: Text("2. Dönem")),
        ],
        onChanged: (int? newValue) {
          if (newValue != null) {
            setState(() {
              selectedTerm = "$newValue. Dönem"; // Yeni değeri güncelle
              _loadStudentGradesBySemester(selectedStudent!.id, newValue);
            });
          }
        },
      ),
    );
  }

  // Tarih formatı yardımcı fonksiyonu
  String _formatDate(String? dateStr) {
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
      return 'Geçersiz tarih';
    }
  }

  // Boş durum widget'ı
  Widget _buildEmptyStateWidget(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          if (title.contains('girmemiş') || title.contains('girilmemiş'))
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Veriler düzenli olarak güncellenmektedir',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
