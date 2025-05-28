import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:async';
import 'dart:typed_data';

import 'package:ogrenci_takip_sistemi/models/classes_model.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:ogrenci_takip_sistemi/models/units_model.dart';
import 'package:ogrenci_takip_sistemi/models/kds_model.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/unit/unit_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/unit/unit_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/unit/unit_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds/kds_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds/kds_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds/kds_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds_class/kds_class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds_class/kds_class_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/kds_class/kds_class_state.dart';
import 'package:ogrenci_takip_sistemi/utils/ui_helpers.dart';

// KDSScores model - migrated from the original code
class KDSScores {
  final int dogru;
  final int yanlis;
  final int bos;
  final int puan;

  KDSScores({
    this.dogru = 0,
    this.yanlis = 0,
    this.bos = 0,
    this.puan = 0,
  });

  Map<String, dynamic> toJson() => {
        'dogru': dogru,
        'yanlis': yanlis,
        'bos': bos,
        'puan': puan,
      };

  factory KDSScores.fromJson(Map<String, dynamic> json) => KDSScores(
        dogru: json['dogru'] ?? 0,
        yanlis: json['yanlis'] ?? 0,
        bos: json['bos'] ?? 0,
        puan: json['puan'] ?? 0,
      );
}

// Create a new bloc event class for KDS result operations
abstract class KdsResultEvent {}

class LoadStudentKdsResults extends KdsResultEvent {}

class AddStudentKdsResult extends KdsResultEvent {
  final int kdsId;
  final int studentId;
  final KDSScores scores;

  AddStudentKdsResult(this.kdsId, this.studentId, this.scores);
}

class ImportKdsResultsFromExcel extends KdsResultEvent {
  final File file;

  ImportKdsResultsFromExcel(this.file);
}

// Create a new bloc state class for KDS result operations
abstract class KdsResultState {}

class KdsResultInitial extends KdsResultState {}

class KdsResultLoading extends KdsResultState {}

class KdsResultLoaded extends KdsResultState {
  final Map<int, Map<int, KDSScores>> studentKdsScores;

  KdsResultLoaded(this.studentKdsScores);
}

class KdsResultError extends KdsResultState {
  final String message;

  KdsResultError(this.message);
}

class KdsResultSuccess extends KdsResultState {
  final String message;

  KdsResultSuccess(this.message);
}

// Create a new bloc for KDS results
class KdsResultBloc extends Bloc<KdsResultEvent, KdsResultState> {
  final http.Client _httpClient = http.Client();
  final String baseUrl = 'http://localhost:3000';
  Map<int, Map<int, KDSScores>> studentKdsScores = {};

  KdsResultBloc() : super(KdsResultInitial()) {
    on<LoadStudentKdsResults>(_onLoadStudentKdsResults);
    on<AddStudentKdsResult>(_onAddStudentKdsResult);
    on<ImportKdsResultsFromExcel>(_onImportKdsResultsFromExcel);
  }

  Future<void> _onLoadStudentKdsResults(
      LoadStudentKdsResults event, Emitter<KdsResultState> emit) async {
    emit(KdsResultLoading());
    try {
      final response = await _httpClient.get(Uri.parse('$baseUrl/student-kds'));
      if (response.statusCode == 200) {
        final kdsData = json.decode(response.body) as List<dynamic>;
        Map<int, Map<int, KDSScores>> scores = {};

        for (var record in kdsData) {
          int studentId = record['ogrenci_id'] ?? 0;
          int kdsId = record['kds_id'] ?? 0;

          if (!scores.containsKey(studentId)) {
            scores[studentId] = {};
          }

          scores[studentId]![kdsId] = KDSScores(
            dogru: record['dogru'] ?? 0,
            yanlis: record['yanlis'] ?? 0,
            bos: record['bos'] ?? 0,
            puan: record['puan'] ?? 0,
          );
        }

        studentKdsScores = scores;
        emit(KdsResultLoaded(studentKdsScores));
      } else {
        emit(KdsResultError('Failed to load student KDS scores'));
      }
    } catch (e) {
      emit(KdsResultError('Failed to load student KDS scores: $e'));
    }
  }

