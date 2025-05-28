import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_state.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';

class StudentListWidget extends StatelessWidget {
  const StudentListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherCommentBloc, TeacherCommentState>(
      buildWhen: (previous, current) {
        // Only rebuild on student-related state changes
        return current is StudentsLoadedState ||
            current is StudentsLoadingState ||
            current is BulkFeedbackOperationState;
      },
      builder: (context, state) {
        // Handle student loading state separately
        if (state is StudentsLoadingState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C8997)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Öğrenciler yükleniyor...',
                  style: TextStyle(
                    color: const Color(0xFF6C8997),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is StudentsLoadedState) {
          if (state.students.isEmpty) {
            return _buildEmptyState();
          }

          return _buildStudentList(context, state);
        }

        if (state is BulkFeedbackOperationState && state.isInProgress) {
          return _buildLoadingOverlay(context);
        }

        return _buildErrorState();
      },
    );
  }

  Widget _buildStudentList(BuildContext context, StudentsLoadedState state) {
    return ListView.builder(
      itemCount: state.students.length,
      itemBuilder: (context, index) {
        final student = state.students[index];
        final isSelected = state.isMultiSelectMode
            ? state.selectedStudents.contains(student)
            : state.selectedStudent?.id == student.id;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isSelected
                ? const Color(0xFF6C8997)
                : const Color(0xFF6C8997).withOpacity(0.1),
            child: Icon(
              Icons.person,
              color: isSelected ? Colors.white : const Color(0xFF6C8997),
            ),
          ),
          title: Text(
            '${student.ogrenciNo} - ${student.adSoyad}',
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          trailing: state.isMultiSelectMode
              ? Checkbox(
                  value: isSelected,
                  activeColor: const Color(0xFF6C8997),
                  onChanged: (bool? value) {
                    _handleStudentSelection(
                        context, student, value ?? false, state);
                  },
                )
              : null,
          selected: isSelected,
          selectedTileColor: const Color(0xFF6C8997).withOpacity(0.1),
          onTap: () {
            if (state.isMultiSelectMode) {
              _handleStudentSelection(context, student,
                  !state.selectedStudents.contains(student), state);
            } else {
              // Don't show loading when selecting students
              print(
                  'Selecting student: ${student.adSoyad} (ID: ${student.id})');

              // First ensure we have fresh feedback options
              context
                  .read<TeacherCommentBloc>()
                  .add(LoadFeedbackOptionsEvent());

              // Then select the student
              context
                  .read<TeacherCommentBloc>()
                  .add(SelectStudentEvent(student));
            }
          },
        );
      },
    );
  }

  void _handleStudentSelection(
    BuildContext context,
    Student student,
    bool isSelected,
    StudentsLoadedState state,
  ) {
    final Set<Student> updatedSelection = Set.from(state.selectedStudents);

    if (isSelected) {
      updatedSelection.add(student);
    } else {
      updatedSelection.remove(student);
    }

    context.read<TeacherCommentBloc>().add(
          UpdateSelectedStudentsEvent(updatedSelection),
        );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 64,
            color: const Color(0xFF6C8997).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bu sınıfta öğrenci bulunamadı',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          const Text(
            'Öğrenciler yüklenemedi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay(BuildContext context) {
    // Extract bulk operation state
    final bulkState =
        context.select<TeacherCommentBloc, BulkFeedbackOperationState?>((bloc) {
      final state = bloc.state;
      if (state is BulkFeedbackOperationState) {
        return state;
      }
      return null;
    });

    if (bulkState == null) {
      return Container();
    }

    return Container(
      color: Colors.black.withOpacity(0.1),
      child: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C8997)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'İşlem yapılıyor',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'İşleniyor: ${bulkState.successCount} / ${bulkState.totalCount}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
