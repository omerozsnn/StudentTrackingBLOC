import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah/prayer_surah_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah/prayer_surah_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah/prayer_surah_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah_student/prayer_surah_student_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah_student/prayer_surah_student_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/prayer_surah_student/prayer_surah_student_state.dart';
import 'package:ogrenci_takip_sistemi/models/prayer_surah_model.dart';
import 'package:ogrenci_takip_sistemi/screens/prayer_surah/prayer_surah_management_page.dart';
import 'package:ogrenci_takip_sistemi/screens/prayer_surah/prayer_surah_tracking_screen.dart';
import 'package:ogrenci_takip_sistemi/utils/snackbar_helper.dart';
import 'package:ogrenci_takip_sistemi/widgets/prayer_surah/student_selection_card.dart';
import 'package:http/http.dart' as http;
import 'package:ogrenci_takip_sistemi/blocs/class/class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/class/class_state.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';

class PrayerSurahAssignmentScreen extends StatefulWidget {
  const PrayerSurahAssignmentScreen({Key? key}) : super(key: key);

  @override
  _PrayerSurahAssignmentScreenState createState() =>
      _PrayerSurahAssignmentScreenState();
}

class _PrayerSurahAssignmentScreenState
    extends State<PrayerSurahAssignmentScreen> {
  Uint8List? studentImage;

  @override
  void initState() {
    super.initState();
    // Load prayer surahs
    context.read<PrayerSurahBloc>().add(LoadPrayerSurahs());
    // Load classes from class bloc
    context.read<ClassBloc>().add(LoadClassesForDropdown());
  }

  Future<void> loadStudentImage(int studentId) async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/student/$studentId/image'));
      if (response.statusCode == 200) {
        setState(() {
          studentImage = response.bodyBytes;
        });
      }
    } catch (error) {
      debugPrint('Öğrenci resmi yüklenemedi: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PrayerSurahStudentBloc, PrayerSurahStudentState>(
      listener: (context, state) {
        if (state.status == PrayerSurahStudentStatus.failure &&
            state.errorMessage != null) {
          SnackbarHelper.showErrorSnackBar(
            context,
            state.errorMessage!,
          );
        } else if (state.status == PrayerSurahStudentStatus.success) {
          // Optionally show success message for certain operations
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Sınıf ve sure/dua seçimi
            _buildSelectionArea(),
            const SizedBox(height: 20),
            // Öğrenci listesi
            _buildStudentList(),
            // Atama butonları
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionArea() {
    return BlocBuilder<PrayerSurahStudentBloc, PrayerSurahStudentState>(
      builder: (context, prayerSurahStudentState) {
        return Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 4)
            ],
          ),
          child: Row(
            children: [
              // Sınıf seçimi dropdown
              Expanded(
                child: _buildClassDropdown(prayerSurahStudentState),
              ),
              const SizedBox(width: 16),
              // Sure/Dua seçimi dropdown
              Expanded(
                child: _buildPrayerSurahDropdown(prayerSurahStudentState),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClassDropdown(PrayerSurahStudentState prayerSurahStudentState) {
    // We should get classes from the ClassBloc
    return BlocBuilder<ClassBloc, ClassState>(
      builder: (context, classState) {
        if (classState is ClassLoading && classState.classes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (classState.classes.isEmpty) {
          return const Text('Henüz sınıf eklenmemiş.');
        }

        return DropdownButtonFormField<Classes>(
          value: classState.selectedClass,
          decoration: InputDecoration(
            labelText: 'Sınıf Seçin',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          items: classState.classes.map((Classes classData) {
            return DropdownMenuItem<Classes>(
              value: classData,
              child: Text(
                classData.sinifAdi,
                style: const TextStyle(color: Colors.black),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              // Dispatch event to ClassBloc to update its state
              context.read<ClassBloc>().add(SelectClass(newValue));
              // Dispatch event to PrayerSurahStudentBloc to update its state
              context
                  .read<PrayerSurahStudentBloc>()
                  .add(SetSelectedClass(newValue.sinifAdi)); // Assuming SetSelectedClass takes a string
            }
          },
        );
      },
    );
  }

  Widget _buildPrayerSurahDropdown(
      PrayerSurahStudentState prayerSurahStudentState) {
    return BlocBuilder<PrayerSurahBloc, PrayerSurahState>(
      builder: (context, prayerSurahState) {
        if (prayerSurahState.status == PrayerSurahStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (prayerSurahState.prayerSurahs.isEmpty) {
          return const Text('Henüz sure veya dua eklenmemiş.');
        }

        return DropdownButtonFormField<int>(
          value: prayerSurahStudentState.selectedPrayerSurahId,
          decoration: InputDecoration(
            labelText: 'Sure/Dua Seçin',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          items: prayerSurahState.prayerSurahs.map((PrayerSurah prayerSurah) {
            return DropdownMenuItem<int>(
              value: prayerSurah.id,
              child: Text(prayerSurah.duaSureAdi),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              context
                  .read<PrayerSurahStudentBloc>()
                  .add(SetSelectedPrayerSurahId(newValue));
            }
          },
        );
      },
    );
  }

  Widget _buildStudentList() {
    return BlocBuilder<PrayerSurahStudentBloc, PrayerSurahStudentState>(
      builder: (context, state) {
        if (state.status == PrayerSurahStudentStatus.loading) {
          return const Expanded(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.students.isEmpty) {
          return const Expanded(
            child: Center(
              child: Text('Önce bir sınıf seçin veya sınıfta öğrenci yok.'),
            ),
          );
        }

        return Expanded(
          flex: 2,
          child: ListView.builder(
            itemCount: state.students.length,
            itemBuilder: (context, index) {
              final student = state.students[index];
              final isSelected = state.selectedStudents[student.id] ?? false;

              return StudentSelectionCard(
                student: student,
                isSelected: isSelected,
                onSelectionChanged: (selected) {
                  context.read<PrayerSurahStudentBloc>().add(
                        ToggleStudentSelection(student.id, selected),
                      );
                },
                onTap: () => loadStudentImage(student.id),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return BlocBuilder<PrayerSurahStudentBloc, PrayerSurahStudentState>(
      builder: (context, state) {
        return Column(
          children: [
            // Atama butonu
            ElevatedButton(
              onPressed: state.selectedPrayerSurahId != null &&
                      state.hasSelectedStudents()
                  ? () {
                      context.read<PrayerSurahStudentBloc>().add(
                            AssignPrayerSurahToMultipleStudents(
                              state.selectedPrayerSurahId!,
                              state.selectedStudentIds,
                            ),
                          );
                      SnackbarHelper.showSuccessSnackBar(
                        context,
                        'Sure/Dua başarıyla atandı.',
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Atama Yap'),
            ),
            const SizedBox(height: 20),
            // Tümünü seç
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tümünü Seç'),
                Checkbox(
                  value: state.selectAll,
                  activeColor: Colors.teal,
                  onChanged: (bool? value) {
                    if (value != null) {
                      context
                          .read<PrayerSurahStudentBloc>()
                          .add(SelectAllStudents(value));
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
