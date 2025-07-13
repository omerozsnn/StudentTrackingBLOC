import 'package:flutter/material.dart';
import 'api.dart/unitsApi.dart' as unitApi;
import 'api.dart/egitimOgretimYılıApi.dart' as egitimOgretimYili;
import 'api.dart/studentTransferApi.dart' as studentApi;
import 'api.dart/prayerSurahApi.dart' as prayerSurahApi;
import 'api.dart/homeworkControlApi.dart' as homeworkApi;
import 'api.dart/misbehaviorApi.dart' as misbehaviourApi;
import 'api.dart/teacherFeedbackApi.dart' as teacherFeedbackApi;

class BilgiAktarmaPage extends StatefulWidget {
  const BilgiAktarmaPage({super.key});

  @override
  _BilgiAktarmaPageState createState() => _BilgiAktarmaPageState();
}

class _BilgiAktarmaPageState extends State<BilgiAktarmaPage> {
  final egitimOgretimYili.ApiService api = egitimOgretimYili.ApiService();
  final unitApi.ApiService unitService = unitApi.ApiService();
  final studentApi.ApiService studentService = studentApi.ApiService();
  final prayerSurahApi.PrayerSurahApiService prayerSurahService =
      prayerSurahApi.PrayerSurahApiService(baseUrl: 'http://localhost:3000');
  final homeworkApi.ApiService homeworkService = homeworkApi.ApiService();
  final misbehaviourApi.MisbehaviourApiService misbehaviourService =
      misbehaviourApi.MisbehaviourApiService(baseUrl: 'http://localhost:3000');
  final teacherFeedbackApi.ApiService teacherFeedbackService =
      teacherFeedbackApi.ApiService();

  List<String> eskiYillar = [];
  List<String> yeniYillar = [];
  String? _selectedEskiYil;
  String? _selectedYeniYil;
  bool _isLoading = false; // Yüklenme durumunu kontrol eden değişken
  bool _ogrenciBilgileri = false;
  bool _uniteler = false;
  bool _sureDuaHavuzu = false;
  bool _odevHavuzu = false;
  bool _yaramazliklar = false;
  bool _ogretmenGorusleri = false;

  @override
  void initState() {
    super.initState();
    loadEducationYears();
  }

  // Eğitim öğretim yıllarını yükle
  Future<void> loadEducationYears() async {
    try {
      final List<dynamic> years = await api.getAllYears();
      setState(() {
        eskiYillar =
            years.map((year) => year['egitim_ogretim_yili'] as String).toList();
        yeniYillar = List.from(eskiYillar);
      });
    } catch (error) {
      print('Error fetching education years: $error');
    }
  }

  // Aktarma işlemini başlat
  Future<void> _startTransfer() async {
    setState(() {
      _isLoading = true; // İşlem başladığında yüklenme göstergesini aktif et
    });
    if (_selectedEskiYil == null || _selectedYeniYil == null) {
      print('Lütfen kaynak ve hedef yılı seçin.');
      return;
    }

    final int? fromYearId = await _getYearIdByName(_selectedEskiYil!);
    final int? toYearId = await _getYearIdByName(_selectedYeniYil!);

    if (fromYearId == null || toYearId == null) {
      print("Eğitim öğretim yılı ID'leri bulunamadı.");
      return;
    }

    if (_ogrenciBilgileri) {
      try {
        await studentService.transferAllStudents(fromYearId, toYearId);
        print('Öğrenci bilgileri başarıyla aktarıldı.');
      } catch (error) {
        print('Öğrenci aktarımı sırasında hata: $error');
      }
    }

    if (_uniteler) {
      try {
        await unitService.transferUnitsToNextYear(fromYearId, toYearId);
        print('Üniteler başarıyla aktarıldı.');
      } catch (error) {
        print('Ünite aktarımı sırasında hata: $error');
      }
    }

    if (_sureDuaHavuzu) {
      try {
        await prayerSurahService.transferPrayerSurahs(fromYearId, toYearId);
        print('Sure ve dualar başarıyla aktarıldı.');
      } catch (error) {
        print('Sure ve dua aktarımı sırasında hata: $error');
      }
    }

    if (_odevHavuzu) {
      try {
        await homeworkService.transferHomeworks(fromYearId, toYearId);
        print('Ödevler başarıyla aktarıldı.');
      } catch (error) {
        print('Ödev aktarımı sırasında hata: $error');
      }
    }

    if (_yaramazliklar) {
      try {
        await misbehaviourService.transferMisbehaviour(fromYearId, toYearId);
        print('Yaramazlıklar başarıyla aktarıldı.');
      } catch (error) {
        print('Yaramazlık aktarımı sırasında hata: $error');
      }
    }

    if (_ogretmenGorusleri) {
      try {
        await teacherFeedbackService.transferTeacherFeedbackOptions(
            fromYearId, toYearId);
        print('Öğretmen görüşleri başarıyla aktarıldı.');
      } catch (error) {
        print('Öğretmen görüşleri aktarımı sırasında hata: $error');
      }
    }

    print("Bilgi aktarımı tamamlandı.");
    setState(() {
      _isLoading = false; // İşlem tamamlandığında yüklenme göstergesini kapat
    });
  }

