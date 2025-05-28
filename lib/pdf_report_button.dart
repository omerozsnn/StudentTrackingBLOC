import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'daily_tracking_report.dart' as report;
import 'daily_tracking_page.dart';
import 'models/daily_tracking_model.dart';

/// PDF raporu oluşturmak için kullanılan buton widget'ı
/// AppBar'ın actions listesine eklenebilir.
class PDFReportButton extends StatelessWidget {
  final dynamic classInfo; // Changed to dynamic to accept either ClassInfo type
  final List<Student> students;
  final Map<int, Map<String, Map<EnumCourse, int>>> trackingData;
  final Map<int, Map<int, Map<EnumCourse, int>>> weeklyData;
  final DateTime reportDate;

  const PDFReportButton({
    Key? key,
    required this.classInfo,
    required this.students,
    required this.trackingData,
    required this.weeklyData,
    required this.reportDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<report.PDFReportType>(
      tooltip: 'PDF Raporu Oluştur',
      icon: const Icon(Icons.picture_as_pdf),
      onSelected: (report.PDFReportType reportType) {
        _showPdfPreview(context, reportType);
      },
      itemBuilder: (BuildContext context) =>
          <PopupMenuEntry<report.PDFReportType>>[
        const PopupMenuItem<report.PDFReportType>(
          value: report.PDFReportType.classMonthly,
          child: ListTile(
            leading: Icon(Icons.class_outlined),
            title: Text('Sınıf Aylık Raporu'),
            subtitle: Text('Tüm sınıfın aylık özeti'),
          ),
        ),
        const PopupMenuItem<report.PDFReportType>(
          value: report.PDFReportType.classWeekly,
          child: ListTile(
            leading: Icon(Icons.view_week),
            title: Text('Sınıf Haftalık Raporu'),
            subtitle: Text('Hafta bazında özet'),
          ),
        ),
        const PopupMenuItem<report.PDFReportType>(
          value: report.PDFReportType.studentSummary,
          child: ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('Öğrenci Özet Raporu'),
            subtitle: Text('Her öğrenci için kısa özet'),
          ),
        ),
        const PopupMenuItem<report.PDFReportType>(
          value: report.PDFReportType.studentDetailed,
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text('Öğrenci Detaylı Raporu'),
            subtitle: Text('Öğrenci bazlı detaylı görünüm'),
          ),
        ),
        // Yeni Excel stili rapor seçeneği
        const PopupMenuItem<report.PDFReportType>(
          value: report.PDFReportType.excelStyle,
          child: ListTile(
            leading: Icon(Icons.grid_on),
            title: Text('Excel Stili Rapor'),
            subtitle: Text('Excel formatına benzer matris görünüm'),
          ),
        ),
      ],
    );
  }

  // Convert Student to report.Student
  List<report.Students> _convertStudents() {
    return students
        .map((student) => report.Students(
              id: student.id,
              name: student.name,
              studentNumber:
                  student.studentNumber ?? '', // Güncellenmiş parametre adı
            ))
        .toList();
  }

  // Convert data to use report.Course enum
  Map<int, Map<String, Map<report.Course, int>>> _convertTrackingData() {
    Map<int, Map<String, Map<report.Course, int>>> convertedData = {};

    trackingData.forEach((studentId, dateMap) {
      convertedData[studentId] = {};
      dateMap.forEach((date, courseMap) {
        convertedData[studentId]![date] = {};
        courseMap.forEach((course, count) {
          // Map the Course enum from daily_tracking_page to the report.Course enum
          report.Course reportCourse;
          switch (course) {
            case EnumCourse.TURKCE:
              reportCourse = report.Course.TURKCE;
              break;
            case EnumCourse.MATEMATIK:
              reportCourse = report.Course.MATEMATIK;
              break;
            case EnumCourse.FEN_BILIMLERI:
              reportCourse = report.Course.FEN;
              break;
            case EnumCourse.SOSYAL_BILGILER:
              reportCourse = report.Course.SOSYAL;
              break;
            case EnumCourse.INGILIZCE:
              reportCourse = report.Course.INGILIZCE;
              break;
            case EnumCourse.DIKAB:
              reportCourse = report.Course.DIKAB;
              break;
          }
          convertedData[studentId]![date]![reportCourse] = count;
        });
      });
    });

    return convertedData;
  }

  // Convert weekly data to use report.Course enum
  Map<int, Map<int, Map<report.Course, int>>> _convertWeeklyData() {
    Map<int, Map<int, Map<report.Course, int>>> convertedData = {};

    weeklyData.forEach((studentId, weekMap) {
      convertedData[studentId] = {};
      weekMap.forEach((week, courseMap) {
        convertedData[studentId]![week] = {};
        courseMap.forEach((course, count) {
          // Map the Course enum from daily_tracking_page to the report.Course enum
          report.Course reportCourse;
          switch (course) {
            case EnumCourse.TURKCE:
              reportCourse = report.Course.TURKCE;
              break;
            case EnumCourse.MATEMATIK:
              reportCourse = report.Course.MATEMATIK;
              break;
            case EnumCourse.FEN_BILIMLERI:
              reportCourse = report.Course.FEN;
              break;
            case EnumCourse.SOSYAL_BILGILER:
              reportCourse = report.Course.SOSYAL;
              break;
            case EnumCourse.INGILIZCE:
              reportCourse = report.Course.INGILIZCE;
              break;
            case EnumCourse.DIKAB:
              reportCourse = report.Course.DIKAB;
              break;
          }
          convertedData[studentId]![week]![reportCourse] = count;
        });
      });
    });

    return convertedData;
  }

  /// Seçilen rapor tipine göre PDF önizleme sayfasını gösterir
  void _showPdfPreview(BuildContext context, report.PDFReportType reportType) {
    String reportTypeStr;
    switch (reportType) {
      case report.PDFReportType.classMonthly:
        reportTypeStr = 'Sınıf Aylık';
        break;
      case report.PDFReportType.classWeekly:
        reportTypeStr = 'Sınıf Haftalık';
        break;
      case report.PDFReportType.studentSummary:
        reportTypeStr = 'Öğrenci Özet';
        break;
      case report.PDFReportType.studentDetailed:
        reportTypeStr = 'Öğrenci Detaylı';
        break;
      case report.PDFReportType.excelStyle:
        reportTypeStr = 'Excel Stili';
        break;
    }

    // Convert ClassInfo from daily_tracking_page to report.ClassInfo
    final reportClassInfo =
        report.ClassInfo(id: classInfo.id, name: classInfo.name);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('$reportTypeStr Rapor Önizleme'),
            actions: [
              // PDF kaydetme butonu
              IconButton(
                icon: const Icon(Icons.save),
                tooltip: 'PDF Kaydet',
                onPressed: () => _savePdf(reportType),
              ),
            ],
          ),
          body: PdfPreview(
            build: (format) => report.DailyTrackingReport(
              pageFormat: format,
              title: '$reportTypeStr Raporu',
              classInfo: reportClassInfo,
              students: _convertStudents(),
              trackingData: _convertTrackingData(),
              weeklyData: _convertWeeklyData(),
              reportDate: reportDate,
              reportType: reportType,
            ).generatePdf(),
          ),
        ),
      ),
    );
  }

  /// Seçilen rapor tipine göre PDF dosyasını kaydeder ve otomatik olarak açar
  Future<void> _savePdf(report.PDFReportType reportType) async {
    String reportTypeStr;
    switch (reportType) {
      case report.PDFReportType.classMonthly:
        reportTypeStr = 'sinif_aylik';
        break;
      case report.PDFReportType.classWeekly:
        reportTypeStr = 'sinif_haftalik';
        break;
      case report.PDFReportType.studentSummary:
        reportTypeStr = 'ogrenci_ozet';
        break;
      case report.PDFReportType.studentDetailed:
        reportTypeStr = 'ogrenci_detayli';
        break;
      case report.PDFReportType.excelStyle:
        reportTypeStr = 'excel_stili';
        break;
    }

    final dateStr =
        '${reportDate.year}_${reportDate.month.toString().padLeft(2, '0')}';
    final fileName = '${reportTypeStr}_${classInfo.name}_$dateStr.pdf';

    // Convert ClassInfo from daily_tracking_page to report.ClassInfo
    final reportClassInfo =
        report.ClassInfo(id: classInfo.id, name: classInfo.name);

    final dailyReport = report.DailyTrackingReport(
      title: 'Öğrenci Takip Raporu',
      classInfo: reportClassInfo,
      students: _convertStudents(),
      trackingData: _convertTrackingData(),
      weeklyData: _convertWeeklyData(),
      reportDate: reportDate,
      reportType: reportType,
    );

    await dailyReport.savePdf(fileName);
  }
}
