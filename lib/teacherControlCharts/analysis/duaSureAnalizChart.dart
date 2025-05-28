import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PrayerSurahAnalysisChart extends StatelessWidget {
  final Map<String, int> analysis;

  const PrayerSurahAnalysisChart({Key? key, required this.analysis})
      : super(key: key);

  List<PieChartSectionData> _getChartData() {
    return [
      PieChartSectionData(
        value: analysis['okunan']!.toDouble(),
        title: '${analysis['okunan']}',
        color: Colors.green,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: analysis['okunmayan']!.toDouble(),
        title: '${analysis['okunmayan']}',
        color: Colors.red,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          // Pie Chart
          Center(
            child: PieChart(
              PieChartData(
                sections: _getChartData(),
                centerSpaceRadius: 60,
                sectionsSpace: 4,
              ),
            ),
          ),
          // Sağ alt bilgi alanı
          Positioned(
            bottom: 10,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Okunan: ${analysis['okunan']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Okunmayan: ${analysis['okunmayan']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
