import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:ogrenci_takip_sistemi/api.dart/daily_tracking_api.dart';
import 'package:ogrenci_takip_sistemi/pdf_report_button.dart';
import '../../image_cache_manager.dart';
import '../../scrollable_table_widget.dart';
import 'package:ogrenci_takip_sistemi/models/daily_tracking_model.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';
import 'package:ogrenci_takip_sistemi/blocs/daily_tracking/daily_tracking_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/daily_tracking/daily_tracking_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/daily_tracking/daily_tracking_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/daily_tracking/daily_tracking_repository.dart';

// ClassInfo sınıfı - PDF raporu için
class ClassInfo {
  final int id;
  final String name;

  ClassInfo({required this.id, required this.name});
}

// Ana sınıf - şimdi BLoC kullanıyor
class DailyTrackingScreen extends StatelessWidget {
  const DailyTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DailyTrackingBloc(
        repository: DailyTrackingRepository(baseUrl: 'http://localhost:3000'),
      )..add(LoadClasses()),
      child: const DailyTrackingView(),
    );
  }
}

class DailyTrackingView extends StatefulWidget {
  const DailyTrackingView({super.key});

  @override
  _DailyTrackingViewState createState() => _DailyTrackingViewState();
}

class _DailyTrackingViewState extends State<DailyTrackingView> {
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

  // Scroll controller
  final ScrollController _horizontalScrollController = ScrollController();

  // Debounce timers for text input
  final Map<String, Timer> _debounceTimers = {};

  // Performance optimization: Cache frequently used calculations
  final Map<String, int> _calculationCache = {};
  
