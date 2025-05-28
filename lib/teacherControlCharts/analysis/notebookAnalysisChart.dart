import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class NotebookBookAnalysisChart extends StatelessWidget {
  final Map<String, dynamic> analysis;

  const NotebookBookAnalysisChart({
    Key? key,
    required this.analysis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Özet Kartları
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSummaryCard(
              'Toplam Defter Getirmeme',
              analysis['totalMissingNotebook'].toString(),
              Colors.orange,
            ),
            _buildSummaryCard(
              'Toplam Kitap Getirmeme',
              analysis['totalMissingBook'].toString(),
              Colors.blue,
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Grafikler
        Expanded(
          child: Row(
            children: [
              // Defter Pie Chart
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Defter Durumu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              color: Colors.orange,
                              value: analysis['totalMissingNotebook']
                                      ?.toDouble() ??
                                  0,
                              title:
                                  analysis['totalMissingNotebook'].toString(),
                              radius: 100,
                              titleStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              color: Colors.green,
                              value: (analysis['totalRecords'] -
                                          analysis['totalMissingNotebook'])
                                      ?.toDouble() ??
                                  0,
                              title: (analysis['totalRecords'] -
                                      analysis['totalMissingNotebook'])
                                  .toString(),
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
                  ],
                ),
              ),
              // Kitap Pie Chart
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Kitap Durumu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              color: Colors.orange,
                              value:
                                  analysis['totalMissingBook']?.toDouble() ?? 0,
                              title: analysis['totalMissingBook'].toString(),
                              radius: 100,
                              titleStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              color: Colors.green,
                              value: (analysis['totalRecords'] -
                                          analysis['totalMissingBook'])
                                      ?.toDouble() ??
                                  0,
                              title: (analysis['totalRecords'] -
                                      analysis['totalMissingBook'])
                                  .toString(),
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
                  ],
                ),
              ),
            ],
          ),
        ),
        // Açıklamalar
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(Colors.orange, 'Defter Getirmedi'),
                  const SizedBox(height: 4),
                  _buildLegendItem(Colors.green, 'Defter Getirdi'),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(Colors.orange, 'Kitap Getirmedi'),
                  const SizedBox(height: 4),
                  _buildLegendItem(Colors.green, 'Kitap Getirdi'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
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
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
