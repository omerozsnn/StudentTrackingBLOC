import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ogrenci_takip_sistemi/widgets/deneme_sinavi/deneme_score_dialog.dart';

class DenemePdfService {
  static Future<Uint8List> generatePDFReport({
    required List<dynamic> students,
    required List<dynamic> denemeList,
    required List<dynamic> units,
    required String selectedClass,
    required String selectedUnit,
    required Map<int, Map<int, DenemeScores>> studentDenemeScores,
  }) async {
    try {
      final pdf = pw.Document();
      final fontData = await rootBundle.load("assets/DejaVuSans.ttf");
      final ttf = pw.Font.ttf(fontData.buffer.asByteData());
      final boldFontData = await rootBundle.load("assets/dejavu-sans-bold.ttf");
      final boldTtf = pw.Font.ttf(boldFontData.buffer.asByteData());

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              // Başlık - kompakt
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 10),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      '$selectedClass - ${units.firstWhere((u) => u['id'].toString() == selectedUnit)?['ünite_adı']} Deneme Sınavı Raporu',
                      style: pw.TextStyle(
                          font: boldTtf,
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      'Toplam Soru: ${_getTotalQuestionCount(denemeList)}',
                      style: pw.TextStyle(font: boldTtf, fontSize: 8),
                    ),
                  ],
                ),
              ),

              // Deneme Tablosu - kompakt
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                columnWidths: {
                  0: const pw.FlexColumnWidth(0.7), // No
                  1: const pw.FlexColumnWidth(2), // İsim
                  for (var i = 0; i < denemeList.length; i++)
                    i + 2: const pw.FlexColumnWidth(1.2), // Denemeler
                  2 + denemeList.length:
                      const pw.FlexColumnWidth(0.8), // Toplam
                  3 + denemeList.length:
                      const pw.FlexColumnWidth(0.8), // Ortalama
                },
                children: [
                  // Tablo başlığı
                  pw.TableRow(
                    decoration:
                        const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _buildHeaderCell('No', boldTtf),
                      _buildHeaderCell('Öğrenci Adı', boldTtf),
                      ...denemeList.map((deneme) => pw.Container(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Column(
                              children: [
                                pw.Text(
                                    deneme['denemeSinavi']['deneme_sinavi_adi'],
                                    style: pw.TextStyle(
                                        font: boldTtf,
                                        fontSize: 6,
                                        fontWeight: pw.FontWeight.bold),
                                    textAlign: pw.TextAlign.center),
                                pw.Text(
                                    '(${deneme['denemeSinavi']['soru_sayisi']} soru)',
                                    style: pw.TextStyle(
                                        font: boldTtf, fontSize: 4),
                                    textAlign: pw.TextAlign.center),
                              ],
                            ),
                          )),
                      _buildHeaderCell('Toplam', boldTtf),
                      _buildHeaderCell('Ortalama', boldTtf),
                    ],
                  ),
                  // Öğrenci satırları
                  ...students.map((student) {
                    return pw.TableRow(
                      children: [
                        _buildCell(student.ogrenciNo?.toString() ?? '', ttf),
                        _buildCell(student.adSoyad ?? '', ttf),
                        ...denemeList.map((deneme) {
                          var denemeScores = studentDenemeScores[student.id]
                              ?[deneme['deneme_sinavi_id']];
                          return pw.Container(
                            padding: const pw.EdgeInsets.all(2),
                            child: pw.Column(
                              children: [
                                pw.Text(
                                  denemeScores != null
                                      ? '${denemeScores.puan}'
                                      : '-',
                                  style: pw.TextStyle(
                                      font: boldTtf,
                                      fontSize: 8,
                                      fontWeight: pw.FontWeight.bold),
                                  textAlign: pw.TextAlign.center,
                                ),
                                if (denemeScores != null)
                                  pw.Text(
                                      'D:${denemeScores.dogru} Y:${denemeScores.yanlis} B:${denemeScores.bos}',
                                      style:
                                          pw.TextStyle(font: ttf, fontSize: 5),
                                      textAlign: pw.TextAlign.center),
                              ],
                            ),
                          );
                        }),
                        _buildCell(
                            _calculateTotalScore(
                                    student.id, studentDenemeScores)
                                .toString(),
                            ttf,
                            fontSize: 10),
                        _buildCell(
                          _calculateAverageScore(
                                  student.id, studentDenemeScores)
                              .toStringAsFixed(1),
                          ttf,
                          fontSize: 10,
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ];
          },
        ),
      );

      return pdf.save();
    } catch (e) {
      print('PDF oluşturma hatası: $e');
      throw Exception('PDF oluşturulurken hata oluştu: $e');
    }
  }

  // PDF generation helpers
  static pw.Widget _buildHeaderCell(String text, pw.Font ttf) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2),
      child: pw.Text(text,
          style: pw.TextStyle(
              font: ttf, fontSize: 8, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center),
    );
  }

  static pw.Widget _buildCell(String text, pw.Font ttf, {double fontSize = 8}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2),
      child: pw.Text(text,
          style: pw.TextStyle(font: ttf, fontSize: fontSize),
          textAlign: pw.TextAlign.left),
    );
  }

  // Calculation methods
  static int _getTotalQuestionCount(List<dynamic> denemeList) {
    int totalQuestions = 0;
    for (var deneme in denemeList) {
      var soruSayisi = deneme['denemeSinavi']['soru_sayisi'];
      if (soruSayisi != null) {
        totalQuestions += soruSayisi as int;
      }
    }
    return totalQuestions;
  }

  static int _calculateTotalScore(
      int studentId, Map<int, Map<int, DenemeScores>> studentDenemeScores) {
    if (!studentDenemeScores.containsKey(studentId)) return 0;
    return studentDenemeScores[studentId]!
        .values
        .fold(0, (sum, score) => sum + score.puan);
  }

  static double _calculateAverageScore(
      int studentId, Map<int, Map<int, DenemeScores>> studentDenemeScores) {
    if (!studentDenemeScores.containsKey(studentId) ||
        studentDenemeScores[studentId]!.isEmpty) return 0.0;

    int totalScore = _calculateTotalScore(studentId, studentDenemeScores);
    int totalDeneme = studentDenemeScores[studentId]!.length;
    return totalDeneme > 0 ? totalScore / totalDeneme : 0.0;
  }
}
