import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class OkulDenemeleriAnalysisChart extends StatelessWidget {
  final List<Map<String, dynamic>> denemeler;
  final Map<String, dynamic> statistics;

  const OkulDenemeleriAnalysisChart({
    Key? key,
    required this.denemeler,
    required this.statistics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // TabBar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: TabBar(
              labelColor: Colors.purple, // Seçili tab rengi
              unselectedLabelColor: Colors.grey, // Seçili olmayan tab rengi
              indicatorColor:
                  Colors.purple, // Seçili tab'ın altındaki çizgi rengi
              tabs: const [
                Tab(text: 'Net Gelişim Grafiği'),
                Tab(text: 'Deneme İstatistikleri'),
              ],
            ),
          ),

          // TabBarView
          Expanded(
            child: TabBarView(
              children: [
                // Sayfa 1: Net Gelişim Grafiği
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
                        Expanded(
                          child: // LineChart'ı güncelleyelim
                              LineChart(
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
                                    interval:
                                        1, // Her nokta için bir başlık göster
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() >= 0 &&
                                          value.toInt() < denemeler.length) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: RotatedBox(
                                            quarterTurns: 1,
                                            child: SizedBox(
                                              width: 60,
                                              child: Text(
                                                denemeler[value.toInt()]
                                                        ['deneme_adi'] ??
                                                    '',
                                                style: const TextStyle(
                                                    fontSize: 10),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                                    sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                              ),
                              lineBarsData: [
                                // Öğrenci çizgisi
                                LineChartBarData(
                                  spots:
                                      List.generate(denemeler.length, (index) {
                                    // Öğrencinin katıldığı denemeyi kontrol et
                                    final ogrenciKatildi = denemeler[index]
                                            ['ogrenci_katildi'] ??
                                        false;
                                    final ogrenciNet = denemeler[index]
                                                ['ogrenci_net']
                                            ?.toDouble() ??
                                        0.0;

                                    return FlSpot(
                                      index.toDouble(),
                                      ogrenciKatildi ? ogrenciNet : 0.0,
                                    );
                                  }),
                                  isCurved:
                                      false, // Düz çizgiler için false yap
                                  color:
                                      const Color.fromARGB(255, 226, 247, 70),
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                      // Sadece öğrencinin katıldığı denemelerde nokta göster
                                      if (denemeler[index]['ogrenci_katildi'] ??
                                          false) {
                                        return FlDotCirclePainter(
                                          radius: 6,
                                          color: Colors.purple,
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        );
                                      }
                                      return FlDotCirclePainter(
                                        radius: 0,
                                        color: const Color.fromARGB(
                                            0, 255, 255, 255),
                                        strokeWidth: 0,
                                        strokeColor: const Color.fromARGB(
                                            0, 253, 253, 253),
                                      );
                                    },
                                  ),
                                ),
// Sınıf ortalaması çizgisi
                                LineChartBarData(
                                  spots:
                                      List.generate(denemeler.length, (index) {
                                    final sinifOrt = denemeler[index]
                                                ['sinif_ortalamasi']
                                            ?.toDouble() ??
                                        0.0;
                                    return FlSpot(
                                      index.toDouble(),
                                      sinifOrt,
                                    );
                                  }),
                                  isCurved:
                                      false, // Düz çizgiler için false yap
                                  color: Colors.blue,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                      final sinifOrt = denemeler[index]
                                              ['sinif_ortalamasi'] ??
                                          0;
                                      if (sinifOrt > 0) {
                                        return FlDotCirclePainter(
                                          radius: 6,
                                          color: Colors.blue,
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        );
                                      }
                                      return FlDotCirclePainter(
                                        radius: 0,
                                        color: Colors.transparent,
                                        strokeWidth: 0,
                                        strokeColor: Colors.transparent,
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
                              _buildLegendItem('Sınıf Ortalaması', Colors.blue),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Sayfa 2: İstatistikler
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Deneme İstatistikleri',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Katılım yüzdesi ve istatistikler
                          Row(
                            children: [
                              Expanded(
                                child: _buildCircularProgress(),
                              ),
                              const SizedBox(width: 80),
                              Expanded(
                                child: _buildStatsList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// Katılım yüzdesi için daire göstergesi
  Widget _buildCircularProgress() {
    final katilimYuzdesi = (statistics['katilim_yuzdesi'] as num).toDouble();

    return Container(
      height: 400, // Sabit yükseklik
      width: 200, // Sabit genişlik
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 180, // Dairenin boyutu
            height: 180,
            child: CircularProgressIndicator(
              value: katilimYuzdesi / 100,
              strokeWidth: 50, // Çizgi kalınlığı
              backgroundColor: Colors.grey[200],
              color: _getParticipationColor(katilimYuzdesi),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '%${katilimYuzdesi.toStringAsFixed(1)}',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Katılım',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// İstatistikler listesi
  Widget _buildStatsList() {
    return Expanded(
      // Tüm alanı kaplaması için Expanded kullanıldı
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCompactStatItem(
            'Toplam Deneme',
            statistics['toplam_deneme'].toString(),
            Icons.assignment,
            Colors.blue,
          ),
          const SizedBox(height: 24), // Boşluklar artırıldı
          _buildCompactStatItem(
            'Katıldığı Deneme',
            statistics['katildigi_deneme'].toString(),
            Icons.check_circle,
            Colors.green,
          ),
          const SizedBox(height: 24), // Boşluklar artırıldı
          _buildCompactStatItem(
            'Ortalama Net',
            (statistics['ortalama_net'] as num).toStringAsFixed(2),
            Icons.analytics,
            Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Yeni, daha kompakt stat item builder
  Widget _buildCompactStatItem(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getParticipationColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.blue;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }
}
