import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GradesPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> grades;
  final double genelOrtalama; // ✅ Eksik parametre eklendi

  const GradesPieChart({
    super.key,
    required this.grades,
    required this.genelOrtalama, // ✅ Gerekli parametre eklendi
  });

  @override
  Widget build(BuildContext context) {
    if (grades.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Analiz için yeterli veri bulunamadı',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: 300,
      width: 300,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          sections: [
            PieChartSectionData(
              value: genelOrtalama, // ✅ Buraya eklenen parametreyi kullan
              color: Colors.blueAccent,
              title: '${genelOrtalama.toStringAsFixed(1)}%', // ✅
              radius: 25,
              titleStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: 100 - genelOrtalama,
              color: Colors.orange.withOpacity(0.5),
              title: (100 - genelOrtalama) > 10
                  ? '${(100 - genelOrtalama).toStringAsFixed(1)}%'
                  : '',
              radius: 20,
              titleStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ],
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {},
          ),
        ),
      ),
    );
  }
}
