import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:ogrenci_takip_sistemi/api.dart/daily_tracking_api.dart';
import 'package:ogrenci_takip_sistemi/pdf_report_button.dart';
import 'image_cache_manager.dart';
import 'scrollable_table_widget.dart';
import 'package:ogrenci_takip_sistemi/models/daily_tracking_model.dart';

// Veri model sınıfları
class Student {
  final int id;
  final String name;
  final String studentNumber; // Öğrenci numarası eklendi

  Student(
      {required this.id,
      required this.name,
      this.studentNumber = '' // Her zaman bir string değeri olsun
      });

  factory Student.fromJson(Map<String, dynamic> json) {
    String name;
    if (json.containsKey('ad') && json.containsKey('soyad')) {
      name = "${json['ad'] ?? ''} ${json['soyad'] ?? ''}";
    } else if (json.containsKey('ad_soyad')) {
      name = json['ad_soyad'] ?? '';
    } else {
      name = "Öğrenci #${json['id']}";
    }

    return Student(
      id: json['id'],
      name: name,
      studentNumber: json['ogrenci_no']?.toString() ??
          '', // null kontrolü ekleyin ve toString() kullanın
    );
  }
}

class ClassInfo {
  final int id;
  final String name;

  ClassInfo({required this.id, required this.name});

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      id: json['id'],
      name: json['sinif_adi'] ?? 'Bilinmeyen Sınıf',
    );
  }
}

// Ana sınıf
class DailyTrackingScreen extends StatefulWidget {
  const DailyTrackingScreen({super.key});

  @override
  _DailyTrackingScreenState createState() => _DailyTrackingScreenState();
}

class _DailyTrackingScreenState extends State<DailyTrackingScreen> {
  // API service for data handling
  final apiBaseUrl = 'http://localhost:3000';

  // Renk sabitleri
  final Color weekdayHeaderColor = Colors.blue.shade100;
  final Color weekendHeaderColor = Colors.amber.shade100;
  final Color weekdayBgColor = Colors.white;
  final Color weekendBgColor = Colors.grey.shade200;
  final Color dataEntryWeekdayColor = Colors.yellow.shade100;
  final Color dataEntryWeekendColor = Colors.orange.shade100;
  final Color weeklyTotalColor = Colors.green.shade200;
  final Color monthlyTotalColor = Colors.purple.shade300;

  // Add these constants
  final double studentColWidth = 200.0;
  final double courseColWidth = 120.0;
  final double dayColWidth = 40.0;
  final double totalColWidth = 60.0;
  final double weeklyTotalWidth = 70.0;

  // Month and year selection
  DateTime selectedMonth = DateTime.now();
  final Map<String, Timer> _debounceTimers = {};

  // Gün adı kısaltmasını getiren yardımcı fonksiyon
  String _getDayAbbreviation(int weekday) {
    // Türkçe gün kısaltmaları 1=Pazartesi, 7=Pazar
    const Map<int, String> abbrevs = {
      1: "Pt", // Pazartesi
      2: "Sa", // Salı
      3: "Ça", // Çarşamba
      4: "Pe", // Perşembe
      5: "Cu", // Cuma
      6: "Ct", // Cumartesi
      7: "Pa", // Pazar
    };

    return abbrevs[weekday] ?? "?";
  }

  // Students data
  List<Student> students = [];

  List<DailyTracking> allTrackingData = [];

  // Track loading state
  bool isLoading = true;
  String? errorMessage;

  // To hold daily tracking data - optimize edilmiş veri yapısı
  Map<int, Map<String, Map<EnumCourse, int>>> trackingData = {};

  // Haftalık toplam verileri için
  Map<int, Map<int, Map<EnumCourse, int>>> weeklyData = {};

  // Current class (sınıf) id
  int? currentClassId;
  List<ClassInfo> classes = [];

  // Günleri önbelleğe al - her seferinde yeniden hesaplama
  late List<DateTime> _daysInMonth;

  // Her öğrenci için gösterilen/gizlenen kursları izle
  Map<int, bool> _expandedStudents = {};

