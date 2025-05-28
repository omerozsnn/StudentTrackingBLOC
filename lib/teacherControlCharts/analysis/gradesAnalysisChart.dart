import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GradesAnalysisChart extends StatelessWidget {
  final List<Map<String, dynamic>> grades;

  const GradesAnalysisChart({Key? key, required this.grades}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (grades.isEmpty) {
      return const Center(child: Text('Veri bulunamadı'));
    }

    // Ders ortalamalarını hesapla (null olanları dahil etme)
    Map<String, double> courseAverages = {};

    for (var grade in grades) {
      String courseName = grade['ders_adi'] ?? 'Bilinmeyen Ders';

      // 🔹 Null olmayan sınavları filtreleyelim
      List<int> validScores = [
        if (grade['sinav1'] != null) grade['sinav1'],
        if (grade['sinav2'] != null) grade['sinav2'],
        if (grade['sinav3'] != null) grade['sinav3'],
        if (grade['sinav4'] != null) grade['sinav4'],
      ];

      // 🔹 Eğer hiç geçerli sınav yoksa ortalama hesaplamayalım
      if (validScores.isNotEmpty) {
        double avg = validScores.fold<int>(0, (a, b) => a + b).toDouble() /
            validScores.length;
        courseAverages[courseName] = avg;
      }
    }

    if (courseAverages.isEmpty) {
      return const Center(child: Text("Not verisi bulunamadı."));
    }

    List<BarChartGroupData> barGroups = [];
    int index = 0;
    courseAverages.forEach((course, avg) {
      barGroups.add(
        BarChartGroupData(
          x: index++,
          barRods: [
            BarChartRodData(
              toY: avg,
              width: 20, // 🔹 Çubukları genişlet
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4), // Köşeleri yuvarlat
            ),
          ],
        ),
      );
    });

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100, // 🔹 Y ekseni maksimum 100 olmalı
        minY: 0,
        barGroups: barGroups,
        gridData: FlGridData(show: true), // Izgara çizgilerini göster
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20, // 🔹 20’lik aralıklarla göster
              getTitlesWidget: (value, meta) {
                return Text("${value.toInt()}");
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= courseAverages.keys.length) {
                  return const Text("");
                }
                return Text(
                  courseAverages.keys.elementAt(value.toInt()),
                  style:
                      const TextStyle(fontSize: 14), // 🔹 Font boyutunu büyüt
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
