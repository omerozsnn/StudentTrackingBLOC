import 'dart:typed_data';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:open_file/open_file.dart';

enum PDFReportType {
  studentSummary, // Öğrenci bazlı kısa rapor
  classWeekly, // Sınıf bazlı haftalık rapor
  classMonthly, // Sınıf bazlı aylık rapor
  studentDetailed,
  excelStyle // Öğrenci bazlı detaylı rapor
}

class ClassInfo {
  final int id;
  final String name;
  ClassInfo({required this.id, required this.name});
}

class Students {
  final int id;
  final String name;
  final String studentNumber;

  Students({required this.id, required this.name, this.studentNumber = ''});
}

enum Course {
  TURKCE,
  MATEMATIK,
  FEN,
  SOSYAL,
  INGILIZCE,
  DIKAB,
}

class DailyTrackingReport {
  // PDF ayarları
  final PdfPageFormat pageFormat;
  final String title;

  // Rapor verileri
  final ClassInfo classInfo;
  final List<Students> students;
  final Map<int, Map<String, Map<Course, int>>> trackingData;
  final Map<int, Map<int, Map<Course, int>>> weeklyData;
  final DateTime reportDate;
  final PDFReportType reportType;

  DailyTrackingReport({
    this.pageFormat = PdfPageFormat.a4,
    required this.title,
    required this.classInfo,
    required this.students,
    required this.trackingData,
    required this.weeklyData,
    required this.reportDate,
    this.reportType = PDFReportType.classMonthly,
  });

  // Ders adı dönüştürücü
  String _getCourseDisplayName(Course course, {bool shortened = false}) {
    if (shortened) {
      switch (course) {
        case Course.TURKCE:
          return 'TÜR';
        case Course.MATEMATIK:
          return 'MAT';
        case Course.FEN:
          return 'FEN';
        case Course.SOSYAL:
          return 'SOS';
        case Course.INGILIZCE:
          return 'İNG';
        case Course.DIKAB:
          return 'DİN';
        default:
          return course.toString().substring(0, 3);
      }
    } else {
      switch (course) {
        case Course.TURKCE:
          return 'TÜRKÇE';
        case Course.MATEMATIK:
          return 'MATEMATİK';
        case Course.FEN:
          return 'FEN BİLİMLERİ';
        case Course.SOSYAL:
          return 'SOSYAL BİLGİLER';
        case Course.INGILIZCE:
          return 'İNGİLİZCE';
        case Course.DIKAB:
          return 'DİKAB';
        default:
          return course.toString();
      }
    }
  }

  // Gün adı kısaltmasını getiren yardımcı fonksiyon
  String _getAbbreviatedDayName(int weekday) {
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

  // Ders renkleri
  PdfColor _getCourseColor(Course course) {
    switch (course) {
      case Course.TURKCE:
        return PdfColors.red200;
      case Course.MATEMATIK:
        return PdfColors.blue200;
      case Course.FEN:
        return PdfColors.green200;
      case Course.SOSYAL:
        return PdfColors.orange200;
      case Course.INGILIZCE:
        return PdfColors.purple200;
      case Course.DIKAB:
        return PdfColors.brown200;
      default:
        return PdfColors.grey300;
    }
  }

  // Öğrenci aylık toplam soru sayısı hesaplama
  int _calculateStudentMonthlyTotal(int studentId) {
    int total = 0;
    trackingData[studentId]?.forEach((date, courses) {
      courses.forEach((course, count) {
        total += count;
      });
    });
    return total;
  }

  // Öğrenci ders toplam hesaplama
  int _calculateCourseTotalForStudent(int studentId, Course course) {
    int total = 0;
    trackingData[studentId]?.forEach((date, courses) {
      total += courses[course] ?? 0;
    });
    return total;
  }

  // Haftalık toplam hesaplama
  int _calculateWeekTotalForStudent(int studentId, int weekNum) {
    int total = 0;
    if (weeklyData[studentId]?[weekNum] != null) {
      weeklyData[studentId]![weekNum]!.forEach((course, value) {
        total += value;
      });
    }
    return total;
  }

  // Belirli bir ders için haftalık toplam
  int _calculateCourseWeekTotal(int studentId, int weekNum, Course course) {
    return weeklyData[studentId]?[weekNum]?[course] ?? 0;
  }

  // PDF dökümanı oluştur ve kaydeder
  Future<Uint8List> generatePdf() async {
    final pdf = pw.Document(
      title: title,
      author: 'Öğrenci Takip Sistemi',
      creator: 'Öğrenci Takip Sistemi',
      subject: 'Öğrenci Günlük Takip Raporu',
    );

    // Yazı tipleri
    final ttf = await PdfGoogleFonts.nunitoRegular();
    final ttfBold = await PdfGoogleFonts.nunitoBold();
    final ttfItalic = await PdfGoogleFonts.nunitoItalic();

    // Yazı tipi teması
    final theme = pw.ThemeData.withFont(
      base: ttf,
      bold: ttfBold,
      italic: ttfItalic,
    );

    switch (reportType) {
      case PDFReportType.classMonthly:
        _addClassMonthlyReport(pdf, theme);
        break;
      case PDFReportType.classWeekly:
        _addClassWeeklyReport(pdf, theme);
        break;
      case PDFReportType.studentSummary:
        _addStudentSummaryReport(pdf, theme);
        break;
      case PDFReportType.studentDetailed:
        _addStudentDetailedReport(pdf, theme);
        break;
      case PDFReportType.excelStyle:
        await _addExcelStyleReport(pdf, theme);
        break;
    }

    return pdf.save();
  }

  // PDF dosyasını kaydet ve aç
  Future<String> savePdfAndOpen() async {
    try {
      final output = await getTemporaryDirectory(); // Yedek olarak temp klasör
      final reportType = this.reportType.toString().split('.').last;
      final fileName =
          '${classInfo.name}_${reportType}_${DateFormat('yyyyMMdd').format(reportDate)}.pdf';

      // Kullanıcının klasör seçmesini sağla
      String? outputDir = await FilePicker.platform.getDirectoryPath();
      if (outputDir == null) {
        // Klasör seçimi iptal edildiyse işlemi sonlandır
        print('Kullanıcı klasör seçimini iptal etti.');
        return '';
      }

      final file = File('$outputDir/$fileName');

      // PDF dosyasını oluştur
      final pdfBytes = await generatePdf();

      // Dosyaya yaz
      await file.writeAsBytes(pdfBytes);

      // Dosyayı aç (isteğe bağlı)
      await OpenFile.open(file.path);

      return file.path;
    } catch (e) {
      print('PDF kaydedilirken hata oluştu: $e');
      return '';
    }
  }

  // PDF dosyasını yazdır
  Future<void> printPdf() async {
    try {
      final pdfBytes = await generatePdf();
      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
        name:
            'Öğrenci Takip Raporu - ${DateFormat('dd.MM.yyyy').format(reportDate)}',
      );
    } catch (e) {
      print('PDF yazdırılırken hata oluştu: $e');
    }
  }

