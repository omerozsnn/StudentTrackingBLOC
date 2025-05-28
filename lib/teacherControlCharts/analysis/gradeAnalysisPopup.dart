import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/grades_model.dart';
import 'package:ogrenci_takip_sistemi/teacherControlCharts/analysis/gradesAnalysisChart.dart';
import '../../api.dart/grades_api.dart' as gradesApi;
import 'gradesBarChart.dart';
import 'gradesPieChart.dart';
import 'gradesClassComparison.dart';

class GradesAnalysisPopup extends StatefulWidget {
  final int sinifId;
  final int donem;
  final int? studentId;
  final List<Map<String, dynamic>> grades;

  const GradesAnalysisPopup({
    super.key,
    required this.sinifId,
    required this.donem,
    required this.grades,
    this.studentId,
  });

  @override
  _GradesAnalysisPopupState createState() => _GradesAnalysisPopupState();
}

class _GradesAnalysisPopupState extends State<GradesAnalysisPopup>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final gradesApi.GradesRepository apiService =
      gradesApi.GradesRepository(baseUrl: 'http://localhost:3000');

  ClassGradesByCourse? gradesData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCourseGrades();
  }

  Future<void> _fetchCourseGrades() async {
    try {
      final data = await apiService.getClassGradesByClassId(
          widget.sinifId, widget.donem);

      print("📌 API Yanıtı: ${data.toString()}");

      if (mounted) {
        setState(() {
          gradesData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
      print("⛔ Hata: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 1200,
        height: 1200,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Ders Ortalamaları'),
                Tab(text: 'Sınıf Karşılaştırması'),
              ],
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : (gradesData == null || gradesData!.dersler == null)
                      ? const Center(child: Text('Veri bulunamadı'))
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            _buildCourseAveragesTab(),
                            _buildClassComparisonTab(),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseAveragesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Ders Bazında Ortalamalar ve Öğrenci Notları',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 450,
            child: GradesBarChart(grades: _getFormattedBarChartData()),
          ),
        ],
      ),
    );
  }

  Widget _buildClassComparisonTab() {
    if (gradesData == null || gradesData!.dersler == null) {
      return const Center(child: Text("Veri bulunamadı"));
    }

    Map<String, dynamic> dersler = gradesData!.dersler;

    return Expanded(
      // ✅ Tüm içeriği ekranın boyutuna göre genişletir
      child: SingleChildScrollView(
        // ✅ Kaydırma işlemini etkinleştirir
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 20, // ✅ Kartlar arasındaki yatay boşluk
            runSpacing: 20, // ✅ Kartlar arasındaki dikey boşluk
            alignment: WrapAlignment.center, // 📌 Ortaya hizala
            children: dersler.entries.map((entry) {
              String courseName = entry.key;
              Map<String, dynamic> courseData = entry.value;

              return StudentPerformanceChart(
                courseName: courseData["ders_adi"] ?? "Bilinmeyen Ders",
                studentScore:
                    (courseData["ogrenciler"]?[0]?['donem_puani'] ?? 0)
                        .toDouble(),
                classAverage: (courseData["sinif_ortalama"] ?? 0).toDouble(),
                studentRank: courseData["ogrenciler"]?[0]?['sinif_sirasi'] ?? 1,
                totalStudents: courseData["ogrenciler"]?.length ?? 1,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFormattedBarChartData() {
    if (gradesData == null || gradesData!.dersler == null) {
      return [];
    }

    Map<String, dynamic> dersler = gradesData!.dersler;
    List<Map<String, dynamic>> formattedData = [];

    dersler.forEach((dersAdi, detaylar) {
      formattedData.add({
        "ders_adi": detaylar["ders_adi"],
        "donem_puani": (detaylar["ogrenciler"]?[0]?['donem_puani'] ?? 0)
            .toDouble(), // Hata önleme için
        "sinif_ortalama":
            (detaylar["sinif_ortalama"] ?? 0).toDouble(), // Hata önleme için
      });
    });

    return formattedData;
  }
}
