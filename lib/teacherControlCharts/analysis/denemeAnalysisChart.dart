import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ogrenci_takip_sistemi/models/ogrenci_denemeleri_model.dart';

class DenemeAnalysischart extends StatelessWidget {
  final List<Map<String, dynamic>> denemeler;
  final ClassDenemeAverages classAverages;
  final Map<String, dynamic>? participationDetails;

  const DenemeAnalysischart(
      {Key? key,
      required this.denemeler,
      required this.classAverages,
      this.participationDetails})
      : super(key: key);

  /// 🔹 **Deneme adını güvenli bir şekilde almak için yardımcı fonksiyon**
  String getDenemeAdi(Map<String, dynamic> deneme) {
    if (deneme.containsKey('denemeSinavi') &&
        deneme['denemeSinavi'].containsKey('deneme_sinavi_adi')) {
      return deneme['denemeSinavi']['deneme_sinavi_adi'] ?? 'Bilinmeyen Deneme';
    }
    return 'Bilinmeyen Deneme';
  }

  @override
  Widget build(BuildContext context) {
    if (denemeler.isEmpty || classAverages.denemeAverages.isEmpty) {
      return const Center(child: Text('Yeterli veri bulunamadı'));
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Deneme Analizi'),
              Tab(text: 'Katılım Durumu'),
            ],
            labelColor: Color(0xFF6C8997),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF6C8997),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAnalysisTab(), // Existing analysis tab
                _participationTab(), // New participation tab
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Net Gelişim Grafiği
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
                                if (value.toInt() >= denemeler.length)
                                  return const SizedBox();

                                // Modified to match KDSAnalysisChart implementation
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: RotatedBox(
                                    quarterTurns: 1,
                                    child: SizedBox(
                                      width: 60,
                                      child: Text(
                                        getDenemeAdi(denemeler[value.toInt()]),
                                        style: const TextStyle(fontSize: 10),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 100, // Increased from 60 to 100
                            ),
                          ),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        lineBarsData: [
                          // Öğrenci çizgisi
                          LineChartBarData(
                            spots: List.generate(denemeler.length, (index) {
                              final deneme = denemeler[index];
                              return FlSpot(
                                  index.toDouble(),
                                  double.parse((deneme['puan']?.toDouble() ?? 0)
                                      .toStringAsFixed(1)));
                            }),
                            isCurved: false,
                            color: Colors.orange, // Changed from blue to orange
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 6,
                                  color: Colors
                                      .orange, // Kept orange color for consistency
                                  strokeWidth: 2,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                          ),
                          // Sınıf ortalaması çizgisi
                          LineChartBarData(
                            spots: List.generate(
                                classAverages.denemeAverages.length, (index) {
                              final classAvg =
                                  classAverages.denemeAverages[index];
                              return FlSpot(
                                  index.toDouble(),
                                  double.parse(
                                      (classAvg.averageScore?.toDouble() ?? 0)
                                          .toStringAsFixed(1)));
                            }),
                            isCurved: false,
                            color: Colors.blue, // Changed from grey to blue
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                // Added dot painter for class average
                                return FlDotCirclePainter(
                                  radius: 5,
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
                        _buildLegendItem('Öğrenci',
                            Colors.orange), // Orange for student (consistent)
                        const SizedBox(width: 24),
                        _buildLegendItem('Sınıf Ortalaması',
                            Colors.blue), // Blue for class average (updated)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bar Chart - Fixed similar to the line chart
          Card(
            elevation: 4,
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Puan Karşılaştırma Grafiği',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 400,
                    child: BarChart(
                      BarChartData(
                        maxY: 100,
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(
                          enabled: true,
                          handleBuiltInTouches: true,
                          touchTooltipData: BarTouchTooltipData(
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final deneme = denemeler[groupIndex];
                              final classAvg =
                                  classAverages.denemeAverages[groupIndex];
                              final isStudentRod = rodIndex == 0;

                              return BarTooltipItem(
                                '${getDenemeAdi(deneme)}\n'
                                '${isStudentRod ? "Öğrenci" : "Sınıf Ort."}: ${rod.toY.toStringAsFixed(1)}\n'
                                '${isStudentRod ? "D:${deneme['dogru']} Y:${deneme['yanlis']} B:${deneme['bos']}" : "Katılım: ${classAvg.totalParticipants} öğrenci"}',
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= denemeler.length)
                                  return const SizedBox();

                                // Match the line chart implementation
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: RotatedBox(
                                    quarterTurns: 1,
                                    child: SizedBox(
                                      width: 60,
                                      child: Text(
                                        getDenemeAdi(denemeler[value.toInt()]),
                                        style: const TextStyle(fontSize: 10),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 100, // Increased from 60 to 100
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text('${value.toInt()}');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(
                          denemeler.length,
                          (index) {
                            final deneme = denemeler[index];
                            final classAvg =
                                classAverages.denemeAverages[index];
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: deneme['puan']?.toDouble() ?? 0,
                                  color: Colors.orange,
                                  width: 22,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                BarChartRodData(
                                  toY: classAvg.averageScore?.toDouble() ?? 0,
                                  color: Colors.blue.withOpacity(0.5),
                                  width: 22,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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

    final totalDeneme = participationDetails!['totalDeneme'] as int;
    final attended = participationDetails!['katilanDenemeSayisi'] as int;
    final missed = participationDetails!['katilmayanDenemesayisi'] as int;
    final attendanceRate =
        totalDeneme > 0 ? (attended / totalDeneme * 100) : 0.0;

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
                    'Deneme Katılım Özeti',
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
                          'Toplam Deneme', totalDeneme, Colors.blue),
                      _buildAttendanceStats(
                          'Katıldığı', attended, Colors.green),
                      _buildAttendanceStats('Katılmadığı', missed, Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Katılmadığı Deneme'ler Listesi
          if ((participationDetails!['katilmayanDenemeler'] as List?)
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
                          'Katılmadığı Deneme\'ler',
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
                      children: (participationDetails!['katilmayanDenemeler']
                              as List)
                          .map((deneme) => Chip(
                                label: Text(deneme['deneme_sinavi_adi'] ?? ''),
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
            backgroundColor: Colors.orange.shade200,
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

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
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

  Widget _buildStatCard(String title, double studentValue, double classValue,
      IconData icon, MaterialColor color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              studentValue.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: color.shade700,
                fontSize: 14,
              ),
            ),
            Text(
              'Sınıf: ${classValue.toStringAsFixed(1)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
