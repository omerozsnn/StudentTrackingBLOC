import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StudentPerformanceChart extends StatelessWidget {
  final String courseName;
  final double studentScore;
  final double classAverage;
  final int studentRank;
  final int totalStudents;

  const StudentPerformanceChart({
    Key? key,
    required this.courseName,
    required this.studentScore,
    required this.classAverage,
    required this.studentRank,
    required this.totalStudents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300, // 📌 Kart genişliği ayarlandı
      margin: const EdgeInsets.all(10), // Kartlar arasında boşluk bırak
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // 📌 Kart yüksekliğini optimize et
          children: [
            Text(
              courseName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: studentScore,
                          color: Colors.blue,
                          radius: 35,
                          title: '',
                        ),
                        PieChartSectionData(
                          value: classAverage,
                          color: Colors.orange,
                          radius: 35,
                          title: '',
                        ),
                      ],
                      sectionsSpace: 3,
                      centerSpaceRadius: 50,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        studentScore.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Sınıf Ort: ${classAverage.toStringAsFixed(1)}",
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.blue, "Öğrenci Notu"),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.orange, "Sınıf Ortalaması"),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusCard("Başarı Durumu",
                    _getSuccessStatus(studentScore), Colors.blue.shade50),
                const SizedBox(width: 10),
                _buildStatusCard("Sınıf Sırası",
                    "$studentRank / $totalStudents", Colors.orange.shade50),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  String _getSuccessStatus(double score) {
    if (score >= 90) return "Üstün Başarı";
    if (score >= 75) return "Başarılı";
    return "Gelişmesi Gerekiyor";
  }

  Widget _buildStatusCard(String title, String value, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: backgroundColor == Colors.orange.shade50
                  ? Colors.orange
                  : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
