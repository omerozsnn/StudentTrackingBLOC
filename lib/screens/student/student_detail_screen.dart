import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/student/student_state.dart';
import 'package:ogrenci_takip_sistemi/widgets/student/student_detail_card.dart';
import 'package:ogrenci_takip_sistemi/utils/ui_helpers.dart';
import 'student_update_screen.dart';

class StudentDetailScreen extends StatefulWidget {
  final int studentId;

  const StudentDetailScreen({super.key, required this.studentId});

  @override
  _StudentDetailScreenState createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load student details when screen initializes
    _loadStudentDetails();
  }

  void _loadStudentDetails() {
    context.read<StudentBloc>().add(LoadStudentDetails(widget.studentId));
  }

  void _updateStudent(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentUpdateScreen(student: student),
      ),
    ).then((value) {
      // Refresh student details after returning from update screen
      if (value == true) {
        _loadStudentDetails();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Detayları'),
        backgroundColor: const Color(0xFF9DC88D),
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<StudentBloc, StudentState>(
        builder: (context, state) {
          if (state is StudentLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is StudentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Hata: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadStudentDetails,
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          // Get student from the state
          Student? student;

          if (state is StudentSelected) {
            student = state.selectedStudent;
          } else {
            // Try to get from bloc
            student = context.read<StudentBloc>().selectedStudent;
          }

          if (student == null) {
            return const Center(
              child: Text('Öğrenci bulunamadı'),
            );
          }

          // Calculate selected class name (this is usually stored in the bloc)
          String? className = context.read<StudentBloc>().selectedClass;

          // Show student detail card
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StudentDetailCard(
                  student: student,
                  className: className,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _updateStudent(student!),
                  icon: const Icon(Icons.edit),
                  label: const Text('Öğrenci Bilgilerini Düzenle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB5D4A7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