  // Scroll controller
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _updateDaysInMonth();
    _testCourseMappings(); // Debugging için eklendi
    _loadData();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _updateDaysInMonth() {
    _daysInMonth = _getDaysInMonth();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Load classes first
      await _loadClasses();
      if (!mounted) return;

      // Then load students for the current class
      if (currentClassId != null) {
        await _loadStudents();
        if (!mounted) return;

        // Finally load tracking data for the selected month
        await _loadTrackingData();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Veri yüklenirken bir hata oluştu: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadClasses() async {
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/class/dropdown'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        final loadedClasses = data.map((c) => ClassInfo.fromJson(c)).toList();

        if (!mounted) return;
        setState(() {
          classes = loadedClasses;
          if (classes.isNotEmpty) {
            if (currentClassId == null ||
                !classes.any((c) => c.id == currentClassId)) {
              currentClassId = classes[0].id;
            }
          } else {
            currentClassId = null;
          }
        });
      } else {
        throw Exception('Failed to load classes');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        classes = [];
        currentClassId = null;
      });
      throw Exception('Error loading classes: $e');
    }
  }

  Future<void> _loadStudents() async {
    try {
      if (currentClassId == null) {
        setState(() {
          students = [];
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$apiBaseUrl/student/class/$currentClassId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        final loadedStudents = data.map((s) => Student.fromJson(s)).toList();

        if (!mounted) return;
        setState(() {
          students = loadedStudents;

          // Yeni öğrenciler için expand durumunu ayarla
          for (final student in students) {
            _expandedStudents.putIfAbsent(student.id, () => true);
          }
        });
      } else {
        if (!mounted) return;
        setState(() {
          students = [];
        });
        throw Exception('Failed to load students');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        students = [];
      });
      throw Exception('Error loading students: $e');
    }
  }

  // Fix 2: Modify _loadTrackingData to properly handle date changes and persist data
  Future<void> _loadTrackingData() async {
    try {
      if (currentClassId == null || students.isEmpty) {
        setState(() {
          trackingData = {};
          weeklyData = {};
        });
        return;
      }

      // Geçerli ay için tarih aralığı
      final startDate = DateFormat('yyyy-MM-dd')
          .format(DateTime(selectedMonth.year, selectedMonth.month, 1));
      final lastDay =
          DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
      final endDate = DateFormat('yyyy-MM-dd')
          .format(DateTime(selectedMonth.year, selectedMonth.month, lastDay));

      // Ay başında ve sonunda yarım kalan haftaları da dahil etmek için genişletilmiş aralık
      DateTime extendedStartDate =
          DateTime(selectedMonth.year, selectedMonth.month, 1);
      // Ay başında pazartesiye kadar geriye git
      while (extendedStartDate.weekday != DateTime.monday) {
        extendedStartDate = extendedStartDate.subtract(const Duration(days: 1));
      }

      DateTime extendedEndDate =
          DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
      // Ay sonunda pazara kadar ileri git
      while (extendedEndDate.weekday != DateTime.sunday) {
        extendedEndDate = extendedEndDate.add(const Duration(days: 1));
      }

      final extStartDateStr =
          DateFormat('yyyy-MM-dd').format(extendedStartDate);
      final extEndDateStr = DateFormat('yyyy-MM-dd').format(extendedEndDate);

      print('📅 Normal aralık: $startDate - $endDate');
      print('🔄 Genişletilmiş aralık: $extStartDateStr - $extEndDateStr');

      // Veri yapıları
      Map<int, Map<String, Map<EnumCourse, int>>> newTrackingData = {};
      Map<int, Map<int, Map<EnumCourse, int>>> newWeeklyData = {};

      // DailyTrackingAPI'yi başlat
      final dailyTrackingAPI = DailyTrackingAPI(baseUrl: apiBaseUrl);

      // Tüm öğrenciler için veri yapılarını hazırla
      for (final student in students) {
        newTrackingData[student.id] = {};
        newWeeklyData[student.id] = {};

        // Aydaki tüm günler için sıfır değerli yapı hazırla
        for (final day in _daysInMonth) {
          final dateStr = DateFormat('yyyy-MM-dd').format(day);
          newTrackingData[student.id]![dateStr] = {};

          // Tüm dersler için sıfır değeri ata
          for (final course in EnumCourse.values) {
            newTrackingData[student.id]![dateStr]![course] = 0;
          }

          // Hafta numarası hesapla - ISO standardında yıl hafta numarası
          final weekOfYear = _getWeekOfYear(day);

          // Hafta verisi yoksa oluştur
          newWeeklyData[student.id]![weekOfYear] ??= {};

          // Tüm dersler için hafta verisini başlat
          for (final course in EnumCourse.values) {
            newWeeklyData[student.id]![weekOfYear]![course] ??= 0;
          }
        }
      }

      // Önce normal ay verilerini al
      try {
        print('📥 Normal ay verilerini getiriyorum...');
        final normalData = await dailyTrackingAPI.getDailyTrackingByDateRange(
            startDate, endDate);
        print('✅ Normal veriler alındı: ${normalData.length} kayıt');
        allTrackingData.addAll(normalData);

        // Genişletilmiş aralık için ek veriler al (önceki/sonraki ay parçaları)
        print('📥 Genişletilmiş aralık verilerini getiriyorum...');
        final extendedData = await dailyTrackingAPI.getDailyTrackingByDateRange(
            extStartDateStr, extEndDateStr);
        print('✅ Genişletilmiş veriler alındı: ${extendedData.length} kayıt');

        // Verileri birleştir ama duplikasyon olmasın
        final Set<String> addedIds = {};
        for (final item in allTrackingData) {
          addedIds.add('${item.ogrenciId}-${item.date}-${item.course}');
        }

        // Sadece eksik olanları ekle
        for (final item in extendedData) {
          final itemId = '${item.ogrenciId}-${item.date}-${item.course}';
          if (!addedIds.contains(itemId)) {
            allTrackingData.add(item);
          }
        }

        print('🔢 Toplam işlenecek kayıt sayısı: ${allTrackingData.length}');
      } catch (e) {
        print('❌ Veri getirme hatası: $e');
        allTrackingData = [];
      }

      // Verileri işle
      int processedCount = 0;
      for (final tracking in allTrackingData) {
        try {
          final studentId = tracking.ogrenciId;

          // Check if date is null or invalid
          if (tracking.date == null) {
            print('❗ Skipping record with null date for student $studentId');
            continue;
          }

          final dateStr = tracking.date;
          DateTime? parsedDate;

          try {
            parsedDate = dateStr;
          } catch (e) {
            print('❗ Invalid date format for $dateStr: $e');
            continue; // Skip this record
          }

          final course = tracking.course;
          final questionCount = tracking.solvedQuestions ?? 0;

          // This student is not in our list, skip
          if (!newTrackingData.containsKey(studentId)) continue;

          try {
            // Calculate week number
            final weekOfYear = _getWeekOfYear(parsedDate);

            // Only process daily data for the viewed month
            if (parsedDate.year == selectedMonth.year &&
                parsedDate.month == selectedMonth.month) {
              final formattedDateStr =
                  DateFormat('yyyy-MM-dd').format(parsedDate);
              if (newTrackingData[studentId]!.containsKey(formattedDateStr)) {
                newTrackingData[studentId]![formattedDateStr]![course] =
                    questionCount;
                processedCount++;
              }
            }

            // Process weekly data for the extended range
            if (!newWeeklyData[studentId]!.containsKey(weekOfYear)) {
              newWeeklyData[studentId]![weekOfYear] = {};
              for (final c in EnumCourse.values) {
                newWeeklyData[studentId]![weekOfYear]![c] = 0;
              }
            }

            // Add to weekly total - we group by week number
            // so weeks spanning month transitions are handled correctly
            newWeeklyData[studentId]![weekOfYear]![course] =
                ((newWeeklyData[studentId]![weekOfYear]![course] ?? 0) +
                        questionCount)
                    .toInt();
          } catch (e) {
            print('❌ Course conversion error: $e for "$course"');
            continue;
          }
        } catch (e) {
          print('❌ Record processing error: $e');
          continue;
        }
      }

      print('✅ İşlenen kayıt sayısı: $processedCount');

      if (!mounted) return;
      setState(() {
        trackingData = newTrackingData;
        weeklyData = newWeeklyData;
      });

      // Hafta numaralarını debug için göster
      _debugWeekNumbers();
    } catch (e) {
      print('❌ Veri yükleme ana hata: $e');
      if (!mounted) return;
      // Sessizce devam et
    }
  }

  // _saveTrackingData fonksiyonu için düzeltme
  Future<void> _saveTrackingData(
      int studentId, DateTime date, EnumCourse course, int? value) async {
    // Eğer değer null ise (silindi) 0 olarak kabul et
    final resolvedValue = value ?? 0;

    if (currentClassId == null) return;

    try {
      // API isteği
      final dailyTrackingAPI = DailyTrackingAPI(baseUrl: apiBaseUrl);
      await dailyTrackingAPI.upsertDailyTracking(DailyTracking(
        id: 0, // Yeni kayıt için 0 kullanıyoruz
        date: date,
        course: course,
        solvedQuestions: resolvedValue, // Null yerine 0 kullanıyoruz
        sinifId: currentClassId!,
        ogrenciId: studentId,
      ));

      // Lokal veriyi güncelle
      setState(() {
        final dateStr = DateFormat('yyyy-MM-dd').format(date);
        // Eski değeri sakla
        final oldValue = trackingData[studentId]?[dateStr]?[course] ?? 0;

        // Günlük veriyi güncelle
        if (trackingData[studentId] == null) {
          trackingData[studentId] = {};
        }

        if (trackingData[studentId]![dateStr] == null) {
          trackingData[studentId]![dateStr] = {};
        }

        trackingData[studentId]![dateStr]![course] =
            resolvedValue; // Null yerine 0 kullanıyoruz

        // Haftalık veriyi güncelle
        final weekOfYear = _getWeekOfYear(date);

        if (weeklyData[studentId] == null) {
          weeklyData[studentId] = {};
        }

        if (weeklyData[studentId]![weekOfYear] == null) {
          weeklyData[studentId]![weekOfYear] = {};
        }

        // Değer farkını hesapla ve ekle/çıkart
        final valueDiff = resolvedValue - oldValue;
        final currentWeekTotal =
            weeklyData[studentId]![weekOfYear]![course] ?? 0;
        weeklyData[studentId]![weekOfYear]![course] =
            currentWeekTotal + valueDiff;
      });

      // Başarı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veri başarıyla kaydedildi'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veri kaydedilirken bir hata oluştu: $e')),
      );
    }
  }

  void _changeMonth(int monthDelta) {
    setState(() {
      selectedMonth =
          DateTime(selectedMonth.year, selectedMonth.month + monthDelta, 1);
      _updateDaysInMonth();
    });
    _loadTrackingData();
  }

  void _changeClass(int classId) {
    setState(() {
      currentClassId = classId;
      students = []; // Öğrenci listesini temizle
      trackingData = {}; // Takip verilerini temizle
      weeklyData = {}; // Haftalık verileri temizle
      _expandedStudents = {}; // Genişletme durumlarını sıfırla
    });
    _loadData();
  }

  // Aydaki günleri getir
  List<DateTime> _getDaysInMonth() {
    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final lastDay = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    return List.generate(
      lastDay.day,
      (index) => DateTime(selectedMonth.year, selectedMonth.month, index + 1),
    );
  }

  // Fix 1: Better week calculation that respects calendar weeks
  int _getWeekOfMonth(DateTime date) {
    // Get first day of the month
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    // Get offset from Monday (1) to align with calendar weeks
    final weekOffset = (firstDayOfMonth.weekday - 1) % 7;
    // Calculate week number with offset
    return ((date.day + weekOffset - 1) ~/ 7) + 1;
  }

  // Aydaki hafta sayısını getir
  int _getWeeksInMonth() {
    // Ayın son günü
    final lastDay = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    // Ayın son gününün haftası
    return ((lastDay.day - 1) ~/ 7) + 1;
  }

  // Haftasonu kontrolü
  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  // Dersin görünen adını getir - Güncellendi
  String _getCourseDisplayName(EnumCourse course) {
    // Use the backend display values which include correct Turkish characters
    return _getBackendCourseString(course);
  }

  // Dersin rengini getir - Güncellendi
  Color _getCourseColor(EnumCourse course) {
    switch (course) {
      case EnumCourse.TURKCE:
        return Colors.red.shade50;
      case EnumCourse.MATEMATIK:
        return Colors.blue.shade50;
      case EnumCourse.FEN_BILIMLERI:
        return Colors.green.shade50;
      case EnumCourse.SOSYAL_BILGILER:
        return Colors.orange.shade50;
      case EnumCourse.INGILIZCE:
        return Colors.purple.shade50;
      case EnumCourse.DIKAB:
        return Colors.brown.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  // Frontend enum to backend string
  String _getBackendCourseString(EnumCourse course) {
    switch (course) {
      case EnumCourse.TURKCE:
        return 'TÜRKÇE';
      case EnumCourse.MATEMATIK:
        return 'MATEMATİK';
      case EnumCourse.FEN_BILIMLERI:
        return 'FEN BİLİMLERİ';
      case EnumCourse.SOSYAL_BILGILER:
        return 'SOSYAL BİLGİLER';
      case EnumCourse.INGILIZCE:
        return 'İNGİLİZCE';
      case EnumCourse.DIKAB:
        return 'DİKAB';
      default:
        throw Exception('Unknown course enum: $course');
    }
  }

  // Backend string to frontend enum
  EnumCourse _convertCourseString(String backendCourseStr) {
    print('🔄 Converting course: "$backendCourseStr"');

    switch (backendCourseStr) {
      case 'TÜRKÇE':
        return EnumCourse.TURKCE;
      case 'MATEMATİK':
        return EnumCourse.MATEMATIK;
      case 'FEN BİLİMLERİ':
        return EnumCourse.FEN_BILIMLERI;
      case 'SOSYAL BİLGİLER':
        return EnumCourse.SOSYAL_BILGILER;
      case 'İNGİLİZCE':
        return EnumCourse.INGILIZCE;
      case 'DİKAB':
        return EnumCourse.DIKAB;
      default:
        // Try to handle variations
        final normalized = backendCourseStr.toUpperCase();

        if (normalized.contains('TÜRK') || normalized.contains('TURK'))
          return EnumCourse.TURKCE;
        if (normalized.contains('MAT')) return EnumCourse.MATEMATIK;
        if (normalized.contains('FEN')) return EnumCourse.FEN_BILIMLERI;
        if (normalized.contains('SOSY')) return EnumCourse.SOSYAL_BILGILER;
        if (normalized.contains('İNG') || normalized.contains('ING'))
          return EnumCourse.INGILIZCE;
        if (normalized.contains('DİN') ||
            normalized.contains('DIN') ||
            normalized.contains('DİK') ||
            normalized.contains('DIK')) return EnumCourse.DIKAB;

        throw Exception('Unknown course: $backendCourseStr');
    }
  }

  // Test ve debug için
  void _testCourseMappings() {
    print('🧪 Testing course mappings:');

    // Test frontend enum to backend string
    for (final course in EnumCourse.values) {
      final backendString = _getBackendCourseString(course);
      print('- ${course.toString()} → "$backendString"');
    }

    // Test backend string to frontend enum
    final testStrings = [
      'TÜRKÇE',
      'MATEMATİK',
      'FEN BİLİMLERİ',
      'SOSYAL BİLGİLER',
      'İNGİLİZCE',
      'DİKAB'
    ];

    for (final str in testStrings) {
      try {
        final course = _convertCourseString(str);
        print('- "$str" → ${course.toString()}');
      } catch (e) {
        print('- "$str" → ERROR: $e');
      }
    }
  }

  // ISO Hafta Hesaplaması
  int _getWeekOfYear(DateTime date) {
    // ISO hafta numarasını hesapla (yıl içindeki hafta)
    // Bu, yıllar arası ve aylar arası tutarlı hafta numaraları sağlar
    int dayOfYear = int.parse(DateFormat('D').format(date));
    int woy = ((dayOfYear - date.weekday + 10) / 7).floor();

    // Yılın ilk haftasıysa ve önceki yılın son haftasına aitse kontrol et
    if (woy < 1) {
      // Önceki yılın son gününün hafta numarasını al
      DateTime prevYearLastDay = DateTime(date.year - 1, 12, 31);
      return _getWeekOfYear(prevYearLastDay);
    }
    // Yılın son haftasıysa ve sonraki yılın ilk haftasına aitse kontrol et
    else if (woy > 52) {
      // Yılın son günü perşembe veya sonrası mı?
      DateTime lastDay = DateTime(date.year, 12, 31);
      if (lastDay.weekday < 4) {
        return 1;
      }
    }
    return woy;
  }

  // İki tarihin aynı haftada olup olmadığını kontrol eder
  bool _isSameWeek(DateTime date1, DateTime date2) {
    // İki tarih aynı ISO haftasında mı? (pazartesi-pazar arası)
    return _getWeekOfYear(date1) == _getWeekOfYear(date2) &&
        date1.year == date2.year;
  }

  // Haftalık toplam hesaplama metodları
  int _calculateWeekTotalForStudent(int studentId, DateTime referenceDate) {
    final int weekNum = _getWeekOfYear(referenceDate);
    int total = 0;

    // Tüm hafta verilerinden toplam hesapla
    if (weeklyData[studentId]?[weekNum] != null) {
      weeklyData[studentId]![weekNum]!.forEach((course, value) {
        total += value;
      });
    }

    return total;
  }

  // Belirli bir ders için haftalık toplam
  int _calculateCourseWeekTotal(
      int studentId, DateTime referenceDate, EnumCourse course) {
    final int weekNum = _getWeekOfYear(referenceDate);
    return weeklyData[studentId]?[weekNum]?[course] ?? 0;
  }

  // Test ve hata ayıklama için hafta numaralarını görüntüle
  void _debugWeekNumbers() {
    print('\n🔍 Ay için hafta numaraları:');
    for (final day in _daysInMonth) {
      final weekNum = _getWeekOfYear(day);
      print('📅 ${DateFormat('yyyy-MM-dd (E)').format(day)} - Hafta: $weekNum');
    }

    // Ay geçişleri için
    final prevMonthLastDay =
        DateTime(selectedMonth.year, selectedMonth.month, 0);
    final nextMonthFirstDay =
        DateTime(selectedMonth.year, selectedMonth.month + 1, 1);

    print('\n🔄 Ay geçişleri:');
    print(
        '◀️ Önceki ayın son günü: ${DateFormat('yyyy-MM-dd (E)').format(prevMonthLastDay)} - Hafta: ${_getWeekOfYear(prevMonthLastDay)}');
    print(
        '▶️ Sonraki ayın ilk günü: ${DateFormat('yyyy-MM-dd (E)').format(nextMonthFirstDay)} - Hafta: ${_getWeekOfYear(nextMonthFirstDay)}');

    // Aynı haftada mı kontrol et
    if (_isSameWeek(prevMonthLastDay,
        DateTime(selectedMonth.year, selectedMonth.month, 1))) {
      print('🔄 Önceki ayın son günü ve bu ayın ilk günü AYNI haftada!');
    }

    final lastDayOfCurrentMonth =
        DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    if (_isSameWeek(lastDayOfCurrentMonth, nextMonthFirstDay)) {
      print('🔄 Bu ayın son günü ve sonraki ayın ilk günü AYNI haftada!');
    }
    print('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük Takip'),
        backgroundColor: Colors.blue,
        actions: [
          // PDF Rapor butonu
          if (currentClassId != null && !isLoading && students.isNotEmpty)
            PDFReportButton(
              classInfo: ClassInfo(
                  id: currentClassId!,
                  name:
                      classes.firstWhere((c) => c.id == currentClassId!).name),
              students: students,
              trackingData: trackingData,
              weeklyData: weeklyData,
              reportDate: selectedMonth,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Verileri Yenile',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : _buildTrackingContent(),
    );
  }

  Widget _buildTrackingContent() {
    return Column(
      children: [
        _buildHeaderControls(),
        const Divider(),
        Expanded(
          // Column içinde Expanded kullanılıyor
          child: _buildTrackingTable(),
        ),
      ],
    );
  }

  Widget _buildHeaderControls() {
    // Dropdown öğelerini hazırla
    final dropdownItems = <DropdownMenuItem<int>>[];

    for (final classItem in classes) {
      dropdownItems.add(DropdownMenuItem<int>(
        value: classItem.id,
        child: Text(classItem.name),
      ));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Sınıf seçim dropdown
          Expanded(
            flex: 3,
            child: dropdownItems.isEmpty
                ? const Text('Henüz sınıf bulunmamaktadır.')
                : DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Sınıf Seçin',
                      border: OutlineInputBorder(),
                    ),
                    value: currentClassId,
                    items: dropdownItems,
                    onChanged: (value) {
                      if (value != null) {
                        _changeClass(value);
                      }
                    },
                  ),
          ),
          const SizedBox(width: 16),
          // Ay navigasyonu
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            DateFormat('MMMM yyyy', 'tr_TR').format(selectedMonth),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  // Replace your _buildTrackingTable method with this implementation
  Widget _buildTrackingTable() {
    if (students.isEmpty) {
      return const Center(child: Text('Bu sınıfta öğrenci bulunmamaktadır.'));
    }

    // Calculate table width
    double tableWidth = studentColWidth + courseColWidth + totalColWidth;
    for (int i = 0; i < _daysInMonth.length; i++) {
      tableWidth += dayColWidth;
      if (_daysInMonth[i].weekday == DateTime.sunday ||
          i == _daysInMonth.length - 1) {
        tableWidth += weeklyTotalWidth;
      }
    }

    // Create header row
    final headerRow = Row(
      children: [
        // Student header
        Container(
          width: studentColWidth,
          padding: const EdgeInsets.all(8),
          color: Colors.blue.shade100,
          alignment: Alignment.centerLeft,
          child: const Text(
            'Öğrenci',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        // Course header
        Container(
          width: courseColWidth,
          padding: const EdgeInsets.all(8),
          color: Colors.blue.shade100,
          alignment: Alignment.center,
          child: const Text(
            'Ders',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        // Day headers and weekly totals
        ..._buildHeaderCells().map((cell) => Container(
              color: Colors.blue.shade100,
              child: cell,
            )),

        // Monthly total header
        Container(
          width: 100,
          padding: const EdgeInsets.all(8),
          color: const Color.fromARGB(255, 238, 102, 243),
          alignment: Alignment.center,
          child: const Text(
            'TOPLAM',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );

    // Use the ScrollableTable widget
    return ScrollableTable(
      header: headerRow,
      contentWidth: tableWidth + 50, // Add some padding
      itemCount: students.length,
      itemBuilder: (context, index) {
        return _buildStudentSection(students[index], _getWeeksInMonth());
      },
    );
  }

  // Fix 4: Modify the header cells building to use correct week calculation
  List<Widget> _buildHeaderCells() {
    List<Widget> cells = [];

    // Hafta tanımlayıcılarını takip et
    Set<String> addedWeeks = {};

    // Yıl-hafta formatında benzersiz tanımlayıcı
    String _weekIdentifier(DateTime date) =>
        '${date.year}-${_getWeekOfYear(date)}';

    for (int i = 0; i < _daysInMonth.length; i++) {
      final day = _daysInMonth[i];
      final isWeekend = _isWeekend(day);

      // Türkçe gün kısaltması (Pt, Sa, Ça, vb.)
      final String dayAbbr = _getDayAbbreviation(day.weekday);

      // Normal gün hücresi - günü ve gün adının kısaltmasını göster
      cells.add(Container(
        width: dayColWidth,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        decoration: BoxDecoration(
          color: isWeekend ? weekendHeaderColor : weekdayHeaderColor,
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.day.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isWeekend ? Colors.brown.shade800 : Colors.blue.shade800,
              ),
            ),
            Text(
              dayAbbr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                color: isWeekend ? Colors.brown.shade800 : Colors.blue.shade800,
              ),
            ),
          ],
        ),
      ));

      // Hafta toplamı kontrolü
      bool needsWeekTotal = false;
      String weekId = _weekIdentifier(day);

      // Son güne geldik mi?
      bool isLastDay = i == _daysInMonth.length - 1;

      // Pazar günü mü?
      bool isWeekEnd = day.weekday == DateTime.sunday;

      // Yarın farklı bir haftaya mı geçiyor?
      bool isNewWeekTomorrow = false;
      if (!isLastDay) {
        isNewWeekTomorrow = !_isSameWeek(day, _daysInMonth[i + 1]);
      }

      // Hafta toplamını gösterme kararı:
      // 1. Eğer bugün pazar (hafta sonu) ise göster
      // 2. Eğer ayın son günüyse ve haftanın son günü ise göster
      // 3. Eğer yarın yeni bir hafta başlıyorsa göster
      if ((isWeekEnd ||
              (isLastDay && day.weekday == DateTime.sunday) ||
              isNewWeekTomorrow) &&
          !addedWeeks.contains(weekId)) {
        needsWeekTotal = true;
        addedWeeks.add(weekId);
      }

      // Ayın sonundayız ve hafta tamamlanmamış - hafta toplamı gösterme
      if (isLastDay && !isWeekEnd && !addedWeeks.contains(weekId)) {
        // Bu durumda hafta toplamı GÖSTERMİYORUZ çünkü hafta tamamlanmamış
      } else if (needsWeekTotal) {
        // Hafta toplamını göster
        cells.add(Container(
          width: weeklyTotalWidth,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: weeklyTotalColor,
            border: Border.all(color: Colors.green.shade400, width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            'Hafta ${_getWeekOfYear(day)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ));
      }
    }

    return cells;
  }

  // Öğrenci bölümü için düzeltilmiş kod
  Widget _buildStudentSection(Student student, int weeks) {
    final isExpanded = _expandedStudents[student.id] ?? true;

    // Sabit genişlikler
    const double imageWidth = 200.0; // Daha küçük resim genişliği

    // Ders listesi ve toplam satır için yükseklik hesapla
    final int rowCount =
        EnumCourse.values.length + 1; // +1 for GÜNLÜK TOPLAM row
    final double rowHeight = 40.0; // Her satır için yükseklik
    final double sectionHeight = rowCount * rowHeight; // Toplam yükseklik

    // Öğrenci numarası mı var?
    final hasStudentNumber =
        student.studentNumber != null && student.studentNumber.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        children: [
          // Öğrenci başlığı - tıklanabilir
          InkWell(
            onTap: () {
              setState(() {
                _expandedStudents[student.id] = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          // Öğrenci numarası varsa, önce numarayı göster
                          if (hasStudentNumber)
                            TextSpan(
                              text: '${student.studentNumber} - ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          // Ardından öğrenci adını göster
                          TextSpan(
                            text: student.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue.shade800,
                  ),
                ],
              ),
            ),
          ),

          // Öğrenci detayları - genişletilebilir
          if (isExpanded)
            Container(
              // Sabit bir yükseklik belirleme - tüm kartın boyutu sabit olacak
              height: sectionHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Öğrenci resmi - daha küçük ve sınırlandırılmış
                  Container(
                    width: imageWidth,
                    height: sectionHeight,
                    padding: const EdgeInsets.all(16), // Daha fazla padding
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: StudentImageWidget(
                        studentId: student.id,
                        width: imageWidth - 32, // padding için ayarla
                        height: sectionHeight - 32, // padding için ayarla
                        shape: StudentImageShape.rectangle,
                      ),
                    ),
                  ),

                  // Sağ taraftaki diğer kodlar...
                  Expanded(
                    child: Column(
                      children: [
                        // GÜNLÜK TOPLAM satırı
                        Container(
                          height: rowHeight,
                          color: Colors.blue.shade50,
                          child: Row(
                            children: [
                              // GÜNLÜK TOPLAM etiketi
                              Container(
                                width: courseColWidth,
                                height: rowHeight,
                                padding: const EdgeInsets.all(8),
                                alignment: Alignment.center,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: const Text(
                                    'GÜNLÜK TOPLAM',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12),
                                  ),
                                ),
                              ),

                              // Günlük toplam değerleri
                              ..._buildDailyTotalCells(student),

                              // Toplam sütunu
                              Container(
                                width: totalColWidth,
                                height: rowHeight,
                                alignment: Alignment.center,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 248, 181, 251),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Text(
                                    _calculateStudentMonthlyTotal(student.id)
                                        .toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Ders satırları
                        ...EnumCourse.values.map((course) => Container(
                              height: rowHeight,
                              child: Row(
                                children: [
                                  // Ders adı
                                  Container(
                                    width: courseColWidth,
                                    height: rowHeight,
                                    padding: const EdgeInsets.all(8),
                                    alignment: Alignment.center,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _getCourseColor(course),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      child: Text(
                                        _getCourseDisplayName(course),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                      ),
                                    ),
                                  ),

                                  // Ders günlük değerleri
                                  ..._buildCourseDailyCells(student, course),

                                  // Ders toplam
                                  Container(
                                    width: totalColWidth,
                                    height: rowHeight,
                                    alignment: Alignment.center,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _getCourseColor(course),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      child: Text(
                                        _calculateCourseTotalForStudent(
                                                student.id, course)
                                            .toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Fix 5: Update daily total cells to use correct week calculation
  List<Widget> _buildDailyTotalCells(Student student) {
    List<Widget> cells = [];

    // Hafta tanımlayıcılarını takip et
    Set<String> addedWeeks = {};

    // Yıl-hafta formatında benzersiz tanımlayıcı
    String _weekIdentifier(DateTime date) =>
        '${date.year}-${_getWeekOfYear(date)}';

    for (int i = 0; i < _daysInMonth.length; i++) {
      final day = _daysInMonth[i];
      final isWeekend = _isWeekend(day);
      final dateStr = DateFormat('yyyy-MM-dd').format(day);

      // Bu gün için toplam hesapla
      int dayTotal = 0;
      if (trackingData[student.id]?[dateStr] != null) {
        trackingData[student.id]![dateStr]!.forEach((course, count) {
          dayTotal += count;
        });
      }

      // Günlük toplam hücresi
      cells.add(Container(
        width: dayColWidth,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isWeekend
              ? weekendBgColor
              : dayTotal > 0
                  ? dataEntryWeekdayColor
                  : weekdayBgColor,
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
        ),
        child: Text(
          dayTotal.toString(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: dayTotal > 0 ? Colors.black : Colors.grey.shade600,
          ),
        ),
      ));

      // Hafta toplamı kontrolü
      bool needsWeekTotal = false;
      String weekId = _weekIdentifier(day);

      // Son güne geldik mi?
      bool isLastDay = i == _daysInMonth.length - 1;

      // Pazar günü mü?
      bool isWeekEnd = day.weekday == DateTime.sunday;

      // Yarın farklı bir haftaya mı geçiyor?
      bool isNewWeekTomorrow = false;
      if (!isLastDay) {
        isNewWeekTomorrow = !_isSameWeek(day, _daysInMonth[i + 1]);
      }

      // Hafta toplamını gösterme kararı
      if ((isWeekEnd ||
              (isLastDay && day.weekday == DateTime.sunday) ||
              isNewWeekTomorrow) &&
          !addedWeeks.contains(weekId)) {
        needsWeekTotal = true;
        addedWeeks.add(weekId);
      }

      // Ayın sonundayız ve hafta tamamlanmamış - hafta toplamı gösterme
      if (isLastDay && !isWeekEnd && !addedWeeks.contains(weekId)) {
        // Bu durumda hafta toplamı GÖSTERMİYORUZ
      } else if (needsWeekTotal) {
        // Bu hafta için toplam hesapla - ISO hafta numarasına göre
        int weekTotal = _calculateWeekTotalForStudent(student.id, day);

        cells.add(Container(
          width: weeklyTotalWidth,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: weeklyTotalColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.green.shade400, width: 1),
          ),
          child: Text(
            weekTotal.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: weekTotal > 0 ? Colors.black : Colors.grey.shade700,
            ),
          ),
        ));
      }
    }
    return cells;
  }

  // Fix 6: Similar update for course cells to use correct week calculation
  List<Widget> _buildCourseDailyCells(Student student, EnumCourse course) {
    List<Widget> cells = [];

    // Hafta tanımlayıcılarını takip et
    Set<String> addedWeeks = {};

    // Yıl-hafta formatında benzersiz tanımlayıcı
    String _weekIdentifier(DateTime date) =>
        '${date.year}-${_getWeekOfYear(date)}';

    for (int i = 0; i < _daysInMonth.length; i++) {
      final day = _daysInMonth[i];
      final isWeekend = _isWeekend(day);
      final dateStr = DateFormat('yyyy-MM-dd').format(day);
      final value = trackingData[student.id]?[dateStr]?[course] ?? 0;

      // Günlük değer hücresi
      cells.add(Container(
        width: dayColWidth,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isWeekend ? weekendBgColor : weekdayBgColor,
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
        ),
        child: TextField(
          controller:
              TextEditingController(text: value > 0 ? value.toString() : ''),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isWeekend ? Colors.brown.shade800 : Colors.black,
            fontWeight: value > 0 ? FontWeight.bold : FontWeight.normal,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            filled: value > 0,
            fillColor:
                isWeekend ? dataEntryWeekendColor : dataEntryWeekdayColor,
          ),
          onChanged: (newValue) {
            // Her hücre için benzersiz bir anahtar oluştur
            final key = '${student.id}-$dateStr-${course.toString()}';

            // Varsa önceki zamanlayıcıyı iptal et
            if (_debounceTimers.containsKey(key)) {
              _debounceTimers[key]?.cancel();
            }

            // Yeni bir zamanlayıcı oluştur (500ms gecikme)
            _debounceTimers[key] = Timer(const Duration(milliseconds: 500), () {
              final intValue =
                  newValue.isEmpty ? 0 : int.tryParse(newValue) ?? 0;
              _saveTrackingData(
                student.id,
                DateTime.parse(dateStr),
                course,
                intValue,
              );
              // İşlem tamamlandıktan sonra zamanlayıcıyı kaldır
              _debounceTimers.remove(key);
            });
          },
        ),
      ));

      // Hafta toplamı kontrolü
      bool needsWeekTotal = false;
      String weekId = _weekIdentifier(day);

      // Son güne geldik mi?
      bool isLastDay = i == _daysInMonth.length - 1;

      // Pazar günü mü?
      bool isWeekEnd = day.weekday == DateTime.sunday;

      // Yarın farklı bir haftaya mı geçiyor?
      bool isNewWeekTomorrow = false;
      if (!isLastDay) {
        isNewWeekTomorrow = !_isSameWeek(day, _daysInMonth[i + 1]);
      }

      // Hafta toplamını gösterme kararı
      if ((isWeekEnd ||
              (isLastDay && day.weekday == DateTime.sunday) ||
              isNewWeekTomorrow) &&
          !addedWeeks.contains(weekId)) {
        needsWeekTotal = true;
        addedWeeks.add(weekId);
      }

      // Ayın sonundayız ve hafta tamamlanmamış - hafta toplamı gösterme
      if (isLastDay && !isWeekEnd && !addedWeeks.contains(weekId)) {
        // Bu durumda hafta toplamı GÖSTERMİYORUZ
      } else if (needsWeekTotal) {
        // Bu hafta ve kurs için toplam hesapla
        int weekValue = _calculateCourseWeekTotal(student.id, day, course);

        cells.add(Container(
          width: weeklyTotalWidth,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: weekValue > 0
                ? _getCourseColor(course).withOpacity(0.7)
                : _getCourseColor(course).withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: weeklyTotalColor, width: 1),
          ),
          child: Text(
            weekValue.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: weekValue > 0 ? Colors.black : Colors.grey.shade700,
            ),
          ),
        ));
      }
    }

    return cells;
  }

  int _calculateStudentMonthlyTotal(int studentId) {
    int total = 0;
    trackingData[studentId]?.forEach((date, courses) {
      courses.forEach((course, count) {
        total += count;
      });
    });
    return total;
  }

  int _calculateCourseTotalForStudent(int studentId, EnumCourse course) {
    int total = 0;
    trackingData[studentId]?.forEach((date, courses) {
      total += courses[course] ?? 0;
    });
    return total;
  }
}
