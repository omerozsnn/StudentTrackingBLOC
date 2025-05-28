// ignore_for_file: depend_on_referenced_packages
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'api.dart/homeworkTrackingControlApi.dart' as homeworkTrackingApi;
import 'api.dart/studentControlApi.dart' as studentControlApi;
import 'api.dart/homeworkControlApi.dart' as homeworkControlApi;
import 'api.dart/studentHomeworkApi.dart' as studentHomeworkApi;

class ClassHomeworkTrackingPage extends StatefulWidget {
  final String className;
  const ClassHomeworkTrackingPage({super.key, required this.className});

  @override
  State<ClassHomeworkTrackingPage> createState() =>
      _ClassHomeworkTrackingPageState();
}

class _ClassHomeworkTrackingPageState extends State<ClassHomeworkTrackingPage> {
  final homeworkTrackingApi.ApiService homeworkTrackingApiService =
      homeworkTrackingApi.ApiService(baseUrl: 'http://localhost:3000');
  final studentControlApi.StudentApiService studentControlService =
      studentControlApi.StudentApiService(baseUrl: 'http://localhost:3000');
  final homeworkControlApi.ApiService homeworkControlApiService =
      homeworkControlApi.ApiService(baseUrl: 'http://localhost:3000');
  final studentHomeworkApi.StudentHomeworkApiService studentHomeworkApiService =
      studentHomeworkApi.StudentHomeworkApiService(
          baseUrl: 'http://localhost:3000');

  List<Student> students = [];
  List<Map<String, dynamic>> homeworks = [];
  Map<int, Map<int, Map<String, dynamic>>> trackingData = {};
  bool isLoading = true;
  String? errorMessage;
  String _layoutOption = 'vertical'; // Default layout option

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
      await _loadStudents();
      await _loadHomeworks();
      await _loadTrackingData();
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

  Future<void> _loadStudents() async {
    try {
      final data =
          await studentControlService.getStudentsByClassName(widget.className);
      setState(() {
        students = data;
      });
    } catch (error) {
      print('Öğrenciler yüklenemedi: $error');
      throw Exception('Öğrenciler yüklenemedi: $error');
    }
  }

  Future<void> _loadHomeworks() async {
    try {
      if (students.isEmpty) return;

      // İlk öğrencinin ödevlerini al
      final studentHomeworks = await studentHomeworkApiService
          .getStudentHomeworksByStudentId(students.first.id);

      Map<int, Map<String, dynamic>> uniqueHomeworks = {};

      // Her ödev için detayları al
      for (var homework in studentHomeworks) {
        final homeworkId =
            homework['odev_id'] ?? homework['homework']?['odev_id'];
        if (homeworkId != null && !uniqueHomeworks.containsKey(homeworkId)) {
          final homeworkDetails =
              await homeworkControlApiService.getHomeworkById(homeworkId);
          uniqueHomeworks[homeworkId] = {
            'id': homeworkId,
            'odev_adi': homeworkDetails['odev_adi'],
          };
        }
      }

      setState(() {
        homeworks = uniqueHomeworks.values.toList();
      });
    } catch (error) {
      print('Ödevler yüklenemedi: $error');
      throw Exception('Ödevler yüklenemedi: $error');
    }
  }

  Future<void> _loadTrackingData() async {
    try {
      trackingData.clear();

      for (var student in students) {
        trackingData[student.id] = {};

        final studentHomeworks = await studentHomeworkApiService
            .getStudentHomeworksByStudentId(student.id);

        for (var homework in studentHomeworks) {
          final homeworkId =
              homework['odev_id'] ?? homework['homework']?['odev_id'];

          try {
            final trackingList = await homeworkTrackingApiService
                .getHomeworkTrackingByStudentHomeworkId(homework['id']);

            if (trackingList.isNotEmpty) {
              final tracking = trackingList[0];
              trackingData[student.id]![homeworkId] = {
                'status': tracking['durum'] == 'yapti' ? '+' : '-',
              };
            } else {
              trackingData[student.id]![homeworkId] = {'status': '-'};
            }
          } catch (e) {
            trackingData[student.id]![homeworkId] = {'status': '-'};
          }
        }
      }
      setState(() {});
    } catch (error) {
      print('Takip verileri yüklenemedi: $error');
      throw Exception('Takip verileri yüklenemedi: $error');
    }
  }

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();
    final fontData = await rootBundle.load("assets/DejaVuSans.ttf");
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    final isHorizontal = _layoutOption == 'horizontal';
    final pageFormat =
        isHorizontal ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;
    final studentsPerPage = isHorizontal ? 25 : 20;

