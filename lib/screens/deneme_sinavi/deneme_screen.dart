import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:typed_data';

// Models
import 'package:ogrenci_takip_sistemi/models/ogrenci_denemeleri_model.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';

// BLoCs
import 'package:ogrenci_takip_sistemi/blocs/class/class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/unit/unit_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/unit/unit_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/unit/unit_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/sinif_deneme/sinif_deneme_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/sinif_deneme/sinif_deneme_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/sinif_deneme/sinif_deneme_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/ogrenci_deneme/ogrenci_deneme_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/ogrenci_deneme/ogrenci_deneme_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/ogrenci_deneme/ogrenci_deneme_state.dart';

// Widgets
import 'package:ogrenci_takip_sistemi/widgets/common/custom_button.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/error_banner.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/loading_indicator.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/dropdown_card.dart';
import 'package:ogrenci_takip_sistemi/widgets/deneme_sinavi/deneme_sinavi_card.dart';
import 'package:ogrenci_takip_sistemi/widgets/deneme_sinavi/deneme_score_dialog.dart';

// Services
import 'package:ogrenci_takip_sistemi/services/deneme_pdf_service.dart';

// Utils
import 'package:ogrenci_takip_sistemi/utils/ui_helpers.dart';

class DenemeScreen extends StatefulWidget {
  const DenemeScreen({super.key});

  @override
  _DenemeScreenState createState() => _DenemeScreenState();
}

