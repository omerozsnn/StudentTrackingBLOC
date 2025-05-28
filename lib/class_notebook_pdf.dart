// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ogrenci_takip_sistemi/models/course_classes_model.dart';
import 'package:ogrenci_takip_sistemi/models/courses_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'api.dart/defterKitapControlApi.dart' as defterKitapApi;
import 'api.dart/classApi.dart' as classApi;
import 'api.dart/studentControlApi.dart' as studentApi;
import 'api.dart/courseClassesApi.dart' as courseClassesApi;

class ClassNotebookBookTrackingPage extends StatefulWidget {
  final String className;

  const ClassNotebookBookTrackingPage({super.key, required this.className});

  @override
  _ClassNotebookBookTrackingPageState createState() =>
      _ClassNotebookBookTrackingPageState();
}

class _ClassNotebookBookTrackingPageState
    extends State<ClassNotebookBookTrackingPage> {
  final classApi.ApiService classService =
      classApi.ApiService(baseUrl: 'http://localhost:3000');
  final studentApi.StudentApiService studentService =
      studentApi.StudentApiService(baseUrl: 'http://localhost:3000');
  final defterKitapApi.ApiService defterKitapService =
      defterKitapApi.ApiService(baseUrl: 'http://localhost:3000');
  final courseClassesApi.ApiService courseClassApi =
      courseClassesApi.ApiService(baseUrl: 'http://localhost:3000');

  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> history = [];
  List<String> availableDates = [];
  bool isLoading = true;
  String? errorMessage;
  String _layoutOption = 'vertical'; // Default layout option
  int? classId;
  String? selectedCourse;
  int? selectedCourseId;
  int? courseClassId;
  List<CourseClass> courses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      await _loadClassId();
      await _loadStudents();
      await _loadCourses();
    } catch (error) {
      setState(() {
        errorMessage = 'Veriler yüklenirken bir hata oluştu: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadClassId() async {
    try {
      final id = await classService.getClassIdByName(widget.className);
      if (id != null) {
        setState(() {
          classId = id;
        });
      }
    } catch (error) {
      print('Sınıf ID yüklenemedi: $error');
      throw Exception('Sınıf ID yüklenemedi: $error');
    }
  }

  Future<void> _loadStudents() async {
    if (classId == null) return;
    try {
      final data = await studentService.getStudentsByClassId(classId!);
      setState(() {
        students = data.map((student) {
          return {
            'id': student.id,
            'ogrenci_no': student.ogrenciNo,
            'ad_soyad': student.adSoyad,
            'notebook': true,
            'book': true,
          };
        }).toList();
      });
    } catch (error) {
      print('Öğrenciler yüklenemedi: $error');
      throw Exception('Öğrenciler yüklenemedi: $error');
    }
  }

  Future<void> _loadCourses() async {
    if (classId == null) return;
    try {
      final data = await courseClassApi.getCourseClassesByClassId(classId!);

      setState(() {
        courses = data;

        if (courses.isNotEmpty) {
          selectedCourse = courses[0].course?.dersAdi;
          selectedCourseId = courses[0].id;
          _getCourseClassId(classId!, selectedCourseId!);
        }
      });
    } catch (error) {
      print('Dersler yüklenemedi: $error');
      throw Exception('Dersler yüklenemedi: $error');
    }
  }

  Future<void> _getCourseClassId(int sinifId, int dersId) async {
    try {
      final id = await courseClassApi.getCourseClassIdByClassAndCourseId(
          sinifId, dersId);
      if (id != null) {
        setState(() {
          courseClassId = id;
          _loadAvailableDates();
        });
      }
    } catch (error) {
      print('CourseClass ID alınamadı: $error');
    }
  }

  Future<void> _loadAvailableDates() async {
    if (courseClassId == null) return;
    try {
      final dates =
          await defterKitapService.getDatesByCourseClassId(courseClassId!);
      setState(() {
        availableDates =
            dates.map((date) => _formatDate(date['tarih'] as String)).toList();
      });
      if (availableDates.isNotEmpty) {
        _loadHistoryByDate(availableDates[0]);
      }
    } catch (error) {
      print('Tarihler yüklenemedi: $error');
    }
  }

  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }

  Future<void> _loadHistoryByDate(String date) async {
    if (courseClassId == null) return;
    try {
      // Tüm tarihlerin verilerini yükle
      List<Map<String, dynamic>> allHistory = [];

      for (String currentDate in availableDates) {
        final dateParts = currentDate.split('-');
        final apiDateFormat = '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';

        final data = await defterKitapService
            .getDefterKitapByDateAndCourseClass(apiDateFormat, courseClassId!);

        if (data != null) {
          allHistory.addAll(List<Map<String, dynamic>>.from(data));
        }
      }

      setState(() {
        history = allHistory;

        // Öğrenci durumlarını sıfırla
        for (var student in students) {
          student['notebook'] = false;
          student['book'] = false;
        }

        // Gelen verilere göre öğrenci durumlarını güncelle
        for (var record in history) {
          var studentId = record['students'][0]['id'];
          var student = students.firstWhere(
            (s) => s['id'] == studentId,
            orElse: () => {},
          );

          if (student != null) {
            String recordDate = _formatDate(record['tarih']);
            if (recordDate == date) {
              student['notebook'] = record['defter_durum'] == 'getirdi';
              student['book'] = record['kitap_durum'] == 'getirdi';
            }
          }
        }
      });

      // Debug için log
      print('Loaded history data: ${history.length} records');
    } catch (error) {
      print('Geçmiş yüklenemedi: $error');
      print('Hata detayları: $error');
    }
  }

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load("assets/DejaVuSans.ttf");
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    final boldFontData = await rootBundle.load("assets/dejavu-sans-bold.ttf");
    final boldTtf = pw.Font.ttf(boldFontData.buffer.asByteData());

    final isHorizontal = _layoutOption == 'horizontal';
    final datesPerPage =
        isHorizontal ? 20 : 15; // Yatayda daha fazla tarih göster
    final pageFormat = PdfPageFormat(
      isHorizontal ? 842 : 595, // A4 genişlik
      isHorizontal ? 595 : 842, // A4 yükseklik
      marginAll: isHorizontal ? 20 : 30,
    );

    // Sort dates chronologically
    final sortedDates = availableDates.toList()
      ..sort((a, b) {
        final aParts = a.split('-');
        final bParts = b.split('-');
        final aDate = DateTime(
            int.parse(aParts[2]), int.parse(aParts[1]), int.parse(aParts[0]));
        final bDate = DateTime(
            int.parse(bParts[2]), int.parse(bParts[1]), int.parse(bParts[0]));
        return aDate.compareTo(bDate);
      });

    for (var i = 0; i < sortedDates.length; i += datesPerPage) {
      final datesToShow = sortedDates.sublist(
        i,
        i + datesPerPage > sortedDates.length
            ? sortedDates.length
            : i + datesPerPage,
      );

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Text(
                    '${widget.className} - Defter Kitap Takip Listesi',
                    style: pw.TextStyle(
                      font: boldTtf,
                      fontSize: isHorizontal ? 12 : 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                if (selectedCourse != null)
                  pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 10),
                    child: pw.Text(
                      'Ders: $selectedCourse',
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: isHorizontal ? 10 : 10,
                      ),
                    ),
                  ),
                pw.Expanded(child: _buildPdfTable(datesToShow, ttf, boldTtf)),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  pw.Widget _buildPdfTable(
      List<String> dates, pw.Font regularFont, pw.Font boldFont) {
    final isHorizontal = _layoutOption == 'horizontal';

    // Sütun genişliklerini ayarla
    final Map<int, pw.TableColumnWidth> columnWidths = {
      0: const pw.FixedColumnWidth(25), // No için
      1: pw.FixedColumnWidth(isHorizontal ? 80 : 60), // Ad Soyad için
    };

    // Tarih sütunları için genişlik
    for (var i = 0; i < dates.length; i++) {
      columnWidths[i + 2] = pw.FixedColumnWidth(isHorizontal ? 20 : 20);
    }

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: columnWidths,
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
      children: [
        // Başlık satırı
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildPdfHeaderCell('No', regularFont),
            _buildPdfHeaderCell('Ad Soyad', regularFont),
            ...dates.map((date) => _buildPdfDateHeaderCell(date, regularFont)),
          ],
        ),
        // Öğrenci satırları
        ...students.map((student) {
          return pw.TableRow(
            children: [
              _buildPdfCell(student['ogrenci_no'].toString(), regularFont),
              _buildPdfCell(student['ad_soyad'], regularFont),
              ...dates.map((date) {
                return _buildPdfStatusCell(student, date, history, boldFont);
              }),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildPdfHeaderCell(String text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(2),
      alignment: pw.Alignment.center,
      height: 20,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildPdfDateHeaderCell(String date, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(2),
      alignment: pw.Alignment.center,
      height: 30,
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            date,
            style: pw.TextStyle(
              font: font,
              fontSize: 6,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              pw.Text('D', style: pw.TextStyle(font: font, fontSize: 6)),
              pw.Text('K', style: pw.TextStyle(font: font, fontSize: 6)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfCell(String text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: 8),
      ),
    );
  }

  pw.Widget _buildPdfStatusCell(Map<String, dynamic> student, String date,
      List<Map<String, dynamic>> history, pw.Font font) {
    final records = history
        .where((h) =>
            h['students'][0]['id'] == student['id'] &&
            _formatDate(h['tarih']) == date)
        .toList();

    final notebook = records.isNotEmpty &&
        records.any((r) => r['defter_durum'] == 'getirdi');
    final book =
        records.isNotEmpty && records.any((r) => r['kitap_durum'] == 'getirdi');

    return pw.Container(
      padding: const pw.EdgeInsets.all(2),
      alignment: pw.Alignment.center,
      height: 15,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        children: [
          pw.Text(
            notebook ? '✓' : '×',
            style: pw.TextStyle(
              font: font,
              fontSize: 8,
              color: notebook ? PdfColors.green : PdfColors.red,
            ),
          ),
          pw.Text(
            book ? '✓' : '×',
            style: pw.TextStyle(
              font: font,
              fontSize: 8,
              color: book ? PdfColors.green : PdfColors.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.className} - Defter Kitap Takip Listesi'),
        backgroundColor: const Color(0xFF6C8997),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6C8997), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text('Veriler yükleniyor...',
                style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (errorMessage != null) return _buildErrorWidget();
    if (students.isEmpty) return _buildEmptyStudentsWidget();
    if (courses.isEmpty) return _buildEmptyCoursesWidget();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: TabBarView(
              children: [
                _buildDataTableCard(),
                _buildPdfPreview(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Ders Seçimi',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: selectedCourse,
                    items: courses.map((course) {
                      return DropdownMenuItem<String>(
                        value: course.course?.dersAdi,
                        child: Text(course.course!.dersAdi),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedCourse = newValue;
                          selectedCourseId = courses
                              .firstWhere((course) =>
                                  course.course?.dersAdi == newValue)
                              .id;
                          _getCourseClassId(classId!, selectedCourseId!);
                        });
                      }
                    },
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Düzen:',
                      style: TextStyle(
                        color: Color(0xFF6C8997),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ToggleButtons(
                      onPressed: (int index) {
                        setState(() {
                          _layoutOption =
                              index == 0 ? 'vertical' : 'horizontal';
                        });
                      },
                      isSelected: [
                        _layoutOption == 'vertical',
                        _layoutOption == 'horizontal'
                      ],
                      borderRadius: BorderRadius.circular(8),
                      selectedColor: Colors.white,
                      fillColor: const Color(0xFF6C8997),
                      color: const Color(0xFF6C8997),
                      constraints: const BoxConstraints(
                        minHeight: 36,
                        minWidth: 64,
                      ),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.vertical_align_top, size: 16),
                              SizedBox(width: 4),
                              Text('Dikey'),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Icon(Icons.horizontal_distribute, size: 16),
                              SizedBox(width: 4),
                              Text('Yatay'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.table_chart),
                    SizedBox(width: 8),
                    Text('Tablo'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf),
                    SizedBox(width: 8),
                    Text('Önizleme'),
                  ],
                ),
              ),
            ],
            labelColor: Color(0xFF6C8997),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF6C8997),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTableCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  showCheckboxColumn: false,
                  horizontalMargin: 12,
                  columnSpacing: 20,
                  headingRowColor: MaterialStateProperty.all(
                    const Color(0xFF6C8997).withOpacity(0.1),
                  ),
                  columns: [
                    const DataColumn(label: Text('NO')),
                    const DataColumn(label: Text('ADI SOYADI')),
                    ...availableDates.map(
                      (date) => DataColumn(
                        label: RotatedBox(
                          quarterTurns: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(date),
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: students.map((student) {
                    return DataRow(
                      cells: [
                        DataCell(Text(student['ogrenci_no'].toString())),
                        DataCell(Text(student['ad_soyad'])),
                        ...availableDates.map((date) {
                          final record = history.firstWhere(
                            (h) =>
                                h['students'][0]['id'] == student['id'] &&
                                _formatDate(h['tarih']) == date,
                            orElse: () => {},
                          );

                          final notebook = record.isNotEmpty &&
                              record['defter_durum'] == 'getirdi';
                          final book = record.isNotEmpty &&
                              record['kitap_durum'] == 'getirdi';

                          return DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  notebook
                                      ? Icons.check_circle
                                      : Icons.remove_circle,
                                  color: notebook ? Colors.green : Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  book
                                      ? Icons.check_circle
                                      : Icons.remove_circle,
                                  color: book ? Colors.green : Colors.red,
                                  size: 16,
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Icons.check_circle, Colors.green, 'Getirdi'),
                const SizedBox(width: 16),
                _buildLegendItem(Icons.remove_circle, Colors.red, 'Getirmedi'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }

  Widget _buildPdfPreview() {
    return PdfPreview(
      build: (format) => _generatePdf(),
      initialPageFormat: _layoutOption == 'horizontal'
          ? PdfPageFormat.a4.landscape
          : PdfPageFormat.a4,
      pdfFileName:
          '${widget.className}_${selectedCourse}_Defter_Kitap_Takip.pdf',
      canChangePageFormat: false,
      canChangeOrientation: false,
      maxPageWidth: 700,
      actions: [
        PdfPreviewAction(
          icon: const Icon(Icons.save),
          onPressed: (context, build, pageFormat) async {
            await _generateAndDownloadPDF();
          },
        ),
      ],
      previewPageMargin: const EdgeInsets.all(16),
      scrollViewDecoration: BoxDecoration(
        color: Colors.grey.shade200,
      ),
    );
  }

  Future<void> _generateAndDownloadPDF() async {
    try {
      final pdfBytes = await _generatePdf();

      final String filename =
          '${widget.className}_${selectedCourse}_Defter_Kitap_Takip.pdf';
      final String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'PDF Kaydet',
        fileName: filename,
        allowedExtensions: ['pdf'],
        type: FileType.custom,
      );

      if (outputPath != null) {
        final file = File(outputPath);
        await file.writeAsBytes(pdfBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF başarıyla kaydedildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      print('PDF oluşturma hatası: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF oluşturulurken bir hata oluştu'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Veriler Yüklenemedi',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? 'Bir hata oluştu',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C8997),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStudentsWidget() {
    return const Center(
      child: Text(
        'Bu sınıfta henüz öğrenci bulunmuyor.',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyCoursesWidget() {
    return const Center(
      child: Text(
        'Bu sınıfa henüz ders atanmamış.',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
