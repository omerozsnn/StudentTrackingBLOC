import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';
import 'package:collection/collection.dart';

class OkulDenemeleriPdfScreen extends StatefulWidget {
  final List<dynamic> students;
  final List<dynamic> denemeler;
  final List<dynamic> ogrenciDenemeleri;
  final String selectedClass;

  const OkulDenemeleriPdfScreen({
    Key? key,
    required this.students,
    required this.denemeler,
    required this.ogrenciDenemeleri,
    required this.selectedClass,
  }) : super(key: key);

  @override
  State<OkulDenemeleriPdfScreen> createState() =>
      _OkulDenemeleriPdfScreenState();
}

class _OkulDenemeleriPdfScreenState extends State<OkulDenemeleriPdfScreen> {
  bool isLoading = true;
  Uint8List? pdfBytes;

  @override
  void initState() {
    super.initState();
    generatePdf();
  }

  Future<void> generatePdf() async {
    try {
      setState(() {
        isLoading = true;
      });

      final fontData = await rootBundle.load("assets/DejaVuSans.ttf");
      final ttf = pw.Font.ttf(fontData);

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a3.landscape,
          build: (pw.Context context) {
            return [
              pw.Container(
                color: PdfColors.blue,
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  '${widget.selectedClass} Sınıfı Deneme Sonuçları',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border:
                    pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.blueAccent),
                    children: [
                      _tableHeader('No', ttf),
                      _tableHeader('Adı Soyadı', ttf, alignLeft: true),
                      ...widget.denemeler.map((deneme) => pw.Column(
                            children: [
                              _tableHeader(deneme['sinav_adi'], ttf),
                              pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceEvenly,
                                children: [
                                  _tableHeader('D', ttf),
                                  _tableHeader('Y', ttf),
                                  _tableHeader('N', ttf),
                                ],
                              ),
                            ],
                          )),
                    ],
                  ),
                  ...widget.students.mapIndexed((index, student) {
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color:
                            index.isEven ? PdfColors.white : PdfColors.grey100,
                      ),
                      children: [
                        _tableCell(student['ogrenci_no'].toString(), ttf,
                            PdfColors.white,
                            alignLeft: true),
                        _tableCell(student['ad_soyad'], ttf, PdfColors.white,
                            alignLeft: true),
                        ...widget.denemeler.map((deneme) {
                          var ogrenciDeneme =
                              widget.ogrenciDenemeleri.firstWhere(
                            (sonuc) =>
                                sonuc['ogrenci_id'] == student['id'] &&
                                sonuc['okul_deneme_sinavi_id'] == deneme['id'],
                            orElse: () => null,
                          );
                          return _denemeCell(ogrenciDeneme, ttf);
                        }),
                      ],
                    );
                  }),
                ],
              ),
            ];
          },
        ),
      );

      final pdfData = await pdf.save();

      setState(() {
        pdfBytes = pdfData;
        isLoading = false;
      });
    } catch (e) {
      print('PDF oluşturma hatası: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  pw.Widget _tableHeader(String text, pw.Font ttf, {bool alignLeft = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      alignment: alignLeft ? pw.Alignment.centerLeft : pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: ttf,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  pw.Widget _tableCell(String text, pw.Font ttf, PdfColor color,
      {bool alignLeft = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      alignment: alignLeft ? pw.Alignment.centerLeft : pw.Alignment.center,
      color: color,
      child: pw.Text(
        text,
        style: pw.TextStyle(font: ttf, fontSize: 8),
      ),
    );
  }

  pw.Widget _denemeCell(dynamic ogrenciDeneme, pw.Font ttf) {
    bool sinavaGirmemis = ogrenciDeneme == null;
    return pw.Container(
      padding: const pw.EdgeInsets.all(3),
      alignment: pw.Alignment.center,
      color: sinavaGirmemis ? PdfColors.red100 : PdfColors.white,
      child: sinavaGirmemis
          ? pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                pw.Text('GİRMEDİ',
                    style: pw.TextStyle(
                        font: ttf, fontSize: 8, color: PdfColors.red)),
                pw.Text('⚠',
                    style: pw.TextStyle(
                        font: ttf, fontSize: 12, color: PdfColors.orange)),
              ],
            )
          : pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                pw.Text(ogrenciDeneme['dogru_sayisi'].toString(),
                    style: pw.TextStyle(
                        font: ttf, fontSize: 8, color: PdfColors.green)),
                pw.Text(ogrenciDeneme['yanlis_sayisi'].toString(),
                    style: pw.TextStyle(
                        font: ttf, fontSize: 8, color: PdfColors.red)),
                pw.Text(ogrenciDeneme['net'].toStringAsFixed(2),
                    style: pw.TextStyle(
                        font: ttf, fontSize: 8, color: PdfColors.blue)),
              ],
            ),
    );
  }

  Future<void> savePdfToFile() async {
    if (pdfBytes == null) return;
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      final file = File('$selectedDirectory/deneme_sonuclari.pdf');
      await file.writeAsBytes(pdfBytes!);
      OpenFile.open(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Önizleme'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pdfBytes != null
              ? PdfPreview(
                  build: (format) => pdfBytes!,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  actions: [
                    PdfPreviewAction(
                      icon: Image.asset(
                        'assets/icons/pdf(1).png',
                        width: 24,
                        height: 24,
                      ),
                      onPressed: (context, build, pageFormat) async {
                        await savePdfToFile();
                      },
                    ),
                  ],
                  previewPageMargin: const EdgeInsets.all(16),
                  scrollViewDecoration: BoxDecoration(
                    color: Colors.grey.shade200,
                  ),
                )
              : const Center(child: Text('PDF oluşturulamadı')),
    );
  }
}
