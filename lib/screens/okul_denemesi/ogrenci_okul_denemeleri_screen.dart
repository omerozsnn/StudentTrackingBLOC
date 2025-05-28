import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../api.dart/ogrenciOkulDenemeleriApi.dart' as ogrenci_api;
import '../../blocs/ogrenci_okul_denemeleri/ogrenci_okul_denemeleri_bloc.dart';
import '../../blocs/ogrenci_okul_denemeleri/ogrenci_okul_denemeleri_event.dart';
import '../../blocs/ogrenci_okul_denemeleri/ogrenci_okul_denemeleri_repository.dart';
import '../../blocs/ogrenci_okul_denemeleri/ogrenci_okul_denemeleri_state.dart';
import '../../blocs/student/student_bloc.dart';
import '../../blocs/student/student_event.dart';
import '../../blocs/student/student_state.dart';
import '../../blocs/class/class_bloc.dart';
import '../../blocs/class/class_event.dart';
import '../../blocs/class/class_state.dart';
import '../../models/classes_model.dart';
import '../../models/ogrenci_okul_denemesi_model.dart';
import '../../models/okul_denemesi_model.dart';
import '../../models/student_model.dart';
import '../../api.dart/okulDenemeleriApi.dart' as deneme_api;
import '../../okul_denemeleri_pdf_screen.dart';
import '../../blocs/okul_denemesi/okul_denemesi_bloc.dart';
import '../../blocs/okul_denemesi/okul_denemesi_event.dart'
    as okul_deneme_events;
import '../../blocs/okul_denemesi/okul_denemesi_state.dart'
    as okul_deneme_states;

class OgrenciOkulDenemeleriScreen extends StatefulWidget {
  const OgrenciOkulDenemeleriScreen({Key? key}) : super(key: key);

  @override
  _OgrenciOkulDenemeleriScreenState createState() =>
      _OgrenciOkulDenemeleriScreenState();
}