  Future<void> _addExcelStyleReport(pw.Document pdf, pw.ThemeData theme) async {
    // Ayın günlerini al
    final days = _getMonthDays();
    final reportDateStr = DateFormat('dd.MM.yyyy').format(reportDate);
    final monthYearStr = DateFormat('MMMM yyyy', 'tr_TR').format(reportDate);

    // Dinamik olarak öğrenci sayısına ve gün sayısına göre ölçekleme hesapla
    final int totalDays = days.length;
    final int studentCount = students.length;

    // Sayfa başına öğrenci sayısını dinamik olarak belirle
    int studentsPerPage = _calculateOptimalStudentsPerPage(totalDays);

    // Toplam sayfa sayısını hesapla
    final int pageCount = (studentCount / studentsPerPage).ceil();

    // Excel stilindeki başlık için
    final headerDesign = pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.lightBlue100,
        border: pw.Border.all(color: PdfColors.blue800, width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            '${classInfo.name} SINIFI SORU ÇÖZÜMÜ TAKİP LİSTESİ',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Ay: $monthYearStr',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.blue800)),
              pw.Text('Rapor Tarihi: $reportDateStr',
                  style: pw.TextStyle(
                      fontSize: 8,
                      fontStyle: pw.FontStyle.italic,
                      color: PdfColors.blue700)),
            ],
          ),
        ],
      ),
    );

    // Öğrenci listesini sayfalara bölelim
    for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
      final int startStudentIndex = pageIndex * studentsPerPage;
      final int endStudentIndex = (pageIndex + 1) * studentsPerPage;
      final List<Students> pageStudents = students.sublist(startStudentIndex,
          endStudentIndex > studentCount ? studentCount : endStudentIndex);

      // Bu sayfa için Excel stil tablosunu oluştur
      final excelTable = await _buildExcelStyleClassTable(
          days, pageStudents, pageIndex + 1, pageCount, totalDays);

      // Sayfayı oluştur
      pdf.addPage(
        pw.Page(
          theme: theme,
          pageFormat: pageFormat.landscape, // Yatay sayfa kullan
          margin: const pw.EdgeInsets.all(10), // Daha küçük kenar boşluğu
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                headerDesign,
                pw.SizedBox(height: 4),
                // Sayfa numarası bilgisi (birden fazla sayfa varsa)
                if (pageCount > 1)
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(
                      'Sayfa ${pageIndex + 1} / $pageCount',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontStyle: pw.FontStyle.italic,
                        color: PdfColors.blue700,
                      ),
                    ),
                  ),
                // Excel benzeri tablo
                excelTable,
              ],
            );
          },
        ),
      );
    }
  }