class _DenemeScreenState extends State<DenemeScreen> {
  String? selectedClass;
  String? selectedUnit;
  Map<int, Map<int, DenemeScores>> studentDenemeScores = {};
  ScrollController horizontalScrollController = ScrollController();
  ScrollController verticalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Load initial data using BLoCs
    context.read<ClassBloc>().add(LoadClassesForDropdown());
    context.read<UnitBloc>().add(LoadUnits());
  }

  @override
  void dispose() {
    horizontalScrollController.dispose();
    verticalScrollController.dispose();
    super.dispose();
  }

  // Calculation methods
  int getTotalQuestionCount(List<dynamic> denemeList) {
    int totalQuestions = 0;
    for (var deneme in denemeList) {
      var soruSayisi = deneme['denemeSinavi']['soru_sayisi'];
      if (soruSayisi != null) {
        totalQuestions += soruSayisi as int;
      }
    }
    return totalQuestions;
  }

  int calculateTotalScore(int studentId) {
    if (!studentDenemeScores.containsKey(studentId)) return 0;
    return studentDenemeScores[studentId]!
        .values
        .fold(0, (sum, score) => sum + score.puan);
  }

  double calculateAverageScore(int studentId) {
    if (!studentDenemeScores.containsKey(studentId) ||
        studentDenemeScores[studentId]!.isEmpty) return 0.0;

    int totalScore = calculateTotalScore(studentId);
    int totalDeneme = studentDenemeScores[studentId]!.length;
    return totalDeneme > 0 ? totalScore / totalDeneme : 0.0;
  }

  // Notification methods
  void _showSuccessSnackBar(String message) {
    UIHelpers.showSnackBar(
      context: context,
      message: message,
      icon: Icons.check_circle,
      backgroundColor: Colors.green.shade600,
    );
  }

  void _showErrorSnackBar(String message) {
    UIHelpers.showSnackBar(
      context: context,
      message: message,
      icon: Icons.error_outline,
      backgroundColor: Colors.red.shade600,
    );
  }

  // PDF Generation - Using the PDF service
  Future<Uint8List> _generatePDFReport(List<dynamic> students,
      List<dynamic> denemeList, List<dynamic> units) async {
    try {
      return await DenemePdfService.generatePDFReport(
        students: students,
        denemeList: denemeList,
        units: units,
        selectedClass: selectedClass!,
        selectedUnit: selectedUnit!,
        studentDenemeScores: studentDenemeScores,
      );
    } catch (e) {
      print('PDF oluşturma hatası: $e');
      throw Exception('PDF oluşturulurken hata oluştu: $e');
    }
  }

  // Dialog for entering/editing scores
  Future<void> _showPuanDialog(int studentId, int denemeId) async {
    return showDialog(
      context: context,
      builder: (context) => DenemeScoreDialog(
        studentId: studentId,
        denemeId: denemeId,
        studentDenemeScores: studentDenemeScores,
        onSuccess: _showSuccessSnackBar,
        onError: _showErrorSnackBar,
      ),
    );
  }

  // UI Components
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: BlocBuilder<ClassBloc, ClassState>(
              builder: (context, state) {
                final classes = state is ClassesLoaded ? state.classes : [];

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: const Text('Sınıf Seçin'),
                      value: selectedClass,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                      items: classes.map((classItem) {
                        return DropdownMenuItem<String>(
                          value: classItem.sinifAdi,
                          child: Text(classItem.sinifAdi),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        if (value != null) {
                          setState(() {
                            selectedClass = value;
                          });

                          // Load students for this class
                          context.read<StudentBloc>().add(
                                LoadStudentsByClass(value),
                              );

                          // If a unit is also selected, load the exams for this class
                          if (selectedUnit != null) {
                            final classId = classes
                                .firstWhere(
                                  (c) => c.sinifAdi == value,
                                )
                                .id;
                            context.read<SinifDenemeBloc>().add(
                                  LoadExamsByClass(classId),
                                );

                            // Also load student exam results
                            context
                                .read<OgrenciDenemeBloc>()
                                .add(LoadAllOgrenciDenemeResults());
                          }
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: BlocBuilder<UnitBloc, UnitState>(
              builder: (context, state) {
                final units = state is UnitsLoaded ? state.units : [];

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: const Text('Ünite Seçin'),
                      value: selectedUnit,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                      items: units.map((unit) {
                        return DropdownMenuItem<String>(
                          value: unit.id.toString(),
                          child: Text(unit.unitName),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        setState(() {
                          selectedUnit = value;
                        });

                        if (selectedClass != null) {
                          final classId = context
                              .read<ClassBloc>()
                              .classes
                              .firstWhere(
                                (c) => c.sinifAdi == selectedClass,
                              )
                              .id;
                          context.read<SinifDenemeBloc>().add(
                                LoadExamsByClass(classId),
                              );

                          // Also load student exam results
                          context
                              .read<OgrenciDenemeBloc>()
                              .add(LoadAllOgrenciDenemeResults());
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalQuestionCount(List<dynamic> denemeList) {
    int totalQuestions = getTotalQuestionCount(denemeList);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.quiz_outlined, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Text(
            'Toplam Soru Sayısı: $totalQuestions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // Table components
  Widget _buildTableHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDenemeScoreCell(
      {DenemeScores? score, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            Text(
              score != null ? '${score.puan}' : 'G',
              style: TextStyle(
                color: score == null ? Colors.red : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (score != null)
              Text(
                '${score.dogru}D ${score.yanlis}Y ${score.bos}B',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalScoreCell(int total) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        total.toString(),
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAverageScoreCell(double average) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        average.toStringAsFixed(2),
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Action buttons
  Widget _buildExcelUploadButton() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['xls', 'xlsx'],
            );
            if (result != null && result.files.single.path != null) {
              context.read<OgrenciDenemeBloc>().add(
                    UploadOgrenciDenemeExcel(File(result.files.single.path!)),
                  );
            }
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.upload_file, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Excel ile ekle',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPdfDownloadButton(
      List<dynamic> students, List<dynamic> denemeList, List<dynamic> units) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            try {
              final pdfData =
                  await _generatePDFReport(students, denemeList, units);
              final fileName =
                  '${selectedClass}_${units.firstWhere((u) => u.id.toString() == selectedUnit).unitName}_Deneme_Raporu.pdf';

              final result = await FilePicker.platform.saveFile(
                fileName: fileName,
                allowedExtensions: ['pdf'],
                type: FileType.custom,
              );

              if (result != null) {
                final file = File(result);
                await file.writeAsBytes(pdfData);
                _showSuccessSnackBar('PDF başarıyla kaydedildi');
              }
            } catch (e) {
              _showErrorSnackBar('PDF oluşturulurken hata: $e');
            }
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'PDF İndir',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Results table
  Widget _buildResultsTable(List<dynamic> students, List<dynamic> denemeList) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Scrollbar(
          thumbVisibility: true,
          controller: horizontalScrollController,
          child: SingleChildScrollView(
            controller: horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: Scrollbar(
              thumbVisibility: true,
              controller: verticalScrollController,
              child: SingleChildScrollView(
                controller: verticalScrollController,
                child: Table(
                  border: TableBorder.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                  defaultColumnWidth: const FixedColumnWidth(150.0),
                  columnWidths: {
                    0: const FixedColumnWidth(50), // No sütunu
                    1: const FixedColumnWidth(170), // İsim sütunu
                    for (var i = 0; i < denemeList.length; i++)
                      i + 2: const FixedColumnWidth(100), // Deneme sütunları
                    denemeList.length + 2: const FixedColumnWidth(50), // Toplam
                    denemeList.length + 3:
                        const FixedColumnWidth(50), // Ortalama
                  },
                  children: [
                    // Başlık satırı
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                      ),
                      children: [
                        _buildTableHeaderCell('No'),
                        _buildTableHeaderCell('Öğrenci Adı'),
                        ...denemeList.map((deneme) => _buildTableHeaderCell(
                            '${deneme['denemeSinavi']['deneme_sinavi_adi']}\n(${deneme['denemeSinavi']['soru_sayisi']} soru)')),
                        _buildTableHeaderCell('Toplam'),
                        _buildTableHeaderCell('Ortalama'),
                      ],
                    ),
                    // Veri satırları
                    ...students.map((student) {
                      return TableRow(
                        children: [
                          _buildTableCell(
                              student.ogrenciNo?.toString() ?? 'N/A'),
                          _buildTableCell(
                              student.adSoyad ?? 'Bilinmeyen Öğrenci'),
                          ...denemeList.map((deneme) {
                            var denemeScores = studentDenemeScores[student.id]
                                ?[deneme['deneme_sinavi_id']];
                            return _buildDenemeScoreCell(
                              score: denemeScores,
                              onTap: () => _showPuanDialog(
                                  student.id, deneme['deneme_sinavi_id']),
                            );
                          }),
                          _buildTotalScoreCell(calculateTotalScore(student.id)),
                          _buildAverageScoreCell(
                              calculateAverageScore(student.id)),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deneme Sınavları'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
        actions: [
          // Upload Excel Button
          _buildExcelUploadButton(),

          // PDF Download Button
          BlocBuilder<UnitBloc, UnitState>(
            builder: (context, unitState) {
              return BlocBuilder<SinifDenemeBloc, SinifDenemeState>(
                builder: (context, classExamState) {
                  return BlocBuilder<StudentBloc, StudentState>(
                    builder: (context, studentState) {
                      final units =
                          unitState is UnitsLoaded ? unitState.units : [];
                      final students = studentState is StudentsLoaded
                          ? studentState.students
                          : [];
                      List<dynamic> denemeList = [];

                      if (classExamState is ExamsByClassLoaded) {
                        denemeList = classExamState.examsByClass;
                      }

                      if (selectedClass != null &&
                          selectedUnit != null &&
                          students.isNotEmpty &&
                          denemeList.isNotEmpty) {
                        return _buildPdfDownloadButton(
                            students, denemeList, units);
                      } else {
                        return const SizedBox(); // Hide PDF button when data is not ready
                      }
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),

          // Main content based on selections
          Expanded(
            child: BlocConsumer<OgrenciDenemeBloc, OgrenciDenemeState>(
              listener: (context, state) {
                if (state is OgrenciDenemeOperationSuccess) {
                  _showSuccessSnackBar(state.message);
                } else if (state is OgrenciDenemeError) {
                  _showErrorSnackBar(state.message);
                }

                // Update the local scores map when results are loaded
                if (state is OgrenciDenemeResultsLoaded) {
                  setState(() {
                    studentDenemeScores = {};
                    for (var result in state.results) {
                      studentDenemeScores.putIfAbsent(
                          result.ogrenciId, () => {});
                      studentDenemeScores[result.ogrenciId]![
                          result.denemeSinaviId] = DenemeScores(
                        dogru: result.dogru ?? 0,
                        yanlis: result.yanlis ?? 0,
                        bos: result.bos ?? 0,
                        puan: result.puan ?? 0,
                      );
                    }
                  });
                }
              },
              builder: (context, state) {
                return BlocBuilder<SinifDenemeBloc, SinifDenemeState>(
                  builder: (context, classExamState) {
                    return BlocBuilder<StudentBloc, StudentState>(
                      builder: (context, studentState) {
                        // Loading state
                        if (state is OgrenciDenemeLoading ||
                            classExamState is SinifDenemeLoading ||
                            studentState is StudentLoading) {
                          return const Center(
                            child: LoadingIndicator(),
                          );
                        }

                        // Error states
                        if (state is OgrenciDenemeError) {
                          return Center(
                            child: ErrorBanner(
                              message:
                                  'Öğrenci deneme sonuçları yüklenemedi: ${state.message}',
                              onRetry: () => context
                                  .read<OgrenciDenemeBloc>()
                                  .add(LoadAllOgrenciDenemeResults()),
                            ),
                          );
                        }

                        if (classExamState is SinifDenemeError) {
                          return Center(
                            child: ErrorBanner(
                              message:
                                  'Sınıf deneme ilişkileri yüklenemedi: ${classExamState.message}',
                              onRetry: () {
                                if (selectedClass != null) {
                                  final classId = context
                                      .read<ClassBloc>()
                                      .classes
                                      .firstWhere(
                                          (c) => c.sinifAdi == selectedClass)
                                      .id;
                                  context
                                      .read<SinifDenemeBloc>()
                                      .add(LoadExamsByClass(classId));
                                }
                              },
                            ),
                          );
                        }

                        if (studentState is StudentError) {
                          return Center(
                            child: ErrorBanner(
                              message:
                                  'Öğrenciler yüklenemedi: ${studentState.message}',
                              onRetry: () {
                                if (selectedClass != null) {
                                  context
                                      .read<StudentBloc>()
                                      .add(LoadStudentsByClass(selectedClass!));
                                }
                              },
                            ),
                          );
                        }

                        // Get the data from the states
                        final List<Student> students =
                            studentState is StudentsLoaded
                                ? studentState.students
                                : [];
                        List<dynamic> denemeList = [];

                        if (classExamState is ExamsByClassLoaded) {
                          denemeList = classExamState.examsByClass;
                        }

                        // Show content when both class and unit are selected
                        if (selectedClass != null && selectedUnit != null) {
                          if (denemeList.isEmpty) {
                            return const Center(
                              child: Text(
                                  'Bu sınıf ve ünite için deneme sınavı bulunmamaktadır.'),
                            );
                          }

                          if (students.isEmpty) {
                            return const Center(
                              child:
                                  Text('Bu sınıfta öğrenci bulunmamaktadır.'),
                            );
                          }

                          return Column(
                            children: [
                              _buildTotalQuestionCount(denemeList),
                              _buildResultsTable(students, denemeList),
                            ],
                          );
                        } else {
                          return const Center(
                            child: Text('Lütfen sınıf ve ünite seçin'),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