    // Öğrencileri sayfalara böl
    for (var studentIndex = 0;
        studentIndex < students.length;
        studentIndex += studentsPerPage) {
      final studentChunk = students.sublist(
          studentIndex,
          (studentIndex + studentsPerPage) > students.length
              ? students.length
              : studentIndex + studentsPerPage);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(20),
          header: (context) {
            if (context.pageNumber == 1) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${widget.className} - Ödev Takip Listesi',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: isHorizontal ? 10 : 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Öğrenci ${studentIndex + 1}-${studentIndex + studentChunk.length}',
                    style: pw.TextStyle(font: ttf, fontSize: 8),
                  ),
                  pw.SizedBox(height: 10),
                ],
              );
            }
            return pw.Container();
          },
          build: (context) => [
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              columnWidths: {
                0: const pw.FixedColumnWidth(30), // No
                1: const pw.FixedColumnWidth(60), // Adı
                2: const pw.FixedColumnWidth(60), // Soyadı
                ...homeworks.asMap().map((index, _) => MapEntry(
                      index + 3,
                      const pw.FixedColumnWidth(30),
                    )),
              },
              children: [
                // Başlık satırı
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _buildHeaderCell('No', ttf),
                    _buildHeaderCell('Adı', ttf),
                    _buildHeaderCell('Soyadı', ttf),
                    ...homeworks.map((homework) => _buildRotatedHeaderCell(
                        homework['odev_adi'] ?? '', ttf, isHorizontal)),
                  ],
                ),
                // Sadece bu sayfadaki öğrenciler için satırlar
                ...studentChunk.map((student) => pw.TableRow(
                      children: [
                        _buildCell(student.ogrenciNo?.toString() ?? '', ttf),
                        _buildCell(
                            student.adSoyad?.split(' ').first ?? '', ttf),
                        _buildCell(student.adSoyad?.split(' ').last ?? '', ttf),
                        ...homeworks.map((homework) {
                          final status = trackingData[student.id]
                                  ?[homework['id']]?['status'] ??
                              '-';
                          return _buildCell(
                            status,
                            ttf,
                            isStatus: true,
                            color: status == '+'
                                ? PdfColors.black
                                : PdfColors.black,
                          );
                        }),
                      ],
                    )),
              ],
            ),
          ],
          footer: (context) => pw.Center(
            child: pw.Text(
              'Sayfa ${context.pageNumber}',
              style: pw.TextStyle(font: ttf, fontSize: 8),
            ),
          ),
        ),
      );
    }

    return pdf.save();
  }

  Future<void> _generateAndDownloadPDF() async {
    final pdfBytes = await _generatePdf();

    final String filename = '${widget.className} - Ödev Takip Listesi.pdf';
    final String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'PDF Kaydet',
      fileName: filename,
      allowedExtensions: ['pdf'],
      type: FileType.custom,
    );

    if (outputPath != null) {
      try {
        final file = File(outputPath);
        await file.writeAsBytes(pdfBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF kaydedildi: ${file.path}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF kaydedilirken bir hata oluştu.')),
        );
      }
    }
  }

  pw.Widget _buildHeaderCell(String text, pw.Font ttf) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
            font: ttf, fontSize: 6, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  // Yardımcı widget'ları güncelleyelim
  pw.Widget _buildRotatedHeaderCell(
      String text, pw.Font ttf, bool isHorizontal) {
    final double cellHeight =
        isHorizontal ? 100.0 : 120.0; // Yüksekliği artırdık
    final double textWidth = cellHeight - 8;

    return pw.Container(
      height: cellHeight,
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      alignment: pw.Alignment.center,
      child: pw.Transform.rotate(
        angle: 1.5708, // 90 derece
        child: pw.Container(
          width: textWidth,
          alignment: pw.Alignment.center,
          child: pw.Text(
            text,
            style: pw.TextStyle(
              font: ttf,
              fontSize: isHorizontal ? 7 : 8,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
            maxLines: 4, // Daha fazla satıra izin verdik
            overflow: pw.TextOverflow.clip, // ellipsis yerine clip kullanıyoruz
          ),
        ),
      ),
    );
  }

  pw.Widget _buildCell(String text, pw.Font ttf,
      {bool isStatus = false, PdfColor? color}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(2),
      alignment: isStatus ? pw.Alignment.center : pw.Alignment.centerLeft,
      height: 20,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: ttf,
          fontSize: 6,
          color: color ?? PdfColors.black,
        ),
        maxLines: 1,
        overflow: pw.TextOverflow.clip,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.className} - Ödev Takip Listesi'),
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
        child: Column(
          children: [
            Expanded(child: _buildBody()),
          ],
        ),
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
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            SizedBox(height: 16),
            Text('Veriler yükleniyor...',
                style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (errorMessage != null) return _buildErrorWidget();
    if (students.isEmpty) return _buildEmptyStudentsWidget();
    if (homeworks.isEmpty) return _buildEmptyHomeworksWidget();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tab Bar
                const Expanded(
                  child: TabBar(
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
                ),
                // Düzen Seçici
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
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildDataTable(),
                _buildPdfPreview(),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Yeni fonksiyon ekleyin
  Widget _buildPdfPreview() {
    return PdfPreview(
      build: (format) => _generatePdf(),
      initialPageFormat: _layoutOption == 'horizontal'
          ? PdfPageFormat.a4.landscape
          : PdfPageFormat.a4,
      pdfFileName: '${widget.className} - Ödev Takip Listesi.pdf',
      canChangePageFormat: false,
      canChangeOrientation: false,
      maxPageWidth: 700,
      actions: [
        PdfPreviewAction(
          icon: Image.asset(
            'assets/icons/pdf(1).png',
            width: 24,
            height: 24,
          ),
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

  Widget _buildEmptyHomeworksWidget() {
    return const Center(
      child: Text(
        'Bu sınıfa henüz ödev atanmamış.',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  Widget _buildDataTable() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      child: Center(
        // Burayı ekledik
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: LayoutBuilder(
              // LayoutBuilder ekledik
              builder: (context, constraints) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  width: MediaQuery.of(context).size.width *
                      0.95, // Ekran genişliğine göre ayarladık
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dataTableTheme: const DataTableThemeData(
                        headingTextStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6C8997),
                          fontSize: 10,
                        ),
                        dataTextStyle: TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                        ),
                        headingRowHeight: 32.0,
                        dataRowHeight: 48.0,
                        dividerThickness: 1.0,
                      ),
                    ),
                    child: DataTable(
                      showCheckboxColumn: false,
                      horizontalMargin: 8,
                      columnSpacing: 12,
                      headingRowColor: MaterialStateProperty.all(
                        const Color(0xFF6C8997).withOpacity(0.1),
                      ),
                      columns: [
                        const DataColumn(
                          label: Text('NO'),
                        ),
                        const DataColumn(
                          label: Text('ADI'),
                        ),
                        const DataColumn(
                          label: Text('SOYADI'),
                        ),
                        ...homeworks.map((homework) => DataColumn(
                              label: Container(
                                constraints: const BoxConstraints(
                                    maxWidth: 60,
                                    maxHeight: 80), // Maksimum genişlik
                                child: Text(
                                  homework['odev_adi'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 8), // Font boyutunu küçülttük
                                  overflow: TextOverflow.ellipsis,
                                  maxLines:
                                      3, // Gerekirse 3 satıra kadar izin ver
                                ),
                              ),
                            )),
                      ],
                      rows: students.map((student) {
                        return DataRow(
                          cells: [
                            DataCell(Text(student.ogrenciNo?.toString() ?? '',
                                style: const TextStyle(fontSize: 12))),
                            DataCell(Text(
                                student.ogrenciNo?.split(' ').first ?? '',
                                style: const TextStyle(fontSize: 12))),
                            DataCell(Text(
                                student.adSoyad?.split(' ').last ?? '',
                                style: const TextStyle(fontSize: 12))),
                            ...homeworks.map((homework) {
                              final trackingInfo =
                                  trackingData[student.id]?[homework['id']];
                              final status = trackingInfo?['status'] ?? '-';

                              return DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: status == '+'
                                        ? Colors.green.withOpacity(0.1)
                                        : null,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: status == '+'
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
