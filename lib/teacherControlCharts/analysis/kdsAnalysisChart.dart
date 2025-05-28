import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class KDSAnalysisChart extends StatelessWidget {
  final List<Map<String, dynamic>> kdsScores;
  final List<Map<String, dynamic>> classAverages;
  final Map<String, dynamic>? participationDetails; // Yeni parametre

  const KDSAnalysisChart({
    Key? key,
    required this.kdsScores,
    required this.classAverages,
    this.participationDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kdsScores.isEmpty || classAverages.isEmpty) {
      return const Center(
        child: Text('Yeterli veri bulunamadı'),
      );
    }

    return DefaultTabController(
      length: 2, // Number of tabs
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'KDS Analizi'),
              Tab(
                  text:
                      'Katılım Durumu Analizi'), // Placeholder for the new tab
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // First Tab
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Net Gelişim Grafiği',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 400,
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(show: true),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 40,
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: 1,
                                          getTitlesWidget: (value, meta) {
                                            if (value.toInt() >= 0 &&
                                                value.toInt() <
                                                    kdsScores.length) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: RotatedBox(
                                                  quarterTurns: 1,
                                                  child: SizedBox(
                                                    width: 60,
                                                    child: Text(
                                                      kdsScores[value.toInt()]
                                                                  ['kds']
                                                              ['kds_adi'] ??
                                                          '',
                                                      style: const TextStyle(
                                                          fontSize: 10),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign: TextAlign.left,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                            return const Text('');
                                          },
                                          reservedSize: 100,
                                        ),
                                      ),
                                      rightTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                      topTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                    ),
                                    lineBarsData: [
                                      // Öğrenci çizgisi
                                      LineChartBarData(
                                        spots: List.generate(kdsScores.length,
                                            (index) {
                                          final score = kdsScores[index]['puan']
                                                  ?.toDouble() ??
                                              0.0;
                                          return FlSpot(
                                              index.toDouble(), score);
                                        }),
                                        isCurved: false,
                                        color: const Color.fromARGB(
                                            255, 226, 247, 70),
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(
                                          show: true,
                                          getDotPainter:
                                              (spot, percent, barData, index) {
                                            return FlDotCirclePainter(
                                              radius: 6,
                                              color: Colors.purple,
                                              strokeWidth: 2,
                                              strokeColor: Colors.white,
                                            );
                                          },
                                        ),
                                      ),
                                      // Sınıf ortalaması çizgisi
                                      LineChartBarData(
                                        spots: List.generate(
                                            classAverages.length, (index) {
                                          final avgScore = classAverages[index]
                                                      ['averageScore']
                                                  ?.toDouble() ??
                                              0.0;
                                          // Burada toStringAsFixed(1) kullanarak bir ondalık basamağa yuvarlıyoruz
                                          return FlSpot(
                                              index.toDouble(),
                                              double.parse(
                                                  avgScore.toStringAsFixed(1)));
                                        }),
                                        isCurved: false,
                                        color: Colors.blue,
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(
                                          show: true,
                                          getDotPainter:
                                              (spot, percent, barData, index) {
                                            return FlDotCirclePainter(
                                              radius: 6,
                                              color: Colors.blue,
                                              strokeWidth: 2,
                                              strokeColor: Colors.white,
                                            );
                                          },
                                        ),
                                        dashArray: [5, 5],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildLegendItem('Öğrenci', Colors.purple),
                                    const SizedBox(width: 24),
                                    _buildLegendItem(
                                        'Sınıf Ortalaması', Colors.blue),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Second Tab (Placeholder)
                _participationTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _participationTab() {
    if (participationDetails == null) {
      return const Center(child: Text('Katılım bilgisi bulunamadı'));
    }

    final totalKDS =
        int.tryParse(participationDetails!['totalKDS'] ?? '0') ?? 0;
    final attended =
        int.tryParse(participationDetails!['katilanKDSsayisi'] ?? '0') ?? 0;
    final missed =
        int.tryParse(participationDetails!['katilmayanKDSsayisi'] ?? '0') ?? 0;
    final attendanceRate = totalKDS > 0 ? (attended / totalKDS * 100) : 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Katılım Özeti Kartı
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KDS Katılım Özeti',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProgressIndicator(
                    attendanceRate.toDouble(),
                    'Katılım Oranı',
                    '${attendanceRate.toStringAsFixed(1)}%',
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAttendanceStats(
                          'Toplam KDS', totalKDS, Colors.blue),
                      _buildAttendanceStats(
                          'Katıldığı', attended, Colors.green),
                      _buildAttendanceStats('Katılmadığı', missed, Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Katılmadığı KDS'ler Listesi
          if ((participationDetails!['katilmayanKDSler'] as List?)
                  ?.isNotEmpty ??
              false)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Katılmadığı KDS\'ler',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          (participationDetails!['katilmayanKDSler'] as List)
                              .map((kds) => Chip(
                                    label: Text(kds['kds_adi'] ?? ''),
                                    backgroundColor: Colors.red.shade50,
                                    labelStyle:
                                        TextStyle(color: Colors.red.shade900),
                                  ))
                              .toList(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(
      double percentage, String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage > 75
                  ? Colors.green
                  : percentage > 50
                      ? Colors.orange
                      : Colors.red,
            ),
            minHeight: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceStats(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
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
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildStatCard(String title, double studentValue, double classValue,
      IconData icon, MaterialColor color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              studentValue.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: color.shade700,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Sınıf: ${classValue.toStringAsFixed(1)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hesaplama metodları
  double _calculateAverageScore() {
    if (kdsScores.isEmpty) return 0;
    return kdsScores.fold<double>(
            0, (sum, kds) => sum + (kds['puan']?.toDouble() ?? 0)) /
        kdsScores.length;
  }

  double _calculateClassAverageScore() {
    if (classAverages.isEmpty) return 0;
    return classAverages.fold<double>(
            0, (sum, avg) => sum + (avg['averageScore']?.toDouble() ?? 0)) /
        classAverages.length;
  }

  double _calculateAverageCorrect() {
    if (kdsScores.isEmpty) return 0;
    return kdsScores.fold<double>(
            0, (sum, kds) => sum + (kds['dogru']?.toDouble() ?? 0)) /
        kdsScores.length;
  }

  double _calculateClassAverageCorrect() {
    if (classAverages.isEmpty) return 0;
    return classAverages.fold<double>(
            0, (sum, avg) => sum + (avg['averageCorrect']?.toDouble() ?? 0)) /
        classAverages.length;
  }

  double _calculateAverageWrong() {
    if (kdsScores.isEmpty) return 0;
    return kdsScores.fold<double>(
            0, (sum, kds) => sum + (kds['yanlis']?.toDouble() ?? 0)) /
        kdsScores.length;
  }

  double _calculateClassAverageWrong() {
    if (classAverages.isEmpty) return 0;
    return classAverages.fold<double>(
            0, (sum, avg) => sum + (avg['averageWrong']?.toDouble() ?? 0)) /
        classAverages.length;
  }
}