  Future<void> _onAddStudentKdsResult(
      AddStudentKdsResult event, Emitter<KdsResultState> emit) async {
    emit(KdsResultLoading());
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/student-kds'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'kds_id': event.kdsId,
          'ogrenci_id': event.studentId,
          'dogru': event.scores.dogru,
          'yanlis': event.scores.yanlis,
          'bos': event.scores.bos,
          'puan': event.scores.puan,
        }),
      );

      if (response.statusCode == 201) {
        // Update local state
        if (!studentKdsScores.containsKey(event.studentId)) {
          studentKdsScores[event.studentId] = {};
        }
        studentKdsScores[event.studentId]![event.kdsId] = event.scores;

        emit(KdsResultSuccess('Student KDS result added successfully'));
        emit(KdsResultLoaded(studentKdsScores));
      } else {
        emit(KdsResultError('Failed to add student KDS result'));
      }
    } catch (e) {
      emit(KdsResultError('Failed to add student KDS result: $e'));
    }
  }

  Future<void> _onImportKdsResultsFromExcel(
      ImportKdsResultsFromExcel event, Emitter<KdsResultState> emit) async {
    emit(KdsResultLoading());
    try {
      final mimeType = event.file.path.endsWith('.xlsx')
          ? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
          : 'application/vnd.ms-excel';

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/student-kds/excel'),
      );

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        event.file.path,
        contentType: MediaType.parse(mimeType),
      ));

      final response = await request.send();

      if (response.statusCode == 200) {
        // Reload the student KDS scores
        add(LoadStudentKdsResults());
        emit(KdsResultSuccess('Excel file uploaded successfully'));
      } else {
        emit(KdsResultError('Failed to import KDS results from Excel'));
      }
    } catch (e) {
      emit(KdsResultError('Failed to import KDS results from Excel: $e'));
    }
  }
}

class KdsResultScreen extends StatefulWidget {
  const KdsResultScreen({Key? key}) : super(key: key);

  @override
  _KdsResultScreenState createState() => _KdsResultScreenState();
}

class _KdsResultScreenState extends State<KdsResultScreen> {
  String? selectedClass;
  String? selectedUnit;
  List<dynamic> kdsList = [];
  List<Student> students = [];

  // StreamSubscription to handle KdsClassBloc state changes
  StreamSubscription? _kdsClassSubscription;

  @override
  void initState() {
    super.initState();

    // Initialize BLoCs
    context.read<ClassBloc>().add(LoadClassesForDropdown());
    context.read<UnitBloc>().add(LoadUnits());

    // Initialize the KDS class bloc
    context.read<KdsClassBloc>().add(KdsClassLoadingEvent());

    // Initialize the KDS result bloc
    final kdsResultBloc = BlocProvider.of<KdsResultBloc>(context);
    kdsResultBloc.add(LoadStudentKdsResults());
  }

  int getTotalQuestionCount() {
    int totalQuestions = 0;
    for (var kds in kdsList) {
      totalQuestions += (kds['calisma_soru_sayisi'] as num?)?.toInt() ?? 0;
    }
    return totalQuestions;
  }

  void _loadStudentsByClass(String className) {
    context.read<StudentBloc>().add(LoadStudentsByClass(className));
  }

  void _loadKDS(String unitId) {
    if (selectedClass == null) return;

    // Get the class ID from the selected class name
    final classState = context.read<ClassBloc>().state;
    if (classState is ClassesLoaded) {
      final classInfo = classState.classes.firstWhere(
        (c) => c.sinifAdi == selectedClass,
        orElse: () => throw Exception('Sınıf bulunamadı'),
      );
      int classId = classInfo.id;

      // Cancel any existing subscription
      _kdsClassSubscription?.cancel();

      // Load the KDS list for the selected class and unit
      final kdsClassBloc = context.read<KdsClassBloc>();
      kdsClassBloc.add(LoadKdsByClass(classId));

      // Update KDS list when the data is loaded
      _kdsClassSubscription = kdsClassBloc.stream.listen((state) {
        if ((state is KdsAssignedListLoaded ||
                state is KdsClassOperationSuccess) &&
            state.assignedKdsList.isNotEmpty) {
          // Transform KdsClass objects to the format expected by kdsList
          setState(() {
            kdsList = state.assignedKdsList
                .map((kdsClass) => {
                      'id': kdsClass.kdsId,
                      'kds_adi': kdsClass.kdsName ?? 'KDS Adı',
                      'calisma_soru_sayisi': kdsClass.questionCount ?? 0,
                    })
                .toList();
          });
        }
      });
    }
  }

