import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_state.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';
import 'package:ogrenci_takip_sistemi/widgets/feedback/feedback_form_widget.dart';
import 'package:ogrenci_takip_sistemi/widgets/feedback/feedback_list_widget.dart';

class StudentDetailWidget extends StatelessWidget {
  const StudentDetailWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherCommentBloc, TeacherCommentState>(
      buildWhen: (previous, current) {
        // Rebuild for any state change to ensure we always catch student selection
        // This might be less efficient but will ensure the UI updates correctly
        print(
            'Previous state: ${previous.runtimeType}, Current state: ${current.runtimeType}');
        return true;
      },
      builder: (context, state) {
        // Get the selected student
        final selectedStudent =
            context.select<TeacherCommentBloc, Student?>((bloc) {
          final currentState = bloc.state;
          if (currentState is StudentsLoadedState) {
            print(
                'Found selected student: ${currentState.selectedStudent?.adSoyad}');
            return currentState.selectedStudent;
          }
          return null;
        });

        // If no student is selected, show a placeholder
        if (selectedStudent == null) {
          print('No student selected, showing placeholder');
          return _buildNoStudentSelected();
        }

        // Otherwise, show student details with feedback
        print('Building details for student: ${selectedStudent.adSoyad}');
        return _buildStudentDetail(context, selectedStudent);
      },
    );
  }

  Widget _buildNoStudentSelected() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 64,
            color: const Color(0xFF6C8997).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Görüşleri görüntülemek için\nbir öğrenci seçin',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6C8997),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentDetail(BuildContext context, Student student) {
    final selectedClass = context.select<TeacherCommentBloc, String?>((bloc) {
          final currentState = bloc.state;
          if (currentState is StudentsLoadedState) {
            return currentState.selectedClass;
          }
          return null;
        }) ??
        '';

    // Print debug info with clearer message
    print(
        'Building detail view for student: ${student.id} - ${student.adSoyad}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Student header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6C8997).withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFF6C8997),
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.adSoyad,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      selectedClass,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Feedback content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Existing feedback section
                const Text(
                  'Görüşler',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C8997),
                  ),
                ),
                const SizedBox(height: 16),
                const FeedbackListWidget(),

                // Add new feedback section - use the FeedbackFormWidget
                FeedbackFormWidget(studentId: student.id),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
