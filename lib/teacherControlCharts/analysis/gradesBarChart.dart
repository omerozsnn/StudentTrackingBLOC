import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GradesBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> grades;

  const GradesBarChart({Key? key, required this.grades}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (grades.isEmpty) {
      return const Center(child: Text('Veri bulunamadı'));
    }

    List<BarChartGroupData> barGroups = [];
    int index = 0;

    for (var grade in grades) {
      double avgScore = (grade['sinif_ortalama'] as num).toDouble();
      double studentScore = (grade['donem_puani'] as num).toDouble();

      barGroups.add(
        BarChartGroupData(
          x: index++,
          barRods: [
            // Sınıf Ortalaması Çubuğu (Mavi)
            BarChartRodData(
              toY: avgScore,
              width: 20,
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
            // Öğrenci Notu Çubuğu (Kırmızı)
            BarChartRodData(
              toY: studentScore,
              width: 20,
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 📊 Grafik
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 120,
              minY: 0,
              barGroups: barGroups,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 10,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.shade300,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text("${value.toInt()}",
                          style: const TextStyle(fontSize: 12));
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= grades.length) {
                        return const Text("");
                      }
                      return Text(
                        grades[value.toInt()]["ders_adi"],
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // 📌 Açıklamalar (Legend)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(Colors.blue, "Sınıf Ortalaması"),
            const SizedBox(width: 30),
            _buildLegendItem(Colors.red, "Öğrenci Notu"),
          ],
        ),
      ],
    );
  }

  // 📌 Açıklama Bileşeni (Legend)
  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
