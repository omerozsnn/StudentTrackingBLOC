import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_state.dart';

class ClassSelectionWidget extends StatelessWidget {
  const ClassSelectionWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherCommentBloc, TeacherCommentState>(
      buildWhen: (previous, current) {
        // Only rebuild when class-related states change
        return current is ClassesLoadedState ||
            current is StudentsLoadingState ||
            (previous is TeacherCommentInitial &&
                current is TeacherCommentLoading);
      },
      builder: (context, state) {
        // Show loading only during initial class loading
        if (state is TeacherCommentLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C8997)),
            ),
          );
        }

        // Both ClassesLoadedState and StudentsLoadingState have classes
        final List<String> classes = state is ClassesLoadedState
            ? state.classes
            : (state is StudentsLoadingState ? state.classes : []);

        final selectedClass = state is ClassesLoadedState
            ? state.selectedClass
            : (state is StudentsLoadingState ? state.selectedClass : null);

        final isLoadingStudents = state is StudentsLoadingState;

        if (classes.isEmpty) {
          return _buildEmptyState();
        }

        return _buildClassSelection(
            context, classes, selectedClass, isLoadingStudents);
      },
    );
  }

  Widget _buildClassSelection(BuildContext context, List<String> classes,
      String? selectedClass, bool isLoadingStudents) {
    // Extract multi-select mode info
    bool isMultiSelectMode = false;
    bool isSubmittingBulk = false;

    // Use select to check if we're actually loading students or if there's a different state
    bool isReallyLoadingStudents =
        context.select<TeacherCommentBloc, bool>((bloc) {
      final currentState = bloc.state;
      if (currentState is StudentsLoadingState) {
        return true;
      } else if (currentState is BulkFeedbackOperationState) {
        isSubmittingBulk = currentState.isInProgress;
      } else if (currentState is StudentsLoadedState) {
        isMultiSelectMode = currentState.isMultiSelectMode;
      }
      return false;
    });

    return Container(
      color: const Color(0xFF6C8997).withOpacity(0.1),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school, color: Color(0xFF6C8997)),
              const SizedBox(width: 8),
              const Text(
                'Sınıf Seçimi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C8997),
                ),
              ),
              const Spacer(),
              if (isMultiSelectMode && !isSubmittingBulk)
                TextButton.icon(
                  icon: const Icon(Icons.select_all),
                  label: const Text('Tümünü Seç'),
                  onPressed: () {
                    // Handle select all - implement in student list widget
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedClass,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              suffixIcon: isReallyLoadingStudents
                  ? Container(
                      padding: const EdgeInsets.only(right: 12),
                      height: 20,
                      width: 20,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF6C8997)),
                      ),
                    )
                  : null,
            ),
            items: classes.map((value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: isSubmittingBulk || isReallyLoadingStudents
                ? null
                : (newValue) {
                    if (newValue != null) {
                      context.read<TeacherCommentBloc>().add(
                            LoadStudentsByClassEvent(newValue),
                          );
                    }
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text(
          'Sınıf bulunamadı',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text(
          'Sınıflar yüklenemedi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