class _OgrenciOkulDenemeleriScreenState
    extends State<OgrenciOkulDenemeleriScreen> {
  String? selectedClass;
  Map<String, TextEditingController> controllers = {};

  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Load initial data using BLoC
    BlocProvider.of<OkulDenemesiBloc>(context)
        .add(okul_deneme_events.OkulDenemesiLoaded(page: 1, limit: 15));

    // Load classes using ClassBloc
    BlocProvider.of<ClassBloc>(context).add(LoadClassesForDropdown());

    // Debug için API endpoint'lerini kontrol et
    print('API Endpoint Check:');
    print(
        'OkulDenemesi API URL: ${BlocProvider.of<OkulDenemesiBloc>(context).apiService.baseUrl}');
    try {
      final ogrenciOkulDenemeleriBloc =
          BlocProvider.of<OgrenciOkulDenemeleriBloc>(context);
      print(
          'OgrenciOkulDenemeleri API URL: ${ogrenciOkulDenemeleriBloc.repository.apiService.baseUrl}');
    } catch (e) {
      print('API URL alma hatası: $e');
    }

    // Belirli bir süre sonra verileri kontrol et ve gerekirse TEMA sınavı oluştur
    Future.delayed(const Duration(seconds: 2), () {
      _checkAndCreateExams();
    });
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void updateDenemeResult(int studentId, int denemeId, int dogru, int yanlis) {
    // Create a new model
    final denemeSonucu = OgrenciOkulDenemesi(
      ogrenciId: studentId,
      okulDenemesiId: denemeId,
      dogruSayisi: dogru,
      yanlisSayisi: yanlis,
    );

    // Dispatch an event to the bloc
    BlocProvider.of<OgrenciOkulDenemeleriBloc>(context)
        .add(UpsertOgrenciOkulDenemesi(denemeSonucu));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ClassBloc, ClassState>(
          listener: (context, state) {
            if (state is ClassError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<StudentBloc, StudentState>(
          listener: (context, state) {
            if (state is StudentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is StudentsLoaded && state.students.isNotEmpty) {
              // When students are loaded, fetch the first student's exam results
              print(
                  'Öğrenci ID ${state.students.first.id} için sınav sonuçları yükleniyor...');
              BlocProvider.of<OgrenciOkulDenemeleriBloc>(context).add(
                  LoadOgrenciOkulDenemeleriByStudent(state.students.first.id));
            }
          },
        ),
        BlocListener<OgrenciOkulDenemeleriBloc, OgrenciOkulDenemeleriState>(
          listener: (context, state) {
            if (state is OgrenciOkulDenemeleriError) {
              print('OgrenciOkulDenemeleri Error: ${state.message}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is OgrenciOkulDenemeleriLoaded) {
              print(
                  'OgrenciOkulDenemeleri yüklendi: ${state.denemeleri.length} sonuç');
            } else if (state is OgrenciOkulDenemeleriOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
        ),
        // Add listener for OkulDenemesiBloc to debug exams
        BlocListener<OkulDenemesiBloc, okul_deneme_states.OkulDenemesiState>(
          listener: (context, state) {
            if (state is okul_deneme_states.OkulDenemesiLoaded) {
              print('Yüklenen sınavlar:');
              for (var deneme in state.denemeler) {
                print('Sınav ID: ${deneme.id}, Adı: ${deneme.sinavAdi}');
              }
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Öğrenci Okul Denemeleri'),
          backgroundColor: Colors.blueGrey,
          actions: [
            BlocBuilder<StudentBloc, StudentState>(
              builder: (context, studentState) {
                return BlocBuilder<OgrenciOkulDenemeleriBloc,
                    OgrenciOkulDenemeleriState>(
                  builder: (context, denemeleriState) {
                    return BlocBuilder<OkulDenemesiBloc,
                        okul_deneme_states.OkulDenemesiState>(
                      builder: (context, okulDenemesiState) {
                        return Row(
                          children: [
                            // Add sample exam button
                            IconButton(
                              icon: const Icon(Icons.add_box),
                              tooltip: 'Örnek Sınav Ekle',
                              onPressed: () {
                                // Create an example exam if there are no exams
                                if (okulDenemesiState is okul_deneme_states
                                        .OkulDenemesiLoaded &&
                                    okulDenemesiState.denemeler.isEmpty) {
                                  // Add a test exam using the OkulDenemesiBloc
                                  final sampleExam = OkulDenemesi(
                                    sinavAdi: "Örnek Sınav 1",
                                    yanlisGoturmeOrani: 4,
                                    sinavTarihi: DateTime.now(),
                                  );

                                  BlocProvider.of<OkulDenemesiBloc>(context)
                                      .add(okul_deneme_events
                                          .OkulDenemesiCreated(sampleExam));

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Örnek sınav eklendi. Lütfen sayfayı yenileyin.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Zaten sınavlar mevcut.'),
                                      backgroundColor: Colors.blue,
                                    ),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.picture_as_pdf),
                              onPressed: () {
                                if (denemeleriState
                                        is OgrenciOkulDenemeleriLoaded &&
                                    studentState is StudentsLoaded &&
                                    okulDenemesiState is okul_deneme_states
                                        .OkulDenemesiLoaded) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          OkulDenemeleriPdfScreen(
                                        students: studentState.students,
                                        denemeler: okulDenemesiState.denemeler,
                                        ogrenciDenemeleri:
                                            denemeleriState.denemeleri,
                                        selectedClass:
                                            selectedClass ?? 'Seçili Sınıf',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Class dropdown
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<ClassBloc, ClassState>(
                builder: (context, state) {
                  if (state is ClassLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ClassesLoaded) {
                    return DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Sınıf Seçin'),
                      value: selectedClass,
                      items: state.classes.map((Classes classItem) {
                        return DropdownMenuItem<String>(
                          value: classItem.sinifAdi,
                          child: Text(classItem.sinifAdi),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedClass = value;
                        });
                        if (value != null) {
                          // Use StudentBloc to load students by class
                          BlocProvider.of<StudentBloc>(context)
                              .add(LoadStudentsByClass(value));
                        }
                      },
                    );
                  } else {
                    return const Text('Sınıflar yüklenemedi');
                  }
                },
              ),
            ),

            // Results table
            Expanded(
              child: BlocBuilder<StudentBloc, StudentState>(
                builder: (context, studentState) {
                  if (studentState is StudentLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (studentState is StudentsLoaded) {
                    return BlocBuilder<OgrenciOkulDenemeleriBloc,
                        OgrenciOkulDenemeleriState>(
                      builder: (context, denemeleriState) {
                        return BlocBuilder<OkulDenemesiBloc,
                            okul_deneme_states.OkulDenemesiState>(
                          builder: (context, okulDenemesiState) {
                            if (denemeleriState
                                    is OgrenciOkulDenemeleriLoading ||
                                okulDenemesiState
                                    is okul_deneme_states.OkulDenemesiLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (denemeleriState
                                    is OgrenciOkulDenemeleriLoaded &&
                                okulDenemesiState
                                    is okul_deneme_states.OkulDenemesiLoaded) {
                              return buildResultsTable(
                                studentState.students,
                                denemeleriState.denemeleri,
                                okulDenemesiState.denemeler,
                              );
                            } else {
                              return const Center(
                                  child: Text('Sınav sonuçları yüklenemedi'));
                            }
                          },
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text('Önce sınıf seçin'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResultsTable(
      List<Student> students,
      List<OgrenciOkulDenemesi> ogrenciDenemeleri,
      List<OkulDenemesi> denemeler) {
    return SingleChildScrollView(
      controller: _horizontalController,
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        controller: _verticalController,
        scrollDirection: Axis.vertical,
        child: Container(
          width: 215 + (denemeler.length * 120),
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            defaultColumnWidth: const FixedColumnWidth(150),
            columnWidths: {
              0: const FixedColumnWidth(60), // Öğrenci No
              1: const FixedColumnWidth(155), // Ad Soyad
              for (int i = 0; i < denemeler.length; i++)
                i + 2: const FixedColumnWidth(120),
            },
            children: [
              // Header row
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                ),
                children: [
                  _buildHeaderCell("Öğrenci No"),
                  _buildHeaderCell("Adı Soyadı"),
                  ...denemeler
                      .map((deneme) => _buildHeaderCell(deneme.sinavAdi)),
                ],
              ),
              // D/Y/N subheader row
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                ),
                children: [
                  _buildEmptyCell(),
                  _buildEmptyCell(),
                  ...denemeler.map((deneme) => Container(
                        padding: const EdgeInsets.all(8),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('D',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Y',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('N',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )),
                ],
              ),
              // Student rows
              ...students.asMap().entries.map((entry) {
                final index = entry.key;
                final student = entry.value;
                return TableRow(
                  decoration: BoxDecoration(
                    color: index.isEven ? Colors.white : Colors.grey.shade50,
                  ),
                  children: [
                    _buildCell(student.ogrenciNo.toString()),
                    _buildCell(student.adSoyad),
                    ...denemeler.map((deneme) =>
                        _buildDenemeCell(student, deneme, ogrenciDenemeleri)),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDenemeCell(Student student, OkulDenemesi deneme,
      List<OgrenciOkulDenemesi> ogrenciDenemeleri) {
    var ogrenciDeneme = ogrenciDenemeleri.firstWhere(
      (sonuc) =>
          sonuc.ogrenciId == student.id && sonuc.okulDenemesiId == deneme.id,
      orElse: () => OgrenciOkulDenemesi(
        ogrenciId: student.id,
        okulDenemesiId: deneme.id!,
      ),
    );

    // Check if student did not take the exam
    bool sinavaGirmemis = ogrenciDeneme.id == null;

    String keyD = '${student.id}_${deneme.id}_D';
    String keyY = '${student.id}_${deneme.id}_Y';

    if (!controllers.containsKey(keyD)) {
      controllers[keyD] = TextEditingController(
          text: ogrenciDeneme.dogruSayisi?.toString() ?? '');
    } else {
      controllers[keyD]!.text = ogrenciDeneme.dogruSayisi?.toString() ?? '';
    }

    if (!controllers.containsKey(keyY)) {
      controllers[keyY] = TextEditingController(
          text: ogrenciDeneme.yanlisSayisi?.toString() ?? '');
    } else {
      controllers[keyY]!.text = ogrenciDeneme.yanlisSayisi?.toString() ?? '';
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: sinavaGirmemis ? Colors.grey.shade100 : null,
        border: sinavaGirmemis
            ? Border.all(color: Colors.red.shade200, width: 1)
            : null,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Doğru Sayısı TextField
              SizedBox(
                width: 35,
                child: TextField(
                  controller: controllers[keyD],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: sinavaGirmemis
                        ? Colors.grey.shade200
                        : Colors.yellow.shade100,
                    contentPadding: const EdgeInsets.all(4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Düzenleme tamamlandığında veya alan gönderildiğinde kaydet
                  onEditingComplete: () {
                    _saveExamResult(student.id, deneme.id!, controllers[keyD]!,
                        controllers[keyY]!);
                  },
                  // Klavyede ENTER tuşuna basıldığında kaydet
                  onSubmitted: (value) {
                    _saveExamResult(student.id, deneme.id!, controllers[keyD]!,
                        controllers[keyY]!);
                  },
                ),
              ),
              // Yanlış Sayısı TextField
              SizedBox(
                width: 35,
                child: TextField(
                  controller: controllers[keyY],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: sinavaGirmemis
                        ? Colors.grey.shade200
                        : Colors.red.shade100,
                    contentPadding: const EdgeInsets.all(2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Düzenleme tamamlandığında veya alan gönderildiğinde kaydet
                  onEditingComplete: () {
                    _saveExamResult(student.id, deneme.id!, controllers[keyD]!,
                        controllers[keyY]!);
                  },
                  // Klavyede ENTER tuşuna basıldığında kaydet
                  onSubmitted: (value) {
                    _saveExamResult(student.id, deneme.id!, controllers[keyD]!,
                        controllers[keyY]!);
                  },
                ),
              ),
              // Net Sayısı Display
              Container(
                width: 35,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: sinavaGirmemis
                    ? const Icon(Icons.warning, color: Colors.orange, size: 12)
                    : Text(
                        calculateNet(
                          ogrenciDeneme.dogruSayisi ?? 0,
                          ogrenciDeneme.yanlisSayisi ?? 0,
                          deneme.yanlisGoturmeOrani ?? 4,
                        ).toStringAsFixed(2),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      ),
              ),
            ],
          ),
          // Indicator for students who didn't take the exam
          if (sinavaGirmemis)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'GİRMEDİ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double calculateNet(int dogru, int yanlis, int yanlisGoturmeOrani) {
    if (yanlisGoturmeOrani == 0) return dogru.toDouble();
    return double.parse(
        (dogru - (yanlis / yanlisGoturmeOrani)).toStringAsFixed(2));
  }

  Widget _buildEmptyCell({double height = 30}) {
    return Container(
      height: height,
      color: Colors.white,
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(4),
      color: Colors.grey.shade300,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCell(String text, {Color? backgroundColor}) {
    return Container(
      padding: const EdgeInsets.all(4),
      color: backgroundColor ?? Colors.white,
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  // Sınavları kontrol et ve gerekirse TEMA sınavı oluştur
  void _checkAndCreateExams() {
    final okulDenemesiState = BlocProvider.of<OkulDenemesiBloc>(context).state;

    if (okulDenemesiState is okul_deneme_states.OkulDenemesiLoaded) {
      print('Mevcut Sınavlar:');
      for (var deneme in okulDenemesiState.denemeler) {
        print('ID: ${deneme.id}, Adı: ${deneme.sinavAdi}');
      }

      // Ekranda "TEMA" adında bir sınav yoksa oluştur
      bool hasTemaSinav = okulDenemesiState.denemeler
          .any((deneme) => deneme.sinavAdi == "TEMA");

      if (!hasTemaSinav) {
        print('TEMA sınavı bulunamadı, oluşturuluyor...');
        final temaSinav = OkulDenemesi(
          sinavAdi: "TEMA",
          yanlisGoturmeOrani: 4,
          sinavTarihi: DateTime.now(),
        );

        BlocProvider.of<OkulDenemesiBloc>(context)
            .add(okul_deneme_events.OkulDenemesiCreated(temaSinav));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'TEMA sınavı oluşturuldu. Sayfayı yenileyerek kullanabilirsiniz.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      print('Sınavlar henüz yüklenmedi, daha sonra tekrar denenecek...');
      // Bir süre sonra tekrar dene
      Future.delayed(const Duration(seconds: 3), () {
        _checkAndCreateExams();
      });
    }
  }

  void _saveExamResult(
      int studentId,
      int denemeId,
      TextEditingController dogruController,
      TextEditingController yanlisController) {
    if (dogruController.text.isNotEmpty && yanlisController.text.isNotEmpty) {
      int dogru = int.tryParse(dogruController.text) ?? 0;
      int yanlis = int.tryParse(yanlisController.text) ?? 0;
      updateDenemeResult(studentId, denemeId, dogru, yanlis);
    }
  }
}
