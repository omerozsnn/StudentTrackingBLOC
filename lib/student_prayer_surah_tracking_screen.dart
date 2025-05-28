// ignore_for_file: collection_methods_unrelated_type

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import '/api.dart/prayerSurahStudentApi.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
// ignore: duplicate_ignore
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'api.dart/classApi.dart';
import 'api.dart/prayerSurahTrackingControlApi.dart'
    // ignore: library_prefixes
    as prayerSurahTrackingControlApi;
// ignore: library_prefixes
import 'api.dart/studentControlApi.dart' as studentControlApi;
import 'api.dart/prayerSurahApi.dart';
import 'api.dart/classApi.dart' as classApi;

class SudentPrayerSurahScreen extends StatefulWidget {
  final int studentId;
  const SudentPrayerSurahScreen({super.key, required this.studentId});
  @override
  State<SudentPrayerSurahScreen> createState() =>
      _SudentPrayerSurahScreenState();
}

class _SudentPrayerSurahScreenState extends State<SudentPrayerSurahScreen> {
  final prayerSurahTrackingControlApi.ApiService prayerSurahTrackingApiService =
      prayerSurahTrackingControlApi.ApiService(
          baseUrl: 'http://localhost:3000');
  final studentControlApi.StudentApiService studentControlApiService =
      studentControlApi.StudentApiService(baseUrl: 'http://localhost:3000');
  final PrayerSurahApiService prayerSurahApiService =
      PrayerSurahApiService(baseUrl: 'http://localhost:3000');
  final PrayerSurahStudentApiService prayerSurahStudentApiService =
      PrayerSurahStudentApiService(baseUrl: 'http://localhost:3000');
  final classApi.ApiService classService =
      classApi.ApiService(baseUrl: 'http://localhost:3000');

  Student? student;
  List<Map<String, dynamic>> assignedPrayers = [];
  Map<int, Map<String, dynamic>> trackingData = {};
  String? errorMessage;
  bool isLoading = true;
  Uint8List? studentImage;
  String? selectedClass;