  // Yıl adına göre yıl ID'sini getir
  Future<int?> _getYearIdByName(String yearName) async {
    try {
      final List<dynamic> years = await api.getAllYears();
      final year =
          years.firstWhere((year) => year['egitim_ogretim_yili'] == yearName);
      return year['id'] as int?;
    } catch (error) {
      print('Yıl ID bulunamadı: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eğitim Öğretim Yılları Arası Bilgi Aktarma'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'KAYNAK Eğitim Öğretim Yılı',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: eskiYillar.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: ListTile(
                                  leading: Checkbox(
                                    value:
                                        _selectedEskiYil == eskiYillar[index],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _selectedEskiYil =
                                            value! ? eskiYillar[index] : null;
                                      });
                                    },
                                  ),
                                  title: Text(eskiYillar[index]),
                                  selected:
                                      eskiYillar[index] == _selectedEskiYil,
                                  onTap: () {
                                    setState(() {
                                      _selectedEskiYil = eskiYillar[index];
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'HEDEF Eğitim Öğretim Yılı',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: yeniYillar.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: ListTile(
                                  leading: Checkbox(
                                    value:
                                        _selectedYeniYil == yeniYillar[index],
                                    onChanged: (bool? value) {
                                      setState(() {
                                        _selectedYeniYil =
                                            value! ? yeniYillar[index] : null;
                                      });
                                    },
                                  ),
                                  title: Text(yeniYillar[index]),
                                  selected:
                                      yeniYillar[index] == _selectedYeniYil,
                                  onTap: () {
                                    setState(() {
                                      _selectedYeniYil = yeniYillar[index];
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        CheckboxListTile(
                          title: const Text('Öğrenci Bilgileri'),
                          value: _ogrenciBilgileri,
                          onChanged: (bool? value) {
                            setState(() {
                              _ogrenciBilgileri = value!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('Üniteler'),
                          value: _uniteler,
                          onChanged: (bool? value) {
                            setState(() {
                              _uniteler = value!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('Sure & Dua Havuzu'),
                          value: _sureDuaHavuzu,
                          onChanged: (bool? value) {
                            setState(() {
                              _sureDuaHavuzu = value!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('Ödev Havuzu'),
                          value: _odevHavuzu,
                          onChanged: (bool? value) {
                            setState(() {
                              _odevHavuzu = value!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('Yaramazlıklar'),
                          value: _yaramazliklar,
                          onChanged: (bool? value) {
                            setState(() {
                              _yaramazliklar = value!;
                            });
                          },
                        ),
                        CheckboxListTile(
                          title: const Text('Öğretmen Görüşleri'),
                          value: _ogretmenGorusleri,
                          onChanged: (bool? value) {
                            setState(() {
                              _ogretmenGorusleri = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white),
                  onPressed: _startTransfer,
                  child: const Text('AKTARMA İŞLEMİNİ BAŞLAT'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('KAPAT'),
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color:
                    Colors.black.withOpacity(0.5), // Arkaplanı yarı saydam yap
                child: const Center(
                  child: CircularProgressIndicator(), // Yüklenme göstergesi
                ),
              ),
          ],
        ),
      ),
    );
  }
}