  void _showPuanDialog(int kdsId, int studentId,
      Map<int, Map<int, KDSScores>> studentKdsScores) {
    TextEditingController dogruController = TextEditingController();
    TextEditingController yanlisController = TextEditingController();
    TextEditingController bosController = TextEditingController();
    TextEditingController puanController = TextEditingController();

    // Fill existing values if available
    if (studentKdsScores[studentId]?[kdsId] != null) {
      final scores = studentKdsScores[studentId]![kdsId]!;
      dogruController.text = scores.dogru.toString();
      yanlisController.text = scores.yanlis.toString();
      bosController.text = scores.bos.toString();
      puanController.text = scores.puan.toString();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            const Text('Sınav Sonuçları'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: dogruController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Doğru',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: const Icon(Icons.check_circle_outline,
                            color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: yanlisController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Yanlış',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: const Icon(Icons.cancel_outlined,
                            color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: bosController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Boş',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: const Icon(Icons.remove_circle_outline,
                            color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: puanController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Puan',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        prefixIcon: const Icon(Icons.score, color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('İptal', style: TextStyle(color: Colors.grey.shade700)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Kaydet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              try {
                final scores = KDSScores(
                  dogru: int.tryParse(dogruController.text) ?? 0,
                  yanlis: int.tryParse(yanlisController.text) ?? 0,
                  bos: int.tryParse(bosController.text) ?? 0,
                  puan: int.tryParse(puanController.text) ?? 0,
                );

                // Add the scores to the bloc
                context
                    .read<KdsResultBloc>()
                    .add(AddStudentKdsResult(kdsId, studentId, scores));

                Navigator.of(context).pop();
              } catch (e) {
                UIHelpers.showErrorMessage(context, 'Geçerli değerler giriniz');
              }
            },
          ),
        ],
      ),
    );
  }

  void _pickAndUploadExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      context.read<KdsResultBloc>().add(ImportKdsResultsFromExcel(file));
    }
  }

  // Helper functions for calculating totals and averages
  int calculateTotalScore(int studentId, Map<int, Map<int, KDSScores>> scores) {
    if (!scores.containsKey(studentId)) return 0;
    return scores[studentId]!.values.fold(0, (sum, score) => sum + score.puan);
  }

  double calculateAverageScore(
      int studentId, Map<int, Map<int, KDSScores>> scores) {
    if (!scores.containsKey(studentId) || scores[studentId]!.isEmpty)
      return 0.0;

    int totalScore = calculateTotalScore(studentId, scores);
    int totalKDS = scores[studentId]!.length;
    return totalKDS > 0 ? totalScore / totalKDS : 0.0;
  }

  // PDF Generation function (simplified)
  Future<Uint8List> _generateKDSReportPDF(
      Map<int, Map<int, KDSScores>> studentKdsScores) async {
    try {
      final pdf = pw.Document();
      final fontData = await rootBundle.load("assets/DejaVuSans.ttf");
      final ttf = pw.Font.ttf(fontData.buffer.asByteData());
      final boldFontData = await rootBundle.load("assets/dejavu-sans-bold.ttf");
      final boldTtf = pw.Font.ttf(boldFontData.buffer.asByteData());

      // PDF Generation logic would go here

      // This is a simplified implementation - the full implementation would
      // require more code to format the PDF properly

      return pdf.save();
    } catch (e) {
      print('PDF oluşturma hatası: $e');
      throw Exception('PDF oluşturulurken hata oluştu: $e');
    }
  }

  Widget _buildDropdowns() {
    return BlocBuilder<ClassBloc, ClassState>(
      builder: (context, classState) {
        return BlocBuilder<UnitBloc, UnitState>(
          builder: (context, unitState) {
            final classes =
                classState is ClassesLoaded ? classState.classes : <Classes>[];
            final units = unitState is UnitsLoaded ? unitState.units : <Unit>[];

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
                    child: Container(
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
                          icon:
                              const Icon(Icons.arrow_drop_down_circle_outlined),
                          items: classes.map<DropdownMenuItem<String>>(
                              (Classes classItem) {
                            return DropdownMenuItem<String>(
                              value: classItem.sinifAdi,
                              child: Text(classItem.sinifAdi),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedClass = value;
                              });
                              _loadStudentsByClass(value);
                              if (selectedUnit != null) {
                                _loadKDS(selectedUnit!);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
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
                          icon:
                              const Icon(Icons.arrow_drop_down_circle_outlined),
                          items:
                              units.map<DropdownMenuItem<String>>((Unit unit) {
                            return DropdownMenuItem<String>(
                              value: unit.id.toString(),
                              child: Text(unit.unitName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedUnit = value;
                              });
                              _loadKDS(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTotalQuestionCount() {
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
            'Toplam Soru Sayısı: ${getTotalQuestionCount()}',
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

  List<DataColumn> _buildDataColumns() {
    List<DataColumn> columns = [
      DataColumn(
        label: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Text(
            'No',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      DataColumn(
        label: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Text(
            'Öğrenci Adı',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ];

    for (var kds in kdsList) {
      columns.add(
        DataColumn(
          label: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  kds['kds_adi']?.toString() ?? 'KDS',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${kds['calisma_soru_sayisi'] ?? 0} soru',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    columns.addAll([
      DataColumn(
        label: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Text(
            'Toplam',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      DataColumn(
        label: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Text(
            'Ortalama',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ]);

    return columns;
  }

  List<DataRow> _buildDataRows(Map<int, Map<int, KDSScores>> studentKdsScores) {
    List<DataRow> rows = [];
    int rowIndex = 0;

    for (var student in students) {
      List<DataCell> cells = [
        DataCell(Text(student.ogrenciNo?.toString() ?? 'N/A')),
        DataCell(Text(student.adSoyad ?? 'Bilinmeyen Öğrenci')),
      ];

      for (var kds in kdsList) {
        final kdsId = kds['id'] as int?;
        if (kdsId == null) continue;

        var kdsScores = studentKdsScores[student.id]?[kdsId];
        cells.add(
          DataCell(
            Container(
              alignment: Alignment.center,
              height: 48,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () =>
                      _showPuanDialog(kdsId, student.id, studentKdsScores),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: kdsScores != null
                            ? Colors.blue.shade100
                            : Colors.grey.shade200,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          kdsScores != null ? '${kdsScores.puan}' : 'G',
                          style: TextStyle(
                            color:
                                kdsScores == null ? Colors.red : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (kdsScores != null) ...[
                          const SizedBox(width: 4),
                          Text(
                            '${kdsScores.dogru}D ${kdsScores.yanlis}Y ${kdsScores.bos}B',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      int totalPuan = calculateTotalScore(student.id, studentKdsScores);
      double ortalamaPuan = calculateAverageScore(student.id, studentKdsScores);

      cells.addAll([
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              totalPuan.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              ortalamaPuan.toStringAsFixed(2),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ]);

      rows.add(
        DataRow(
          color: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              return rowIndex.isEven ? Colors.grey.shade50 : Colors.white;
            },
          ),
          cells: cells,
        ),
      );
      rowIndex++;
    }

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KDS Ekranı'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
        actions: [
          BlocBuilder<KdsResultBloc, KdsResultState>(
            builder: (context, state) {
              if (state is KdsResultLoaded &&
                  selectedClass != null &&
                  selectedUnit != null) {
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
                          final pdfData = await _generateKDSReportPDF(
                              state.studentKdsScores);

                          final unitName = context
                              .read<UnitBloc>()
                              .units
                              .firstWhere(
                                  (unit) => unit.id.toString() == selectedUnit)
                              .unitName;

                          final fileName =
                              '${selectedClass}_${unitName}_KDS_Raporu.pdf';

                          final result = await FilePicker.platform.saveFile(
                            fileName: fileName,
                            allowedExtensions: ['pdf'],
                            type: FileType.custom,
                          );

                          if (result != null) {
                            final file = File(result);
                            await file.writeAsBytes(pdfData);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('PDF başarıyla kaydedildi')),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('PDF oluşturulurken hata: $e')),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: const [
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
              return Container();
            },
          ),
          Container(
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
                onTap: _pickAndUploadExcel,
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
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocListener<KdsResultBloc, KdsResultState>(
        listener: (context, state) {
          if (state is KdsResultSuccess) {
            UIHelpers.showSuccessMessage(context, state.message);
          } else if (state is KdsResultError) {
            UIHelpers.showErrorMessage(context, state.message);
          }
        },
        child: Column(
          children: [
            _buildDropdowns(),
            if (kdsList.isNotEmpty) _buildTotalQuestionCount(),
            BlocBuilder<StudentBloc, StudentState>(
              builder: (context, studentState) {
                if (studentState is StudentsLoaded) {
                  students = studentState.students;

                  return BlocBuilder<KdsResultBloc, KdsResultState>(
                    builder: (context, kdsResultState) {
                      if (kdsResultState is KdsResultLoaded) {
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: DataTable(
                                    headingRowColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) =>
                                          Colors.grey.shade100,
                                    ),
                                    columnSpacing: 15,
                                    dataRowHeight: 60,
                                    headingRowHeight: 60,
                                    horizontalMargin: 12,
                                    columns: _buildDataColumns(),
                                    rows: _buildDataRows(
                                        kdsResultState.studentKdsScores),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      } else if (kdsResultState is KdsResultLoading) {
                        return const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else {
                        return Expanded(
                          child: Center(
                            child: Text(
                              'KDS sonuçları yüklenemedi.',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  );
                } else if (studentState is StudentLoading) {
                  return const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  return Expanded(
                    child: Center(
                      child: Text(
                        'Lütfen bir sınıf seçin',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _kdsClassSubscription?.cancel();
    super.dispose();
  }
}
