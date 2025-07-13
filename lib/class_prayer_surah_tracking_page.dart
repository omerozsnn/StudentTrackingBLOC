// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
// ignore: duplicate_ignore
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'api.dart/prayerSurahTrackingControlApi.dart'
    // ignore: library_prefixes
    as prayerSurahTrackingControlApi;
// ignore: library_prefixes
import 'api.dart/studentControlApi.dart' as studentControlApi;
import 'api.dart/prayerSurahApi.dart';
import 'api.dart/classApi.dart' as classApi;
import 'api.dart/prayerSurahStudentApi.dart';

class ClassPrayerSurahTrackingPage extends StatefulWidget {
  final String className;

  const ClassPrayerSurahTrackingPage({super.key, required this.className});

  @override
  // ignore: library_private_types_in_public_api
  _ClassPrayerSurahTrackingPageState createState() =>
      _ClassPrayerSurahTrackingPageState();
}

class _ClassPrayerSurahTrackingPageState
    extends State<ClassPrayerSurahTrackingPage> {
  final prayerSurahTrackingControlApi.ApiService prayerSurahTrackingApiService =
      prayerSurahTrackingControlApi.ApiService(
          baseUrl: 'http://localhost:3000');
  final studentControlApi.StudentApiService studentControlApiService =
      studentControlApi.StudentApiService(baseUrl: 'http://localhost:3000');
  final PrayerSurahApiService prayerSurahApiService =
      PrayerSurahApiService(baseUrl: 'http://localhost:3000');
  final classApi.ApiService classApiService =
      classApi.ApiService(baseUrl: 'http://localhost:3000');
  final PrayerSurahStudentApiService prayerSurahStudentApiService =
      PrayerSurahStudentApiService(baseUrl: 'http://localhost:3000');

  List<Student> students = [];
  List<Map<String, dynamic>> prayerSurahs = [];
  int? selectedClassId;
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
      await _loadPrayerSurahs();
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
      final data = await studentControlApiService
          .getStudentsByClassName(widget.className);
      setState(() {
        students = data;
      });
    } catch (error) {
      print('Öğrenciler yüklenemedi: $error');
      throw Exception('Öğrenciler yüklenemedi: $error');
    }
  }

  Future<void> _loadPrayerSurahs() async {
    try {
      // Önce sınıf ID'sini al
      final int? classId =
          await classApiService.getClassIdByName(widget.className);
      if (classId == null) return;

      // Sınıfa atanmış dua ve sureleri al
      final assignedData = await prayerSurahStudentApiService
          .getPrayerSurahStudentByClassId(classId);

      // Atanmış dua ve sureleri filtreleyip unique olanları al
      final Set<int> uniquePrayerSurahIds = {};
      final List<Map<String, dynamic>> filteredPrayerSurahs = [];

      for (var assigned in assignedData) {
        final int prayerSurahId = assigned.duaSureId;
        if (!uniquePrayerSurahIds.contains(prayerSurahId)) {
          uniquePrayerSurahIds.add(prayerSurahId);

          // Dua/sure detaylarını al
          final prayerSurahDetails =
              await prayerSurahApiService.getPrayerSurahById(prayerSurahId);
          if (prayerSurahDetails != null) {
            filteredPrayerSurahs.add(prayerSurahDetails.toJson());
          }
        }
      }

      setState(() {
        prayerSurahs = filteredPrayerSurahs;
      });
    } catch (error) {
      print('Dua ve sureler yüklenemedi: $error');
      throw Exception('Dua ve sureler yüklenemedi: $error');
    }
  }

  Future<void> _loadTrackingData() async {
    try {
      trackingData.clear(); // Önceki verileri temizle

      for (var student in students) {
        try {
          final trackings = await prayerSurahTrackingApiService
              .getPrayerSurahTrackingsByStudentId(student.id);

          // Her öğrenci için boş bir map oluştur
          trackingData[student.id] = {};

          for (var tracking in trackings) {
            final studentId = student.id;
            final prayerSurahId =
                tracking['prayer_surah_student']?['dua_sure_id'];

            if (studentId != null && prayerSurahId != null) {
              // Durum kontrolü
              final String status = tracking['durum'] == 'Okudu' ? '+' : '-';

              // Değerlendirme kontrolü
              final String comment = tracking['degerlendirme'] ?? '';

              // Veriyi sakla
              trackingData[studentId]![prayerSurahId] = {
                'status': status,
                'comment': comment
              };

              // Debug için yazdır
              print(
                  'Öğrenci $studentId, Dua/Sure $prayerSurahId: Status=$status, Comment=$comment');
            }
          }
        } catch (error) {
          // 404 hatası normal bir durum - sadece debug için yazdır
          if (error.toString().contains('404')) {
            print('Öğrenci ${student.id} için henüz değerlendirme yok');
          } else {
            print('Öğrenci ${student.id} için veri yükleme hatası: $error');
          }

          // Her durumda öğrenci için boş bir map oluştur
          trackingData[student.id] = {};
        }
      }
      setState(() {}); // UI'ı güncelle
    } catch (error) {
      print('Takip verileri yüklenemedi: $error');
      throw Exception('Takip verileri yüklenemedi: $error');
    }
  }

  void _showCommentDialog(BuildContext context, String comment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.comment_outlined,
                color: Color(0xFF6C8997),
              ),
              SizedBox(width: 8),
              Text('Değerlendirme'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              comment,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Kapat',
                style: TextStyle(
                  color: Color(0xFF6C8997),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();
    // Fontlar
    final fontData = await rootBundle.load("assets/DejaVuSans.ttf");
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    final boldFontData = await rootBundle.load("assets/dejavu-sans-bold.ttf");
    final boldTtf = pw.Font.ttf(boldFontData.buffer.asByteData());

    final isHorizontal = _layoutOption == 'horizontal';
    final pageFormat =
        isHorizontal ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;

    // Sayfa başına düşecek öğrenci ve dua sayısı
    final int studentsPerPage = isHorizontal ? 25 : 20;
    final int prayersPerPage = isHorizontal ? 15 : 10;

    // Öğrenci ve dua listelerini sayfalara böl
    for (var studentIndex = 0;
        studentIndex < students.length;
        studentIndex += studentsPerPage) {
      final studentChunk = students.sublist(
          studentIndex,
          (studentIndex + studentsPerPage) > students.length
              ? students.length
              : studentIndex + studentsPerPage);

      for (var prayerIndex = 0;
          prayerIndex < prayerSurahs.length;
          prayerIndex += prayersPerPage) {
        final prayerChunk = prayerSurahs.sublist(
            prayerIndex,
            (prayerIndex + prayersPerPage) > prayerSurahs.length
                ? prayerSurahs.length
                : prayerIndex + prayersPerPage);

        pdf.addPage(
          pw.MultiPage(
            pageFormat: pageFormat,
            margin: const pw.EdgeInsets.all(20),
            header: (context) {
              // Sadece ilk sayfa için header göster
              if (context.pageNumber == 1) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '${widget.className} - Dua & Sure Takip Listesi',
                      style: pw.TextStyle(
                        font: boldTtf,
                        fontSize: isHorizontal ? 10 : 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Sayfa ${context.pageNumber}/${context.pagesCount} - Öğrenci ${studentIndex + 1}-${studentIndex + studentChunk.length}',
                      style: pw.TextStyle(font: ttf, fontSize: 8),
                    ),
                    pw.SizedBox(height: 10),
                  ],
                );
              }
              // Diğer sayfalar için boş container dön
              return pw.Container();
            },
            build: (pw.Context context) => [
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                columnWidths: {
                  0: pw.FixedColumnWidth(40), // No
                  1: pw.FixedColumnWidth(60), // Adı
                  2: pw.FixedColumnWidth(60), // Soyadı
                  ...prayerChunk.asMap().map((index, _) => MapEntry(
                        3 + index,
                        pw.FixedColumnWidth(isHorizontal ? 15 : 20),
                      )),
                },
                children: [
                  // Başlık satırı
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildHeaderCell('No', ttf),
                      _buildHeaderCell('Adı', ttf),
                      _buildHeaderCell('Soyadı', ttf),
                      ...prayerChunk.map((prayerSurah) =>
                          _buildRotatedHeaderCell(
                              prayerSurah['dua_sure_adi'] ?? '',
                              ttf,
                              isHorizontal)),
                    ],
                  ),
                  // Öğrenci satırları
                  ...studentChunk.map((student) => pw.TableRow(
                        children: [
                          _buildCell(
                              (student.ogrenciNo?.toString() ?? ''), ttf),
                          _buildCell(
                              (student.adSoyad?.split(' ').first ?? '') +
                                  ' ' +
                                  (student.adSoyad != null &&
                                          student.adSoyad.split(' ').length > 2
                                      ? student.adSoyad.split(' ')[1]!
                                      : ''),
                              ttf),
                          _buildCell(
                              student.adSoyad?.split(' ').last ?? '', ttf),
                          ...prayerChunk.map((prayerSurah) {
                            final trackingInfo =
                                trackingData[student.id]?[prayerSurah['id']];
                            final status = trackingInfo?['status'] ?? '-';
                            return _buildCell(status, boldTtf, center: true);
                          }),
                        ],
                      )),
                ],
              ),
            ],
          ),
        );
      }
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

  // Yardımcı metotlar
  pw.Widget _buildHeaderCell(String text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
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

// _buildRotatedHeaderCell fonksiyonunu güncelle
  pw.Widget _buildRotatedHeaderCell(
      String text, pw.Font font, bool isHorizontal) {
    return pw.Container(
      height: isHorizontal ? 60 : 80,
      padding: const pw.EdgeInsets.all(2),
      alignment: pw.Alignment.center,
      child: pw.Transform.rotate(
        angle: 1.5708, // 90 derece
        child: pw.Text(
          text,
          style: pw.TextStyle(
            font: font,
            fontSize: isHorizontal ? 5 : 6,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  pw.Widget _buildCell(String text, pw.Font font, {bool center = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      alignment: center ? pw.Alignment.center : pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.className} - Dua & Sure Takip Listesi'),
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
            Expanded(
              child: _buildBody(),
            ),
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
    if (prayerSurahs.isEmpty) return _buildEmptyPrayerSurahsWidget();

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
                _buildDataTableCard(),
                _buildPdfPreview(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfPreview() {
    return PdfPreview(
      build: (format) => _generatePdf(),
      initialPageFormat: _layoutOption == 'horizontal'
          ? PdfPageFormat.a4.landscape
          : PdfPageFormat.a4,
      pdfFileName: '${widget.className} - Dua & Sure Takip Listesi.pdf',
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

  Widget _buildDataTableCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: DataTable(
        showCheckboxColumn: false,
        horizontalMargin: 12,
        columnSpacing: 20,
        headingRowColor: MaterialStateProperty.all(
          const Color(0xFF6C8997).withOpacity(0.1),
        ),
        dataRowColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF6C8997).withOpacity(0.1);
            }
            return null;
          },
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
          ...prayerSurahs.map((prayerSurah) => DataColumn(
                label: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    prayerSurah['dua_sure_adi'] ?? '',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )),
        ],
        rows: students.map((student) {
          return DataRow(
            cells: [
              DataCell(Text(student.ogrenciNo?.toString() ?? '')),
              DataCell(Text(student.adSoyad?.split(' ').first ?? '')),
              DataCell(Text(student.adSoyad?.split(' ').last ?? '')),
              ...prayerSurahs.map((prayerSurah) {
                final trackingInfo =
                    trackingData[student.id]?[prayerSurah['id']];
                final status = trackingInfo?['status'] ?? '-';
                final comment = trackingInfo?['comment'] ?? '';

                return DataCell(
                  GestureDetector(
                    onTap: comment.isNotEmpty
                        ? () => _showCommentDialog(context, comment)
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: status == '+'
                            ? Colors.green.withOpacity(0.1)
                            : null,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            status,
                            style: TextStyle(
                              color: status == '+' ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (comment.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.blue,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        }).toList(),
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

  Widget _buildEmptyPrayerSurahsWidget() {
    return const Center(
      child: Text(
        'Bu sınıfa henüz ödev atanmamış.',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
