import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: unused_import
import 'package:ogrenci_takip_sistemi/screens/deneme_sinavi/deneme_screen.dart';
import 'package:ogrenci_takip_sistemi/screens/deneme_sinavi/deneme_sinavi_add_screen.dart';
import 'package:ogrenci_takip_sistemi/blocs/sinif_deneme/sinif_deneme_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/sinif_deneme/sinif_deneme_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/sinif_deneme/sinif_deneme_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/deneme_sinavi/deneme_sinavi_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/deneme_sinavi/deneme_sinavi_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/deneme_sinavi/deneme_sinavi_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_state.dart';

class ExamAssignmentScreen extends StatefulWidget {
  const ExamAssignmentScreen({super.key});

  @override
  _ExamAssignmentScreenState createState() => _ExamAssignmentScreenState();
}

class _ExamAssignmentScreenState extends State<ExamAssignmentScreen> {
  String? selectedClassLevel;
  List<String> classLevels = ["5", "6", "7", "8"];
  String? selectedClass;
  String? selectedExamName;
  int? selectedExamId;
  bool isClassLevelSelected = true;
  List<int> selectedExamIds = [];
  String selectedOption = 'level';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    context.read<DenemeSinaviBloc>().add(LoadDenemeSinavlari());
    context.read<ClassBloc>().add(LoadClasses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Deneme Sınavı Atama"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Deneme Sınavı Ekle',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddDenemeSinaviScreen(),
                ),
              ).then((_) {
                context.read<DenemeSinaviBloc>().add(LoadDenemeSinavlari());
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.assessment),
            tooltip: 'Deneme Kontrol',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DenemeScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOptionsSection(),
              const SizedBox(height: 16),
              _buildExamList(),
              _buildAssignedExams(),
              const SizedBox(height: 16),
              _buildAssignButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Deneme Sınavı Atama Seçenekleri",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Sınıf Seviyesine Göre'),
                value: 'level',
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value!;
                    isClassLevelSelected = true;
                    selectedClass = null;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Belirli Sınıfa Göre'),
                value: 'class',
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value!;
                    isClassLevelSelected = false;
                    selectedClassLevel = null;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isClassLevelSelected)
          _buildClassLevelDropdown()
        else
          _buildClassDropdown(),
      ],
    );
  }

  Widget _buildClassLevelDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Sınıf Seviyesi',
        border: OutlineInputBorder(),
      ),
      value: selectedClassLevel,
      items: classLevels.map((String level) {
        return DropdownMenuItem<String>(
          value: level,
          child: Text('$level. Sınıf'),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedClassLevel = newValue;
        });
      },
    );
  }

  Widget _buildClassDropdown() {
    return BlocBuilder<ClassBloc, ClassState>(
      builder: (context, state) {
        if (state is ClassLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ClassesLoaded) {
          final classes = state.classes;
          return DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Sınıf',
              border: OutlineInputBorder(),
            ),
            value: selectedClass,
            items: classes.map((classItem) {
              return DropdownMenuItem<String>(
                value: classItem.id.toString(),
                child: Text(classItem.sinifAdi),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedClass = newValue;
                if (newValue != null) {
                  context.read<SinifDenemeBloc>().add(
                        LoadExamsByClass(int.parse(newValue)),
                      );
                }
              });
            },
          );
        } else {
          return const Text('Sınıflar yüklenemedi');
        }
      },
    );
  }

  Widget _buildExamList() {
    return BlocBuilder<DenemeSinaviBloc, DenemeSinaviState>(
      builder: (context, state) {
        if (state is DenemeSinaviLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DenemeSinavlariLoaded) {
          final exams = state.denemeSinavlari;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Deneme Sınavları",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: exams.length,
                  itemBuilder: (context, index) {
                    final exam = exams[index];
                    return CheckboxListTile(
                      title: Text(exam.denemeSinaviAdi ?? 'İsimsiz Deneme'),
                      subtitle: Text('Soru Sayısı: ${exam.soruSayisi}'),
                      value: selectedExamIds.contains(exam.id),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true && exam.id != null) {
                            selectedExamIds.add(exam.id!);
                            selectedExamName = exam.denemeSinaviAdi;
                            selectedExamId = exam.id;
                          } else if (exam.id != null) {
                            selectedExamIds.remove(exam.id);
                            if (selectedExamId == exam.id) {
                              selectedExamName = null;
                              selectedExamId = null;
                            }
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          );
        } else {
          return const Text('Deneme sınavları yüklenemedi');
        }
      },
    );
  }

  Widget _buildAssignedExams() {
    return BlocBuilder<SinifDenemeBloc, SinifDenemeState>(
      builder: (context, state) {
        if (state is ExamsByClassLoaded &&
            !isClassLevelSelected &&
            selectedClass != null) {
          final exams = state.examsByClass;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                "Sınıfa Atanmış Deneme Sınavları",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: exams.isEmpty
                    ? const Center(
                        child: Text(
                            'Bu sınıfa atanmış deneme sınavı bulunmamaktadır.'))
                    : ListView.builder(
                        itemCount: exams.length,
                        itemBuilder: (context, index) {
                          final exam = exams[index];
                          return ListTile(
                            title: Text(exam['name'] ?? 'İsimsiz Deneme'),
                            subtitle: Text(
                                'Tarih: ${exam['exam_date'] ?? 'Tarih Yok'}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteConfirmDialog(
                                  int.parse(selectedClass!),
                                  exam['id'],
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showDeleteConfirmDialog(int classId, int examId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Deneme Sınavı Atamayı Sil'),
          content: const Text(
              'Bu deneme sınavı atamasını silmek istediğinize emin misiniz?'),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Sil'),
              onPressed: () {
                context
                    .read<SinifDenemeBloc>()
                    .add(DeleteSinifDeneme(classId, examId));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAssignButton() {
    return BlocListener<SinifDenemeBloc, SinifDenemeState>(
      listener: (context, state) {
        if (state is SinifDenemeOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          // Refresh the assigned exams if a specific class is selected
          if (!isClassLevelSelected && selectedClass != null) {
            context.read<SinifDenemeBloc>().add(
                  LoadExamsByClass(int.parse(selectedClass!)),
                );
          }
        } else if (state is SinifDenemeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: selectedExamIds.isEmpty
              ? null
              : () {
                  _assignExams();
                },
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Deneme Sınavı Ata',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
        ),
      ),
    );
  }

  void _assignExams() {
    if (selectedExamIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen en az bir deneme sınavı seçin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    if (isClassLevelSelected && selectedClassLevel != null) {
      _assignToClassLevel();
    } else if (!isClassLevelSelected && selectedClass != null) {
      _assignToSpecificClass();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir sınıf seviyesi veya sınıf seçin'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  void _assignToClassLevel() {
    for (var examId in selectedExamIds) {
      final data = {'deneme_sinavi_id': examId};

      switch (selectedClassLevel) {
        case "5":
          context.read<SinifDenemeBloc>().add(AssignExamToFifthGrade(data));
          break;
        case "6":
          context.read<SinifDenemeBloc>().add(AssignExamToSixthGrade(data));
          break;
        case "7":
          context.read<SinifDenemeBloc>().add(AssignExamToSeventhGrade(data));
          break;
        case "8":
          context.read<SinifDenemeBloc>().add(AssignExamToEighthGrade(data));
          break;
      }
    }

    setState(() {
      isLoading = false;
      selectedExamIds = [];
    });
  }

  void _assignToSpecificClass() {
    for (var examId in selectedExamIds) {
      context.read<SinifDenemeBloc>().add(
            AssignExamToClass(examId, int.parse(selectedClass!)),
          );
    }

    setState(() {
      isLoading = false;
      selectedExamIds = [];
    });
  }
}
