import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeworkAnalysisChart extends StatelessWidget {
  final Map<String, int> analysis;

  const HomeworkAnalysisChart({
    Key? key,
    required this.analysis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              // Pie Chart
              Expanded(
                flex: 2,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: [
                      PieChartSectionData(
                        color: Colors.green,
                        value: analysis['completed']?.toDouble() ?? 0,
                        title: '${analysis['completed']}',
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        color: Colors.red,
                        value: analysis['incomplete']?.toDouble() ?? 0,
                        title: '${analysis['incomplete']}',
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Legend (Tamamlandı & Tamamlanmadı Bilgisi)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(Colors.green, 'Tamamlandı'),
                  const SizedBox(height: 8),
                  _buildLegendItem(Colors.red, 'Tamamlanmadı'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