  // Track which cell is currently being edited to show TextField only for that cell
  String? _editingCellKey;

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    // Cancel all debounce timers
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _calculationCache.clear();
    super.dispose();
  }

  // Performance optimization: Clear cache when state changes significantly
  void _clearCalculationCache() {
    _calculationCache.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük Takip'),
        backgroundColor: Colors.blue,
        actions: [
          BlocBuilder<DailyTrackingBloc, DailyTrackingState>(
            // Performance optimization: Only rebuild when necessary
            buildWhen: (previous, current) {
              return current is TrackingDataLoaded && 
                     (previous is! TrackingDataLoaded || 
                      previous.currentClassId != current.currentClassId ||
                      previous.students.length != current.students.length);
            },
            builder: (context, state) {
              if (state is TrackingDataLoaded && 
                  state.currentClassId != null && 
                  state.students.isNotEmpty) {
                final classInfo = state.classes
                    .firstWhere((c) => c.id == state.currentClassId!);
                return PDFReportButton(
                  classInfo: ClassInfo(
                    id: state.currentClassId!,
                    name: classInfo.sinifAdi,
                  ),
                  students: state.students,
                  trackingData: state.trackingData,
                  weeklyData: state.weeklyData,
                  reportDate: state.selectedMonth,
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Clear cache on refresh
              _clearCalculationCache();
              context.read<DailyTrackingBloc>().add(RefreshData());
            },
            tooltip: 'Verileri Yenile',
          ),
          // Performance monitoring indicator
          if (kDebugMode)
            IconButton(
              icon: Icon(
                Icons.memory,
                color: _calculationCache.length > 100 ? Colors.orange : Colors.green,
              ),
              onPressed: () {
                print('🎯 Performance Stats:');
                print('📊 Cache entries: ${_calculationCache.length}');
                print('⏱️ Active timers: ${_debounceTimers.length}');
                print('🎭 Editing cell: ${_editingCellKey ?? "None"}');
              },
              tooltip: 'Performance Info (${_calculationCache.length} cached)',
            ),
        ],
      ),
      body: BlocListener<DailyTrackingBloc, DailyTrackingState>(
        listener: (context, state) {
          if (state is DailyTrackingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is DailyTrackingOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                duration: const Duration(seconds: 1),
              ),
            );
          }
          // Clear cache when state changes
          _clearCalculationCache();
        },
        child: BlocBuilder<DailyTrackingBloc, DailyTrackingState>(
          // Performance optimization: Reduce unnecessary rebuilds
          buildWhen: (previous, current) {
            if (current is DailyTrackingLoading ||
                current is DailyTrackingError ||
                current is TrackingDataLoaded ||
                current is ClassesLoaded) {
              return true;
            }
            return false;
          },
          builder: (context, state) {
            if (state is DailyTrackingLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DailyTrackingError) {
              return Center(child: Text(state.message));
            } else if (state is TrackingDataLoaded) {
              return _buildTrackingContent(state);
            } else if (state is ClassesLoaded) {
              // Classes loaded but no class selected yet
              return _buildTrackingContent(TrackingDataLoaded(
                classes: state.classes,
                currentClassId: state.classes.isNotEmpty ? state.classes.first.id : null,
                students: const [],
                trackingData: const {},
                weeklyData: const {},
                selectedMonth: DateTime.now(),
                expandedStudents: const {},
              ));
            }
            return const Center(child: Text('Başlatılıyor...'));
          },
        ),
      ),
    );
  }

  Widget _buildTrackingContent(TrackingDataLoaded state) {
    return Column(
      children: [
        _buildHeaderControls(state),
        const Divider(),
        Expanded(
          child: _buildTrackingTable(state),
        ),
      ],
    );
  }

  Widget _buildHeaderControls(TrackingDataLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Sınıf seçim dropdown
          Expanded(
            flex: 3,
            child: state.classes.isEmpty
                ? const Text('Henüz sınıf bulunmamaktadır.')
                : DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Sınıf Seçin',
                      border: OutlineInputBorder(),
                    ),
                    value: state.currentClassId,
                    items: state.classes.map((classItem) {
                      return DropdownMenuItem<int>(
                        value: classItem.id,
                        child: Text(classItem.sinifAdi),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        context.read<DailyTrackingBloc>().add(SelectClass(value));
                      }
                    },
                  ),
          ),
          const SizedBox(width: 16),
          // Ay navigasyonu
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => context.read<DailyTrackingBloc>().add(const ChangeMonth(-1)),
          ),
          Text(
            DateFormat('MMMM yyyy', 'tr_TR').format(state.selectedMonth),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => context.read<DailyTrackingBloc>().add(const ChangeMonth(1)),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingTable(TrackingDataLoaded state) {
    if (state.students.isEmpty) {
      return const Center(child: Text('Bu sınıfta öğrenci bulunmamaktadır.'));
    }

    final daysInMonth = _getDaysInMonth(state.selectedMonth);

    // Calculate table width
    double tableWidth = studentColWidth + courseColWidth + totalColWidth;
    for (int i = 0; i < daysInMonth.length; i++) {
      tableWidth += dayColWidth;
      if (daysInMonth[i].weekday == DateTime.sunday ||
          i == daysInMonth.length - 1) {
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
        ..._buildHeaderCells(daysInMonth).map((cell) => Container(
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
      contentWidth: tableWidth + 50,
      itemCount: state.students.length,
      itemBuilder: (context, index) {
        return _buildStudentSection(state.students[index], state, daysInMonth);
      },
    );
  }

  // Gün adı kısaltmasını getiren yardımcı fonksiyon
  String _getDayAbbreviation(int weekday) {
    const Map<int, String> abbrevs = {
      1: "Pt", 2: "Sa", 3: "Ça", 4: "Pe", 5: "Cu", 6: "Ct", 7: "Pa",
    };
    return abbrevs[weekday] ?? "?";
  }

  // Aydaki günleri getir
  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    return List.generate(
      lastDay.day,
      (index) => DateTime(month.year, month.month, index + 1),
    );
  }

  // Header cells building with correct week calculation
  List<Widget> _buildHeaderCells(List<DateTime> daysInMonth) {
    List<Widget> cells = [];

    // Hafta tanımlayıcılarını takip et
    Set<String> addedWeeks = {};

    // Yıl-hafta formatında benzersiz tanımlayıcı
    String weekIdentifier(DateTime date) =>
        '${date.year}-${_getWeekOfYear(date)}';

    for (int i = 0; i < daysInMonth.length; i++) {
      final day = daysInMonth[i];
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
      String weekId = weekIdentifier(day);

      // Son güne geldik mi?
      bool isLastDay = i == daysInMonth.length - 1;

      // Pazar günü mü?
      bool isWeekEnd = day.weekday == DateTime.sunday;

      // Yarın farklı bir haftaya mı geçiyor?
      bool isNewWeekTomorrow = false;
      if (!isLastDay) {
        isNewWeekTomorrow = !_isSameWeek(day, daysInMonth[i + 1]);
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
    final lastDay = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
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

  // ISO Hafta Hesaplaması
  int _getWeekOfYear(DateTime date) {
    // ISO hafta numarasını hesapla (yıl içindeki hafta)
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
  int _calculateWeekTotalForStudent(int studentId, DateTime referenceDate, TrackingDataLoaded state) {
    return _getCachedWeekTotalForStudent(studentId, referenceDate, state);
  }

  int _calculateCourseWeekTotal(int studentId, DateTime referenceDate, EnumCourse course, TrackingDataLoaded state) {
    return _getCachedCourseWeekTotal(studentId, referenceDate, course, state);
  }

  // Test ve hata ayıklama için hafta numaralarını görüntüle
  void _debugWeekNumbers(List<DateTime> daysInMonth) {
    print('\n🔍 Ay için hafta numaraları:');
    for (final day in daysInMonth) {
      final weekNum = _getWeekOfYear(day);
      print('📅 ${DateFormat('yyyy-MM-dd (E)').format(day)} - Hafta: $weekNum');
    }

    // Ay geçişleri için
    final prevMonthLastDay =
        DateTime(DateTime.now().year, DateTime.now().month, 0);
    final nextMonthFirstDay =
        DateTime(DateTime.now().year, DateTime.now().month + 1, 1);

    print('\n🔄 Ay geçişleri:');
    print(
        '◀️ Önceki ayın son günü: ${DateFormat('yyyy-MM-dd (E)').format(prevMonthLastDay)} - Hafta: ${_getWeekOfYear(prevMonthLastDay)}');
    print(
        '▶️ Sonraki ayın ilk günü: ${DateFormat('yyyy-MM-dd (E)').format(nextMonthFirstDay)} - Hafta: ${_getWeekOfYear(nextMonthFirstDay)}');

    // Aynı haftada mı kontrol et
    if (_isSameWeek(prevMonthLastDay,
        DateTime(DateTime.now().year, DateTime.now().month, 1))) {
      print('🔄 Önceki ayın son günü ve bu ayın ilk günü AYNI haftada!');
    }

    final lastDayOfCurrentMonth =
        DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
    if (_isSameWeek(lastDayOfCurrentMonth, nextMonthFirstDay)) {
      print('🔄 Bu ayın son günü ve sonraki ayın ilk günü AYNI haftada!');
    }
    print('\n');
  }

  // Öğrenci bölümü için düzeltilmiş kod - Performance optimized
  Widget _buildStudentSection(Student student, TrackingDataLoaded state, List<DateTime> daysInMonth) {
    return BlocBuilder<DailyTrackingBloc, DailyTrackingState>(
      // Performance optimization: Only rebuild this student section when expansion state changes
      buildWhen: (previous, current) {
        if (current is! TrackingDataLoaded || previous is! TrackingDataLoaded) {
          return true;
        }
        
        // Only rebuild if this specific student's expansion state changed
        final currentExpanded = current.expandedStudents[student.id] ?? true;
        final previousExpanded = previous.expandedStudents[student.id] ?? true;
        
        return currentExpanded != previousExpanded ||
               current.trackingData != previous.trackingData ||
               current.selectedMonth != previous.selectedMonth;
      },
      builder: (context, state) {
        if (state is! TrackingDataLoaded) {
          return const SizedBox.shrink();
        }
        
        final isExpanded = state.expandedStudents[student.id] ?? true;

        // Sabit genişlikler
        const double imageWidth = 200.0; // Daha küçük resim genişliği

        // Ders listesi ve toplam satır için yükseklik hesapla
        final int rowCount =
            EnumCourse.values.length + 1; // +1 for GÜNLÜK TOPLAM row
        final double rowHeight = 40.0; // Her satır için yükseklik
        final double sectionHeight = rowCount * rowHeight; // Toplam yükseklik

        // Öğrenci numarası mı var?
        final hasStudentNumber = student.ogrenciNo?.isNotEmpty ?? false;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: Column(
            children: [
              // Öğrenci başlığı - tıklanabilir
              InkWell(
                onTap: () {
                  context.read<DailyTrackingBloc>().add(ToggleStudentExpansion(student.id));
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
                                  text: '${student.ogrenciNo} - ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              // Ardından öğrenci adını göster
                              TextSpan(
                                text: student.adSoyad,
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
                                  ..._buildDailyTotalCells(student, state),

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
                                        _calculateStudentMonthlyTotal(student.id, state)
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
                                      ..._buildCourseDailyCells(student, course, state),

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
                                                    student.id, course, state)
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
      },
    );
  }

  // Fix 5: Update daily total cells to use correct week calculation
  List<Widget> _buildDailyTotalCells(Student student, TrackingDataLoaded state) {
    List<Widget> cells = [];
    final daysInMonth = _getDaysInMonth(state.selectedMonth);

    // Hafta tanımlayıcılarını takip et
    Set<String> addedWeeks = {};

    // Yıl-hafta formatında benzersiz tanımlayıcı
    String weekIdentifier(DateTime date) =>
        '${date.year}-${_getWeekOfYear(date)}';

    for (int i = 0; i < daysInMonth.length; i++) {
      final day = daysInMonth[i];
      final isWeekend = _isWeekend(day);
      final dateStr = DateFormat('yyyy-MM-dd').format(day);

      // Bu gün için toplam hesapla - Performance optimization: Cache this calculation
      final cacheKey = 'day_total_${student.id}_$dateStr';
      int dayTotal;
      if (_calculationCache.containsKey(cacheKey)) {
        dayTotal = _calculationCache[cacheKey]!;
      } else {
        dayTotal = 0;
        if (state.trackingData[student.id]?[dateStr] != null) {
          state.trackingData[student.id]![dateStr]!.forEach((course, count) {
            dayTotal += count;
          });
        }
        _calculationCache[cacheKey] = dayTotal;
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
      String weekId = weekIdentifier(day);

      // Son güne geldik mi?
      bool isLastDay = i == daysInMonth.length - 1;

      // Pazar günü mü?
      bool isWeekEnd = day.weekday == DateTime.sunday;

      // Yarın farklı bir haftaya mı geçiyor?
      bool isNewWeekTomorrow = false;
      if (!isLastDay) {
        isNewWeekTomorrow = !_isSameWeek(day, daysInMonth[i + 1]);
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
        // Bu hafta için toplam hesapla - Performance optimization: Use cached version
        int weekTotal = _getCachedWeekTotalForStudent(student.id, day, state);

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

  // Replace old calculation methods with cached versions
  int _calculateStudentMonthlyTotal(int studentId, TrackingDataLoaded state) {
    return _getCachedStudentMonthlyTotal(studentId, state);
  }

  int _calculateCourseTotalForStudent(int studentId, EnumCourse course, TrackingDataLoaded state) {
    return _getCachedCourseTotalForStudent(studentId, course, state);
  }

  // Performance optimization: Cached calculation methods
  int _getCachedStudentMonthlyTotal(int studentId, TrackingDataLoaded state) {
    final cacheKey = 'monthly_total_$studentId';
    if (_calculationCache.containsKey(cacheKey)) {
      return _calculationCache[cacheKey]!;
    }
    
    int total = 0;
    state.trackingData[studentId]?.forEach((date, courses) {
      courses.forEach((course, count) {
        total += count;
      });
    });
    
    _calculationCache[cacheKey] = total;
    return total;
  }

  int _getCachedCourseTotalForStudent(int studentId, EnumCourse course, TrackingDataLoaded state) {
    final cacheKey = 'course_total_${studentId}_${course.toString()}';
    if (_calculationCache.containsKey(cacheKey)) {
      return _calculationCache[cacheKey]!;
    }
    
    int total = 0;
    state.trackingData[studentId]?.forEach((date, courses) {
      total += courses[course] ?? 0;
    });
    
    _calculationCache[cacheKey] = total;
    return total;
  }

  int _getCachedWeekTotalForStudent(int studentId, DateTime referenceDate, TrackingDataLoaded state) {
    final int weekNum = _getWeekOfYear(referenceDate);
    final cacheKey = 'week_total_${studentId}_$weekNum';
    if (_calculationCache.containsKey(cacheKey)) {
      return _calculationCache[cacheKey]!;
    }
    
    int total = 0;
    if (state.weeklyData[studentId]?[weekNum] != null) {
      state.weeklyData[studentId]![weekNum]!.forEach((course, value) {
        total += value;
      });
    }
    
    _calculationCache[cacheKey] = total;
    return total;
  }

  int _getCachedCourseWeekTotal(int studentId, DateTime referenceDate, EnumCourse course, TrackingDataLoaded state) {
    final int weekNum = _getWeekOfYear(referenceDate);
    final cacheKey = 'course_week_total_${studentId}_${weekNum}_${course.toString()}';
    if (_calculationCache.containsKey(cacheKey)) {
      return _calculationCache[cacheKey]!;
    }
    
    final result = state.weeklyData[studentId]?[weekNum]?[course] ?? 0;
    _calculationCache[cacheKey] = result;
    return result;
  }

  // Optimized cell widget that shows Text by default, TextField when editing
  Widget _buildOptimizedDataCell({
    required int studentId,
    required DateTime date,
    required EnumCourse course,
    required int value,
    required bool isWeekend,
    required TrackingDataLoaded state,
  }) {
    final cellKey = '${studentId}_${DateFormat('yyyy-MM-dd').format(date)}_${course.toString()}';
    final isEditing = _editingCellKey == cellKey;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _editingCellKey = cellKey;
        });
      },
      child: Container(
        width: dayColWidth,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isWeekend ? weekendBgColor : weekdayBgColor,
          border: Border.all(color: Colors.grey.shade300, width: 0.5),
        ),
        child: isEditing
            ? _buildEditableTextField(studentId, date, course, value, isWeekend)
            : _buildDisplayText(value, isWeekend),
      ),
    );
  }

  Widget _buildEditableTextField(int studentId, DateTime date, EnumCourse course, int value, bool isWeekend) {
    final controller = TextEditingController(text: value > 0 ? value.toString() : '');
    
    // Auto-focus when entering edit mode
    return TextField(
      controller: controller,
      autofocus: true,
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
        fillColor: isWeekend ? dataEntryWeekendColor : dataEntryWeekdayColor,
      ),
      onSubmitted: (newValue) {
        _saveValue(studentId, date, course, newValue);
        setState(() {
          _editingCellKey = null;
        });
      },
      onTapOutside: (event) {
        _saveValue(studentId, date, course, controller.text);
        setState(() {
          _editingCellKey = null;
        });
      },
      onChanged: (newValue) {
        // Debounced saving
        final key = '${studentId}_${DateFormat('yyyy-MM-dd').format(date)}_${course.toString()}';
        _debounceTimers[key]?.cancel();
        _debounceTimers[key] = Timer(const Duration(milliseconds: 500), () {
          _saveValue(studentId, date, course, newValue);
          _debounceTimers.remove(key);
        });
      },
    );
  }

  Widget _buildDisplayText(int value, bool isWeekend) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: value > 0 
            ? (isWeekend ? dataEntryWeekendColor : dataEntryWeekdayColor)
            : Colors.transparent,
      ),
      child: Text(
        value > 0 ? value.toString() : '',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: value > 0 ? FontWeight.bold : FontWeight.normal,
          color: value > 0 ? Colors.black : Colors.grey.shade600,
        ),
      ),
    );
  }

  void _saveValue(int studentId, DateTime date, EnumCourse course, String newValue) {
    final intValue = newValue.isEmpty ? 0 : int.tryParse(newValue) ?? 0;
    context.read<DailyTrackingBloc>().add(SaveTrackingData(
      studentId,
      date,
      course,
      intValue,
    ));
    // Clear cache for affected calculations
    _clearCalculationCache();
  }

  // Fix 6: Similar update for course cells to use correct week calculation
  List<Widget> _buildCourseDailyCells(Student student, EnumCourse course, TrackingDataLoaded state) {
    List<Widget> cells = [];
    final daysInMonth = _getDaysInMonth(state.selectedMonth);

    // Hafta tanımlayıcılarını takip et
    Set<String> addedWeeks = {};

    // Yıl-hafta formatında benzersiz tanımlayıcı
    String weekIdentifier(DateTime date) =>
        '${date.year}-${_getWeekOfYear(date)}';

    for (int i = 0; i < daysInMonth.length; i++) {
      final day = daysInMonth[i];
      final isWeekend = _isWeekend(day);
      final dateStr = DateFormat('yyyy-MM-dd').format(day);
      final value = state.trackingData[student.id]?[dateStr]?[course] ?? 0;

      // Performance optimization: Use optimized cell widget
      cells.add(_buildOptimizedDataCell(
        studentId: student.id,
        date: day,
        course: course,
        value: value,
        isWeekend: isWeekend,
        state: state,
      ));

      // Hafta toplamı kontrolü
      bool needsWeekTotal = false;
      String weekId = weekIdentifier(day);

      // Son güne geldik mi?
      bool isLastDay = i == daysInMonth.length - 1;

      // Pazar günü mü?
      bool isWeekEnd = day.weekday == DateTime.sunday;

      // Yarın farklı bir haftaya mı geçiyor?
      bool isNewWeekTomorrow = false;
      if (!isLastDay) {
        isNewWeekTomorrow = !_isSameWeek(day, daysInMonth[i + 1]);
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
        // Bu hafta ve kurs için toplam hesapla - Performance optimization: Use cached version
        int weekValue = _getCachedCourseWeekTotal(student.id, day, course, state);

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
} 