// Gün sayısına göre optimal sayfa başına öğrenci sayısını hesapla
  int _calculateOptimalStudentsPerPage(int dayCount) {
    if (dayCount >= 31) {
      return 3; // Çok fazla gün varsa, sayfa başına sadece 3 öğrenci
    } else if (dayCount >= 25) {
      return 4; // 25-29 gün için 4 öğrenci
    } else if (dayCount >= 20) {
      return 6; // 20-24 gün için 6 öğrenci
    } else if (dayCount >= 15) {
      return 8; // 15-19 gün için 8 öğrenci
    } else {
      return 10; // 14 veya daha az gün için 10 öğrenci
    }
  }

  Future<pw.Widget> _buildExcelStyleClassTable(
    List<int> days,
    List<Students> pageStudents,
    int pageNumber,
    int totalPages,
    int totalDays,
  ) async {
    // 1) Sütun genişlikleri (sadece sağdaki alt tablo için)
    final double dayCellWidth = _calculateOptimalCellWidth(totalDays);
    final double courseColumnWidth = 40.0;
    final double totalColumnWidth = 40.0;
    final double cellHeight = 15.0;

    // "Ders" + (gün sayısı) + "TOP" sütunları
    // => 1 + days.length + 1 = days.length + 2 sütun
    final Map<int, pw.TableColumnWidth> subtableColumnWidths = {
      0: pw.FixedColumnWidth(courseColumnWidth), // Ders sütunu
      for (int i = 0; i < days.length; i++)
        i + 1: pw.FixedColumnWidth(dayCellWidth), // Gün sütunları
      days.length + 1: pw.FixedColumnWidth(totalColumnWidth), // TOP sütunu
    };

    // 2) "Header" (tek satır) oluşturalım: [Ders] [Gün1] [Gün2] ... [TOP]
    final headerRowCells = <pw.Widget>[];

    // Ders başlığı
    headerRowCells.add(
      pw.Container(
        height: cellHeight,
        alignment: pw.Alignment.center,
        color: PdfColors.lightBlue200,
        child: pw.Text(
          'Ders',
          style: pw.TextStyle(
            fontSize: 6,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
      ),
    );

    // Gün başlıkları
    for (final day in days) {
      final date = DateTime(reportDate.year, reportDate.month, day);
      final bool isWeekend = date.weekday > 5;
      headerRowCells.add(
        pw.Container(
          height: cellHeight,
          alignment: pw.Alignment.center,
          color: isWeekend ? PdfColors.amber100 : PdfColors.lightBlue100,
          child: pw.Text(
            day.toString(),
            style: pw.TextStyle(
              fontSize: 5,
              fontWeight: pw.FontWeight.bold,
              color: isWeekend ? PdfColors.orange800 : PdfColors.blue800,
            ),
          ),
        ),
      );
    }

    // TOP başlığı
    headerRowCells.add(
      pw.Container(
        height: cellHeight,
        alignment: pw.Alignment.center,
        color: PdfColors.green100,
        child: pw.Text(
          'TOP',
          style: pw.TextStyle(
            fontSize: 6,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green900,
          ),
        ),
      ),
    );

    // Tek satırlık tablo (başlık)
    final headerSubtable = pw.Table(
      columnWidths: subtableColumnWidths,
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.blue300),
      children: [
        pw.TableRow(children: headerRowCells),
      ],
    );

    // 3) Dış tabloya ilk satır olarak "Öğrenci" başlığı + "Header Subtable" ekleyelim
    // Dış tablonun soldaki sütun genişliğini siz belirleyebilirsiniz (örneğin 80.0).
    final double studentColumnWidth = 80.0;

    final outerTableRows = <pw.TableRow>[];

    // Row 0: Başlık
    outerTableRows.add(
      pw.TableRow(
        children: [
          // Solda "Öğrenci" başlığı
          pw.Container(
            width: studentColumnWidth,
            height: cellHeight,
            alignment: pw.Alignment.center,
            color: PdfColors.lightBlue200,
            child: pw.Text(
              'Öğrenci',
              style: pw.TextStyle(
                fontSize: 6,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
          ),
          // Sağda "headerSubtable"
          headerSubtable,
        ],
      ),
    );

    // 4) Her öğrenci için bir satır: solda öğrenci bilgisi, sağda data subtable
    for (final student in pageStudents) {
      // Sağ taraf tablo: her ders için satır + en sonda "TOPLAM" satırı
      final dataRows = <pw.TableRow>[];

      // Her derse ait satır
      for (final course in Course.values) {
        final rowCells = <pw.Widget>[];

        // Ders hücresi
        rowCells.add(
          pw.Container(
            height: cellHeight,
            alignment: pw.Alignment.centerLeft,
            color: _getCourseColor(course),
            child: pw.Text(
              _getCourseDisplayName(course, shortened: true),
              style: pw.TextStyle(
                fontSize: 6,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        );

        // Günlük değer hücreleri
        for (final day in days) {
          final date = DateTime(reportDate.year, reportDate.month, day);
          final bool isWeekend = date.weekday > 5;
          final String dateStr = DateFormat('yyyy-MM-dd').format(date);
          final int value = trackingData[student.id]?[dateStr]?[course] ?? 0;
          rowCells.add(
            pw.Container(
              height: cellHeight,
              alignment: pw.Alignment.center,
              color: value > 0
                  ? _getCourseColor(course)
                  : (isWeekend ? PdfColors.grey100 : PdfColors.white),
              child: value > 0
                  ? pw.Text(
                      value.toString(),
                      style: pw.TextStyle(
                        fontSize: 6,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    )
                  : pw.SizedBox(),
            ),
          );
        }

        // Ders toplamı
        final int courseTotal =
            _calculateCourseTotalForStudent(student.id, course);
        rowCells.add(
          pw.Container(
            height: cellHeight,
            alignment: pw.Alignment.center,
            color: _getCourseColor(course),
            child: pw.Text(
              courseTotal.toString(),
              style: pw.TextStyle(
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        );

        dataRows.add(pw.TableRow(children: rowCells));
      }

      // "TOPLAM" satırı (öğrencinin tüm dersler için)
      final totalRowCells = <pw.Widget>[];

      // Ders hücresi yerine "TOPLAM" yazalım
      totalRowCells.add(
        pw.Container(
          height: cellHeight,
          alignment: pw.Alignment.center,
          color: PdfColors.yellow200,
          child: pw.Text(
            'TOPLAM',
            style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold),
          ),
        ),
      );

      // Günlük toplamlar (tüm dersler)
      for (final day in days) {
        final date = DateTime(reportDate.year, reportDate.month, day);
        final String dateStr = DateFormat('yyyy-MM-dd').format(date);
        int dayTotal = 0;
        if (trackingData[student.id]?[dateStr] != null) {
          trackingData[student.id]![dateStr]!.forEach((_, count) {
            dayTotal += count;
          });
        }
        totalRowCells.add(
          pw.Container(
            height: cellHeight,
            alignment: pw.Alignment.center,
            color: dayTotal > 0 ? PdfColors.orange200 : PdfColors.yellow50,
            child: dayTotal > 0
                ? pw.Text(
                    dayTotal.toString(),
                    style: pw.TextStyle(
                        fontSize: 7, fontWeight: pw.FontWeight.bold),
                  )
                : pw.SizedBox(),
          ),
        );
      }

      // Aylık toplam
      final int monthlyTotal = _calculateStudentMonthlyTotal(student.id);
      totalRowCells.add(
        pw.Container(
          height: cellHeight,
          alignment: pw.Alignment.center,
          color: PdfColors.orange300,
          child: pw.Text(
            monthlyTotal.toString(),
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ),
      );

      dataRows.add(pw.TableRow(children: totalRowCells));

      // Sağ taraf veri tablosu
      final dataSubtable = pw.Table(
        columnWidths: subtableColumnWidths,
        border: pw.TableBorder.all(width: 0.5, color: PdfColors.blue300),
        children: dataRows,
      );

      // Sol sütun: Öğrenci hücresi (resim + ad vs.)
      // Resim kullanacaksanız, height'i biraz artırabilirsiniz
      final double studentCellHeight = 70;
      final studentImage = await _fetchStudentImage(student.id);
      final studentInfoCell = pw.Container(
        width: studentColumnWidth,
        height: studentCellHeight,
        color: PdfColors.blue50,
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            if (studentImage != null)
              pw.Container(
                width: 40,
                height: 40,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue300, width: 0.5),
                ),
                child: pw.Image(pw.MemoryImage(studentImage),
                    fit: pw.BoxFit.cover),
              )
            else
              pw.Container(
                width: 40,
                height: 40,
                color: PdfColors.blue100,
                child: pw.Center(
                  child: pw.Text(
                    student.name.isNotEmpty ? student.name[0] : "?",
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                ),
              ),
            pw.SizedBox(height: 4),
            pw.Text(
              student.name,
              style: pw.TextStyle(
                fontSize: 6,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
          ],
        ),
      );

      // Dış tabloya bir satır ekle: sol hücre = öğrenci, sağ hücre = dataSubtable
      outerTableRows.add(
        pw.TableRow(
          children: [
            studentInfoCell,
            dataSubtable,
          ],
        ),
      );

      // Öğrenciler arasında biraz boşluk
      outerTableRows.add(
        pw.TableRow(
          children: [
            pw.Container(height: 10, color: PdfColors.white),
            pw.Container(height: 10, color: PdfColors.white),
          ],
        ),
      );
    }

    // 5) Dış tabloyu döndür
    return pw.Table(
      border: null,
      defaultVerticalAlignment: pw.TableCellVerticalAlignment.top,
      columnWidths: {
        0: pw.FixedColumnWidth(80.0), // Öğrenci sütunu
        1: pw.FlexColumnWidth(1), // Sağ taraf (subtable) esnesin
      },
      children: outerTableRows,
    );
  }

  double _calculateOptimalCellWidth(int dayCount) {
    // Genişlik değerlerini daha da küçültebilirsiniz
    if (dayCount >= 30) {
      return 13.0;
    } else if (dayCount >= 25) {
      return 15.0;
    } else if (dayCount >= 20) {
      return 18.0;
    } else if (dayCount >= 15) {
      return 20.0;
    } else {
      return 25.0;
    }
  }

  // Sınıf aylık raporu sayfaları ekle
  void _addClassMonthlyReport(pw.Document pdf, pw.ThemeData theme) {
    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return <pw.Widget>[
            _buildReportHeader(),
            pw.SizedBox(height: 20),
            _buildClassSummaryTable(),
            pw.SizedBox(height: 30),
            _buildMonthlyCourseTotalsChart(),
            pw.SizedBox(height: 20),
            _buildWeeklyProgressChart(),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 20),
            child: pw.Text(
              'Sayfa ${context.pageNumber} / ${context.pagesCount}',
              style: pw.TextStyle(
                fontSize: 10,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          );
        },
      ),
    );
  }

  // Sınıf haftalık raporu sayfaları ekle
  void _addClassWeeklyReport(pw.Document pdf, pw.ThemeData theme) {
    pdf.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return <pw.Widget>[
            _buildReportHeader(),
            pw.SizedBox(height: 20),
            _buildWeeklyClassSummaryTable(),
            pw.SizedBox(height: 30),
            _buildWeeklyCourseTotalsChart(),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 20),
            child: pw.Text(
              'Sayfa ${context.pageNumber} / ${context.pagesCount}',
              style: pw.TextStyle(
                fontSize: 8,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          );
        },
      ),
    );
  }

  // Öğrenci özet raporu sayfaları ekle
  void _addStudentSummaryReport(pw.Document pdf, pw.ThemeData theme) {
    // Her öğrenci için bir özet sayfası oluştur
    for (final student in students) {
      pdf.addPage(
        pw.Page(
          theme: theme,
          pageFormat: pageFormat,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildStudentReportHeader(student),
                pw.SizedBox(height: 20),
                _buildStudentSummaryTable(student),
                pw.SizedBox(height: 20),
                _buildStudentCourseProgressChart(student),
              ],
            );
          },
        ),
      );
    }
  }

  // Öğrenci detaylı raporu sayfaları ekle
  void _addStudentDetailedReport(pw.Document pdf, pw.ThemeData theme) {
    // Her öğrenci için detaylı rapor oluştur
    for (final student in students) {
      pdf.addPage(
        pw.MultiPage(
          theme: theme,
          pageFormat: pageFormat,
          build: (pw.Context context) {
            return <pw.Widget>[
              _buildStudentReportHeader(student),
              pw.SizedBox(height: 20),
              _buildStudentDetailedTable(student),
              pw.SizedBox(height: 20),
              _buildStudentWeeklyProgressChart(student),
              pw.SizedBox(height: 20),
              _buildStudentCourseDetailChart(student),
            ];
          },
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 20),
              child: pw.Text(
                'Sayfa ${context.pageNumber} / ${context.pagesCount}',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            );
          },
        ),
      );
    }
  }

  // Rapor başlığı oluştur
  pw.Widget _buildReportHeader() {
    final reportDateStr = DateFormat('dd.MM.yyyy').format(reportDate);
    final monthYearStr = DateFormat('MMMM yyyy', 'tr_TR').format(reportDate);

    return pw.Header(
      level: 0,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 14, // 16'dan 14'e düşürüldü
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8), // 10'dan 8'e düşürüldü
          pw.Text(
            'Sınıf: ${classInfo.name}',
            style: const pw.TextStyle(
              fontSize: 12, // 14'ten 12'ye düşürüldü
            ),
          ),
          pw.SizedBox(height: 4), // 5'ten 4'e düşürüldü
          pw.Text(
            'Ay: $monthYearStr',
            style: const pw.TextStyle(
              fontSize: 12, // 14'ten 12'ye düşürüldü
            ),
          ),
          pw.SizedBox(height: 4), // 5'ten 4'e düşürüldü
          pw.Text(
            'Rapor Tarihi: $reportDateStr',
            style: pw.TextStyle(
              fontSize: 8, // 10'dan 8'e düşürüldü
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // Öğrenci rapor başlığı oluştur
  pw.Widget _buildStudentReportHeader(Students student) {
    final reportDateStr = DateFormat('dd.MM.yyyy').format(reportDate);
    final monthYearStr = DateFormat('MMMM yyyy', 'tr_TR').format(reportDate);

    return pw.Header(
      level: 0,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'ÖĞRENCİ GÜNLÜK TAKİP RAPORU',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          // Öğrenci numarası ve adı yan yana
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              if (student.studentNumber.isNotEmpty)
                pw.Text(
                  '${student.studentNumber} - ',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              pw.Text(
                student.name,
                style: const pw.TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Sınıf: ${classInfo.name}',
            style: const pw.TextStyle(
              fontSize: 12,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Ay: $monthYearStr',
            style: const pw.TextStyle(
              fontSize: 10,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Rapor Tarihi: $reportDateStr',
            style: pw.TextStyle(
              fontSize: 8,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // Sınıf özet tablosu oluştur
  pw.Widget _buildClassSummaryTable() {
    // Tablo başlıkları
    final tableHeaders = [
      'No',
      'Öğrenci Adı',
      ...Course.values.map(_getCourseDisplayName).toList(),
      'TOPLAM',
    ];

    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.8), // Öğrenci no
        1: const pw.FlexColumnWidth(2.5), // Öğrenci adı
        ...Course.values.asMap().map(
            (i, _) => MapEntry(i + 2, const pw.FlexColumnWidth(1))), // Dersler
        Course.values.length + 2: const pw.FlexColumnWidth(1.5), // Toplam
      },
      children: [
        // Başlık satırı
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          children: tableHeaders.map((header) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(3),
              alignment: pw.Alignment.center,
              child: pw.Text(
                header,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 7,
                ),
              ),
            );
          }).toList(),
        ),
        // Öğrenci satırları
        ...students.map((student) {
          return pw.TableRow(
            children: [
              // Öğrenci No
              pw.Container(
                padding: const pw.EdgeInsets.all(3),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  student.studentNumber,
                  style: const pw.TextStyle(fontSize: 7),
                ),
              ),
              // Öğrenci adı
              pw.Container(
                padding: const pw.EdgeInsets.all(3),
                child: pw.Text(
                  student.name,
                  style: const pw.TextStyle(fontSize: 7),
                ),
              ),
              // Dersler
              ...Course.values.map((course) {
                final total =
                    _calculateCourseTotalForStudent(student.id, course);
                return pw.Container(
                  padding: const pw.EdgeInsets.all(3),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    total.toString(),
                    style: const pw.TextStyle(fontSize: 7),
                  ),
                );
              }).toList(),
              // Toplam
              pw.Container(
                padding: const pw.EdgeInsets.all(3),
                alignment: pw.Alignment.center,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.yellow100,
                ),
                child: pw.Text(
                  _calculateStudentMonthlyTotal(student.id).toString(),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 7,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Haftalık sınıf özet tablosu oluştur
  pw.Widget _buildWeeklyClassSummaryTable() {
    // Ayın ISO haftaları
    final weeks = _getMonthWeeks();

    // Tablo başlıkları
    final tableHeaders = [
      'No',
      'Öğrenci Adı',
      ...weeks.map((week) => 'H $week').toList(),
      'TOPLAM',
    ];

    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.8), // Öğrenci no
        1: const pw.FlexColumnWidth(2.5), // Öğrenci adı
        ...weeks.asMap().map(
            (i, _) => MapEntry(i + 2, const pw.FlexColumnWidth(1))), // Haftalar
        weeks.length + 2: const pw.FlexColumnWidth(1.5), // Toplam
      },
      children: [
        // Başlık satırı
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          children: tableHeaders.map((header) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(3),
              alignment: pw.Alignment.center,
              child: pw.Text(
                header,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 7,
                ),
              ),
            );
          }).toList(),
        ),
        // Öğrenci satırları
        ...students.map((student) {
          return pw.TableRow(
            children: [
              // Öğrenci no
              pw.Container(
                padding: const pw.EdgeInsets.all(3),
                alignment: pw.Alignment.center,
                child: pw.Text(
                  student.studentNumber,
                  style: const pw.TextStyle(fontSize: 7),
                ),
              ),
              // Öğrenci adı
              pw.Container(
                padding: const pw.EdgeInsets.all(3),
                child: pw.Text(
                  student.name,
                  style: const pw.TextStyle(fontSize: 7),
                ),
              ),
              // Haftalar
              ...weeks.map((week) {
                final total = _calculateWeekTotalForStudent(student.id, week);
                return pw.Container(
                  padding: const pw.EdgeInsets.all(3),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    total.toString(),
                    style: const pw.TextStyle(fontSize: 7),
                  ),
                );
              }).toList(),
              // Toplam
              pw.Container(
                padding: const pw.EdgeInsets.all(3),
                alignment: pw.Alignment.center,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.yellow100,
                ),
                child: pw.Text(
                  _calculateStudentMonthlyTotal(student.id).toString(),
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 7,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  // Öğrenci özet tablosu oluştur
  pw.Widget _buildStudentSummaryTable(Students student) {
    // Tablo başlıkları
    final tableHeaders = [
      'Ders',
      'Toplam Çözülen Soru',
    ];

    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(3), // Ders adı
        1: const pw.FlexColumnWidth(2), // Toplam
      },
      children: [
        // Başlık satırı
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          children: tableHeaders.map((header) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(3), // 5'ten 3'e düşürüldü
              alignment: pw.Alignment.center,
              child: pw.Text(
                header,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 7, // Font boyutu eklendi (7pt)
                ),
              ),
            );
          }).toList(),
        ),
        // Ders satırları
        ...Course.values.map((course) {
          final total = _calculateCourseTotalForStudent(student.id, course);
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: _getCourseColor(course),
            ),
            children: [
              // Ders adı
              pw.Container(
                padding: const pw.EdgeInsets.all(3), // 5'ten 3'e düşürüldü
                child: pw.Text(
                  _getCourseDisplayName(course),
                  style: const pw.TextStyle(fontSize: 7), // Font boyutu eklendi
                ),
              ),
              // Toplam
              pw.Container(
                padding: const pw.EdgeInsets.all(3), // 5'ten 3'e düşürüldü
                alignment: pw.Alignment.center,
                child: pw.Text(
                  total.toString(),
                  style: const pw.TextStyle(fontSize: 7), // Font boyutu eklendi
                ),
              ),
            ],
          );
        }).toList(),
        // Toplam satırı
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.yellow100,
          ),
          children: [
            // Toplam
            pw.Container(
              padding: const pw.EdgeInsets.all(3), // 5'ten 3'e düşürüldü
              child: pw.Text(
                'TOPLAM',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 7, // Font boyutu eklendi
                ),
              ),
            ),
            // Toplam değer
            pw.Container(
              padding: const pw.EdgeInsets.all(3), // 5'ten 3'e düşürüldü
              alignment: pw.Alignment.center,
              child: pw.Text(
                _calculateStudentMonthlyTotal(student.id).toString(),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 7, // Font boyutu eklendi
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Öğrenci detaylı tablosu oluştur
  pw.Widget _buildStudentDetailedTable(Students student) {
    // Ayın günleri
    final days = _getMonthDays();
    final firstDay = DateTime(reportDate.year, reportDate.month, 1);

    // Tablo başlıkları
    final tableHeaders = [
      'Ders',
      ...days.map((day) {
        final date = DateTime(reportDate.year, reportDate.month, day);
        return '${day.toString().padLeft(2, '0')}\n${_getAbbreviatedDayName(date.weekday)}';
      }).toList(),
      'TOP', // "TOPLAM" yerine "TOP" kullanarak kısalttık
    ];

    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.5), // Ders adı
        ...days.asMap().map((i, _) => MapEntry(
            i + 1, const pw.FlexColumnWidth(0.6))), // Günler - Daha dar
        days.length + 1: const pw.FlexColumnWidth(1), // Toplam
      },
      children: [
        // Başlık satırı
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.grey300,
          ),
          children: tableHeaders.map((header) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(2), // 5'ten 2'ye düşürüldü
              alignment: pw.Alignment.center,
              child: pw.Text(
                header,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 6, // 8'den 6'ya düşürüldü
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
        // Ders satırları
        ...Course.values.map((course) {
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: _getCourseColor(course),
            ),
            children: [
              // Ders adı - kısaltma yapalım
              pw.Container(
                padding: const pw.EdgeInsets.all(2), // 5'ten 2'ye düşürüldü
                child: pw.Text(
                  _getAbbreviatedCourseName(
                      course), // Kısaltılmış ders adı kullan
                  style:
                      const pw.TextStyle(fontSize: 6), // 9'dan 6'ya düşürüldü
                ),
              ),
              // Günlük değerler
              ...days.map((day) {
                final dateStr = DateFormat('yyyy-MM-dd').format(
                  DateTime(reportDate.year, reportDate.month, day),
                );
                final value = trackingData[student.id]?[dateStr]?[course] ?? 0;

                return pw.Container(
                  padding: const pw.EdgeInsets.all(1), // 2'den 1'e düşürüldü
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    value > 0 ? value.toString() : "",
                    style:
                        const pw.TextStyle(fontSize: 6), // 8'den 6'ya düşürüldü
                  ),
                );
              }).toList(),
              // Toplam
              pw.Container(
                padding: const pw.EdgeInsets.all(2), // 5'ten 2'ye düşürüldü
                alignment: pw.Alignment.center,
                child: pw.Text(
                  _calculateCourseTotalForStudent(student.id, course)
                      .toString(),
                  style: pw.TextStyle(
                    fontSize: 6, // 9'dan 6'ya düşürüldü
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
        // Toplam satırı
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.yellow100,
          ),
          children: [
            // Toplam
            pw.Container(
              padding: const pw.EdgeInsets.all(2), // 5'ten 2'ye düşürüldü
              child: pw.Text(
                'GÜNLÜK TOP.', // "GÜNLÜK TOPLAM" yerine "GÜNLÜK TOP." kullanarak kısalttık
                style: pw.TextStyle(
                  fontSize: 6, // 9'dan 6'ya düşürüldü
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            // Günlük toplamlar
            ...days.map((day) {
              final dateStr = DateFormat('yyyy-MM-dd').format(
                DateTime(reportDate.year, reportDate.month, day),
              );

              int dayTotal = 0;
              if (trackingData[student.id]?[dateStr] != null) {
                trackingData[student.id]![dateStr]!.forEach((course, count) {
                  dayTotal += count;
                });
              }

              return pw.Container(
                padding: const pw.EdgeInsets.all(1), // 2'den 1'e düşürüldü
                alignment: pw.Alignment.center,
                child: pw.Text(
                  dayTotal > 0 ? dayTotal.toString() : "",
                  style:
                      const pw.TextStyle(fontSize: 6), // 8'den 6'ya düşürüldü
                ),
              );
            }).toList(),
            // Aylık toplam
            pw.Container(
              padding: const pw.EdgeInsets.all(2), // 5'ten 2'ye düşürüldü
              alignment: pw.Alignment.center,
              child: pw.Text(
                _calculateStudentMonthlyTotal(student.id).toString(),
                style: pw.TextStyle(
                  fontSize: 6, // 9'dan 6'ya düşürüldü
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Aylık ders toplamları grafiği
  pw.Widget _buildMonthlyCourseTotalsChart() {
    // Ders bazında toplam çözülen soru sayıları
    final Map<Course, int> courseTotals = {};

    for (final course in Course.values) {
      int total = 0;
      for (final student in students) {
        total += _calculateCourseTotalForStudent(student.id, course);
      }
      courseTotals[course] = total;
    }

    // En yüksek değeri bul
    int maxTotal = courseTotals.values.isEmpty
        ? 100
        : courseTotals.values.reduce((a, b) => a > b ? a : b);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Aylık Ders Bazında Toplam Çözülen Soru Sayıları',
          style: pw.TextStyle(
            fontSize: 12, // 14'ten 12'ye düşürüldü
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8), // 10'dan 8'e düşürüldü
        pw.Container(
          height: 200,
          child: pw.Column(
            children: [
              pw.Row(
                children: [
                  pw.SizedBox(width: 30),
                  ...Course.values.map(
                    (course) => pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 2),
                        child: pw.Text(
                          _getCourseDisplayName(course),
                          style: pw.TextStyle(fontSize: 8),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                children: [
                  pw.SizedBox(width: 30),
                  ...Course.values.map(
                    (course) => pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Container(
                            height:
                                100 * (courseTotals[course] ?? 0) / maxTotal,
                            width: 20,
                            color: _getCourseColor(course),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            '${courseTotals[course] ?? 0}',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Haftalık ilerleme grafiği
  pw.Widget _buildWeeklyProgressChart() {
    // Ayın ISO haftaları
    final weeks = _getMonthWeeks();

    // Hafta bazında toplam çözülen soru sayıları
    final Map<int, int> weekTotals = {};

    for (final week in weeks) {
      int total = 0;
      for (final student in students) {
        total += _calculateWeekTotalForStudent(student.id, week);
      }
      weekTotals[week] = total;
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Haftalık İlerleme',
          style: pw.TextStyle(
            fontSize: 12, // 14'ten 12'ye düşürüldü
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8), // 10'dan 8'e düşürüldü
        pw.Container(
          height: 200,
          child: pw.Column(
            children: [
              pw.Row(
                children: [
                  pw.SizedBox(width: 30),
                  ...weeks.map(
                    (week) => pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 2),
                        child: pw.Text('Hafta $week',
                            style: pw.TextStyle(fontSize: 8),
                            textAlign: pw.TextAlign.center),
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                children: [
                  pw.SizedBox(width: 30),
                  ...weeks.map(
                    (week) => pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Container(
                            height: 100 *
                                (weekTotals[week] ?? 0) /
                                (weekTotals.values.isEmpty
                                    ? 100
                                    : weekTotals.values
                                        .reduce((a, b) => a > b ? a : b)),
                            width: 20,
                            color: PdfColors.green300,
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text('${weekTotals[week] ?? 0}',
                              style: pw.TextStyle(fontSize: 8)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Haftalık ders toplamları grafiği
  pw.Widget _buildWeeklyCourseTotalsChart() {
    // Ayın ISO haftaları
    final weeks = _getMonthWeeks();

    // Her ders için haftalık toplam veriler
    final Map<Course, List<int>> courseTotals = {};

    // En yüksek değeri bul
    int maxTotal = 0;

    for (final course in Course.values) {
      final List<int> totals = [];
      for (final week in weeks) {
        int total = 0;
        for (final student in students) {
          total += _calculateCourseWeekTotal(student.id, week, course);
        }
        totals.add(total);
        if (total > maxTotal) {
          maxTotal = total;
        }
      }
      courseTotals[course] = totals;
    }

    // Eğer maxTotal 0 ise, görselleştirme için 100 değerini kullan
    maxTotal = maxTotal > 0 ? maxTotal : 100;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Haftalık Ders Bazında İlerleme',
          style: pw.TextStyle(
            fontSize: 12, // 14'ten 12'ye düşürüldü
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8), // 10'dan 8'e düşürüldü
        ...Course.values.map(
          (course) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 15),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 100,
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  color: _getCourseColor(course),
                  child: pw.Text(
                    _getCourseDisplayName(course),
                    style: pw.TextStyle(fontSize: 8),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  children: [
                    pw.SizedBox(width: 30),
                    ...weeks.asMap().entries.map(
                          (entry) => pw.Expanded(
                            child: pw.Column(
                              children: [
                                pw.Container(
                                  height: 30 *
                                      courseTotals[course]![entry.key] /
                                      maxTotal,
                                  width: 15,
                                  color: _getCourseColor(course),
                                ),
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  '${courseTotals[course]![entry.key]}',
                                  style: pw.TextStyle(fontSize: 6),
                                ),
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  'H${weeks[entry.key]}',
                                  style: pw.TextStyle(fontSize: 6),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Öğrenci ders ilerleme grafiği
  pw.Widget _buildStudentCourseProgressChart(Students student) {
    // Ders bazında toplam çözülen soru sayıları
    final Map<Course, int> courseTotals = {};

    for (final course in Course.values) {
      courseTotals[course] =
          _calculateCourseTotalForStudent(student.id, course);
    }

    // En yüksek değeri bul
    int maxTotal = courseTotals.values.isEmpty
        ? 100
        : courseTotals.values.reduce((a, b) => a > b ? a : b);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Ders Bazında Çözülen Soru Dağılımı',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          height: 200,
          child: pw.Column(
            children: [
              pw.Row(
                children: [
                  pw.SizedBox(width: 30),
                  ...Course.values.map(
                    (course) => pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 2),
                        child: pw.Text(
                          _getCourseDisplayName(course),
                          style: pw.TextStyle(fontSize: 8),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                children: [
                  pw.SizedBox(width: 30),
                  ...Course.values.map(
                    (course) => pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Container(
                            height: 100 *
                                (courseTotals[course] ?? 0) /
                                (maxTotal > 0 ? maxTotal : 100),
                            width: 20,
                            color: _getCourseColor(course),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            '${courseTotals[course] ?? 0}',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Öğrenci haftalık ilerleme grafiği
  pw.Widget _buildStudentWeeklyProgressChart(Students student) {
    // Ayın ISO haftaları
    final weeks = _getMonthWeeks();

    // Hafta bazında toplam çözülen soru sayıları
    final Map<int, int> weekTotals = {};

    for (final week in weeks) {
      weekTotals[week] = _calculateWeekTotalForStudent(student.id, week);
    }

    // En yüksek değeri bul
    int maxTotal = weekTotals.values.isEmpty
        ? 100
        : weekTotals.values.reduce((a, b) => a > b ? a : b);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Haftalık İlerleme',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          height: 200,
          child: pw.Column(
            children: [
              pw.Row(
                children: [
                  pw.SizedBox(width: 30),
                  ...weeks.map(
                    (week) => pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 2),
                        child: pw.Text(
                          'Hafta $week',
                          style: pw.TextStyle(fontSize: 8),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                children: [
                  pw.SizedBox(width: 30),
                  ...weeks.map(
                    (week) => pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Container(
                            height: 100 *
                                (weekTotals[week] ?? 0) /
                                (maxTotal > 0 ? maxTotal : 100),
                            width: 20,
                            color: PdfColors.green300,
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            '${weekTotals[week] ?? 0}',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Öğrenci ders detay grafiği
  pw.Widget _buildStudentCourseDetailChart(Students student) {
    // Ayın ISO haftaları
    final weeks = _getMonthWeeks();

    // Her ders için haftalık toplam veriler
    final Map<Course, List<int>> courseTotals = {};

    // En yüksek değeri bul
    int maxTotal = 0;

    for (final course in Course.values) {
      final List<int> totals = [];
      for (final week in weeks) {
        int total = _calculateCourseWeekTotal(student.id, week, course);
        totals.add(total);
        if (total > maxTotal) {
          maxTotal = total;
        }
      }
      courseTotals[course] = totals;
    }

    // Eğer maxTotal 0 ise, görselleştirme için 100 değerini kullan
    maxTotal = maxTotal > 0 ? maxTotal : 100;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Ders Bazında Haftalık İlerleme',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        ...Course.values.map(
          (course) => pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 15),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 100,
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  color: _getCourseColor(course),
                  child: pw.Text(
                    _getCourseDisplayName(course),
                    style: pw.TextStyle(fontSize: 8),
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  children: [
                    pw.SizedBox(width: 30),
                    ...weeks.asMap().entries.map(
                          (entry) => pw.Expanded(
                            child: pw.Column(
                              children: [
                                pw.Container(
                                  height: 30 *
                                      courseTotals[course]![entry.key] /
                                      maxTotal,
                                  width: 15,
                                  color: _getCourseColor(course),
                                ),
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  '${courseTotals[course]![entry.key]}',
                                  style: pw.TextStyle(fontSize: 6),
                                ),
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  'H${weeks[entry.key]}',
                                  style: pw.TextStyle(fontSize: 6),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Ayın içinde bulunduğu haftaları getir
  List<int> _getMonthDays() {
    // Ayın tüm günlerini içeren bir liste oluştur
    final firstDay = DateTime(reportDate.year, reportDate.month, 1);
    final lastDay = DateTime(reportDate.year, reportDate.month + 1, 0);
    return List.generate(lastDay.day, (index) => index + 1);
  }

  // ISO hafta numarasını hesapla
  int _getISOWeekNumber(DateTime date) {
    // ISO hafta numarası: Yılın ilk Pazartesi gününe göre 1'den başlayarak ilerler
    int dayOfYear = int.parse(DateFormat('D').format(date));
    int woy = ((dayOfYear - date.weekday + 10) / 7).floor();

    if (woy < 1) {
      // Önceki yılın son haftası
      DateTime prevYearLastDay = DateTime(date.year - 1, 12, 31);
      return _getISOWeekNumber(prevYearLastDay);
    } else if (woy > 52) {
      // Sonraki yılın ilk haftası olabilir
      DateTime lastDayOfYear = DateTime(date.year, 12, 31);
      if (lastDayOfYear.weekday < 4) {
        return 1;
      }
    }
    return woy;
  }

  // Ayın içinde bulunduğu haftaları getir
  List<int> _getMonthWeeks() {
    // Ayın ilk ve son günü
    final firstDayOfMonth = DateTime(reportDate.year, reportDate.month, 1);
    final lastDayOfMonth = DateTime(reportDate.year, reportDate.month + 1, 0);

    // Ayın tüm günlerinde geçen ISO hafta numaralarını topla
    final Set<int> weeks = {};

    // Ayın her günü için
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(reportDate.year, reportDate.month, day);
      weeks.add(_getISOWeekNumber(date));
    }

    // Sıralı liste olarak döndür
    return weeks.toList()..sort();
  }

  Future<String> savePdf(String fileName) async {
    try {
      // Kullanıcının klasör seçmesini sağla
      String? outputDir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'PDF dosyasını kaydetmek için klasör seçin',
      );

      if (outputDir == null) {
        // Klasör seçimi iptal edildiyse işlemi sonlandır
        print('Kullanıcı klasör seçimini iptal etti.');
        return '';
      }

      final file = File('$outputDir/$fileName');

      // PDF dosyasını oluştur
      final pdfBytes = await generatePdf();

      // Dosyaya yaz
      await file.writeAsBytes(pdfBytes);

      // Dosyayı aç
      await OpenFile.open(file.path);

      return file.path;
    } catch (e) {
      print('PDF kaydedilirken hata oluştu: $e');
      return '';
    }
  }

  // Ders adlarını kısalt
  String _getAbbreviatedCourseName(Course course) {
    switch (course) {
      case Course.TURKCE:
        return 'TÜRK';
      case Course.MATEMATIK:
        return 'MAT';
      case Course.FEN:
        return 'FEN';
      case Course.SOSYAL:
        return 'SOSY';
      case Course.INGILIZCE:
        return 'İNG';
      case Course.DIKAB:
        return 'DİKAB';
      default:
        return course.toString();
    }
  }

  // Öğrenci resmini almak için yeni bir fonksiyon
  Future<Uint8List?> _fetchStudentImage(int studentId) async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/student/$studentId/image'));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      print('Öğrenci resmi yükleme hatası: $e');
    }
    return null;
  }
}