  int? classId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => isLoading = true);

      // Önce öğrenci ve sınıf bilgilerini yükle
      await _loadStundent(widget.studentId);

      // Sonra diğer verileri paralel yükle
      await Future.wait([
        _loadStudentImage(widget.studentId),
        _loadAssignedPrayerSurah(widget.studentId),
        _loadTrackingData(widget.studentId),
      ]);
    } catch (e) {
      setState(() {
        errorMessage = 'Veri yüklenirken hata oluştu: ${e.toString()}';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  // getStudentImage fonksiyonunu güncelleyelim
  Future<Uint8List> getStudentImage(int id) async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/student/$id/image'));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Resim yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Resim yükleme hatası: $e');
      throw Exception('Resim yüklenemedi: $e');
    }
  }

  void _showCommentDialog(int prayerSurahId, String currentComment) {
    TextEditingController controller =
        TextEditingController(text: currentComment);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Değerlendirme Ekle/Düzenle'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Değerlendirme yazın...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadStundent(int studentId) async {
    try {
      final studentdetail =
          await studentControlApiService.getStudentById(studentId);
      setState(() {
        student = studentdetail;
        classId = student!.sinifId;
        if (classId != null) {
          _loadClass(classId);
        }
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
      });
    }
  }

  Future<void> _loadClass(classId) async {
    try {
      final className = await classService.getClassById(classId);

      setState(() {
        selectedClass = className.sinifAdi;
      });
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  Future<void> _loadAssignedPrayerSurah(int studentId) async {
    try {
      final prayerSurahList = await prayerSurahStudentApiService
          .getPrayerSurahStudentByStudentId(studentId);

      if (mounted) {
        setState(() {
          assignedPrayers.clear();
        });

        // Her bir dua/sure için detay bilgisini çek
        for (var prayer in prayerSurahList) {
          try {
            final duaSureId = prayer['dua_sure_id'];
            if (duaSureId != null) {
              // Dua/Sure detayını çek
              final duaSureDetail =
                  await prayerSurahApiService.getPrayerSurahById(duaSureId);

              if (mounted) {
                setState(() {
                  assignedPrayers.add({
                    'id': prayer['id']?.toString() ?? '',
                    'dua_sure_id': duaSureId.toString(),
                    'dua_sure_adi': duaSureDetail['dua_sure_adi'] ?? 'İsimsiz',
                  });
                });
              }
            }
          } catch (detailError) {
            print('Dua/Sure detay yükleme hatası: $detailError');
          }
        }
      }
    } catch (e) {
      print('Prayer Surah liste yükleme hatası: $e');
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
        });
      }
    }
  }

  // Resim yükleme fonksiyonunu güncelleyelim
  Future<void> _loadStudentImage(int studentId) async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/student/$studentId/image'));
      if (response.statusCode == 200) {
        setState(() {
          studentImage = response.bodyBytes;
        });
      }
    } catch (e) {
      print('Öğrenci resmi yüklenirken hata: $e');
    }
  }

  Future<void> _loadTrackingData(int studentId) async {
    try {
      final trackingDataList = await prayerSurahTrackingApiService
          .getPrayerSurahTrackingsByStudentId(studentId);

      if (mounted) {
        setState(() {
          trackingData.clear();
          for (var tracking in trackingDataList) {
            final prayerSurahId =
                tracking['prayer_surah_student']?['dua_sure_id'];
            if (prayerSurahId != null) {
              trackingData[prayerSurahId] = {
                'status': tracking['durum'] == "Okudu" ? "+" : "-",
                'comment': tracking['degerlendirme']?.toString() ?? "",
                'dua_sure_adi': tracking['prayer_surah_student']
                        ?['prayer_surah']?['dua_sure_adi'] ??
                    'İsimsiz',
              };
              // Debug için
              print(
                  'Added tracking for $prayerSurahId: ${trackingData[prayerSurahId]}');
            }
          }
        });
      }
    } catch (e) {
      print('Tracking Data Error: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Takip verileri yüklenirken hata oluştu: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (errorMessage != null) {
      return Scaffold(
          appBar: AppBar(), body: Center(child: Text(errorMessage!)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(student!.adSoyad ?? 'Öğrenci Takip'),
      ),
      body: Row(
        children: [
          // Sol taraf - Öğrenci bilgileri
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildStudentInfo(),
                  const SizedBox(height: 20),
                  _buildTrackingTable(),
                ],
              ),
            ),
          ),
          // Sağ taraf - PDF önizleme
          Expanded(
            flex: 2,
            child: _buildPDFPreview(),
          ),
        ],
      ),
    );
  }

  Widget _buildPDFPreview() {
    return FutureBuilder<pw.Document>(
      future: _generatePDF(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
              child: Text('PDF oluşturulurken hata: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('PDF oluşturulamadı'));
        }

        return PdfPreview(
          build: (format) => snapshot.data!.save(),
          maxPageWidth: 700,
          actions: [
            PdfPreviewAction(
              icon: Image.asset(
                'assets/icons/pdf(1).png',
                width: 24,
                height: 24,
              ),
              onPressed: (context, build, pageFormat) async {
                // Updated this line
                await _savePDF();
              },
            ),
          ],
          scrollViewDecoration: BoxDecoration(
            color: Colors.grey.shade200,
          ),
        );
      },
    );
  }

  Future<pw.Document> _generatePDF() async {
    try {
      final pdf = pw.Document();

      // Font yükleme işlemi
      final fontData = await rootBundle.load("assets/DejaVuSans.ttf");
      final ttf = pw.Font.ttf(fontData.buffer.asByteData());
      final boldFontData = await rootBundle.load("assets/dejavu-sans-bold.ttf");
      final boldTtf = pw.Font.ttf(boldFontData.buffer.asByteData());

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Başlık
                pw.Center(
                  child: pw.Text(
                    '${student!.adSoyad ?? 'Öğrenci'} Dua/Sure Takip Raporu',
                    style: pw.TextStyle(
                        font: boldTtf,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Öğrenci Bilgileri
                pw.Row(children: [
                  if (studentImage != null)
                    pw.Container(
                      width: 50,
                      height: 80,
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Image(pw.MemoryImage(studentImage!),
                          width: 100, height: 150),
                    ),
                  pw.SizedBox(width: 70),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(5)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                            'Öğrenci Adı: ${student!.adSoyad ?? 'Belirtilmemiş'}',
                            style: pw.TextStyle(font: ttf, fontSize: 12)),
                        pw.Text(
                            'Öğrenci No: ${student!.ogrenciNo ?? 'Belirtilmemiş'}',
                            style: pw.TextStyle(font: ttf, fontSize: 12)),
                        pw.Text('Sınıf: ${selectedClass ?? 'Belirtilmemiş'}',
                            style: pw.TextStyle(font: ttf, fontSize: 12)),
                      ],
                    ),
                  ),
                ]),

                pw.SizedBox(height: 20),

                // Takip Tablosu
                if (assignedPrayers.isNotEmpty) ...[
                  // Dua/Sure Tablosu - 3 sütunlu güncelleme
                  pw.Table(
                    border: pw.TableBorder.all(),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(2), // Dua/Sure Adı
                      1: const pw.FlexColumnWidth(1), // Durum
                      2: const pw.FlexColumnWidth(3), // Değerlendirme
                    },
                    children: [
                      // Tablo Başlığı
                      pw.TableRow(
                        decoration: pw.BoxDecoration(color: PdfColors.grey300),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Dua/Sure Adı',
                                style: pw.TextStyle(
                                    font: boldTtf,
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Durum',
                                style: pw.TextStyle(
                                    font: boldTtf,
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text('Değerlendirme',
                                style: pw.TextStyle(
                                    font: boldTtf,
                                    fontWeight: pw.FontWeight.bold)),
                          ),
                        ],
                      ),
                      // Dua/Sure Satırları
                      ...assignedPrayers.map((prayer) {
                        final duaSureId =
                            int.tryParse(prayer['dua_sure_id'] ?? '0');
                        final trackingInfo = trackingData[duaSureId];

                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  trackingInfo?['dua_sure_adi'] ??
                                      prayer['dua_sure_adi'] ??
                                      'İsimsiz',
                                  style: pw.TextStyle(font: ttf)),
                            ),
                            pw.Center(
                              child: pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(trackingInfo?['status'] ?? '-',
                                    style: pw.TextStyle(font: boldTtf)),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(trackingInfo?['comment'] ?? ' ',
                                  style: pw.TextStyle(font: ttf)),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      );

      return pdf;
    } catch (e) {
      print('PDF Generation Error: $e');
      throw Exception('PDF oluşturulurken hata oluştu: $e');
    }
  }

  Future<void> _savePDF() async {
    try {
      final pdf = await _generatePDF();
      final fileName =
          '${student!.adSoyad ?? 'ogrenci'}_dua_sure_takip_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final result = await FilePicker.platform.saveFile(
        fileName: fileName,
        allowedExtensions: ['pdf'],
        type: FileType.custom,
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsBytes(await pdf.save());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF başarıyla kaydedildi')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF kaydedilirken hata oluştu: $e')),
        );
      }
    }
  }

  Widget _buildStudentInfo() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[200],
              foregroundImage:
                  studentImage != null ? MemoryImage(studentImage!) : null,
              child: studentImage == null
                  ? const Icon(Icons.person, size: 40, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student!.adSoyad?.toString() ?? '',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text('Sınıf: ${selectedClass ?? ''}'),
                  Text('Öğrenci No: ${student!.ogrenciNo?.toString() ?? ''}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Dua/Sure Adı')),
          DataColumn(label: Text('Durum')),
        ],
        rows: assignedPrayers.map((prayer) {
          final duaSureId =
              int.tryParse(prayer['dua_sure_id']?.toString() ?? '0') ?? 0;
          final status = trackingData[duaSureId]?['status'] ?? '-';

          return DataRow(
            cells: [
              DataCell(Text(prayer['dua_sure_adi'] ?? 'İsimsiz')),
              DataCell(
                status == '+'
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.cancel, color: Colors.red),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
