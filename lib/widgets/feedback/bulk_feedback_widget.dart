import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_state.dart';
import 'package:ogrenci_takip_sistemi/models/teacher_feedback_option_model.dart';

class BulkFeedbackWidget extends StatelessWidget {
  const BulkFeedbackWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherCommentBloc, TeacherCommentState>(
      buildWhen: (previous, current) {
        // Only rebuild on relevant state changes
        return current is StudentsLoadedState ||
            current is FeedbackOptionsLoadedState ||
            current is BulkFeedbackOperationState;
      },
      builder: (context, state) {
        // Extract data from various states
        final studentsState = state is StudentsLoadedState
            ? state
            : context.select<TeacherCommentBloc, StudentsLoadedState?>((bloc) {
                final currentState = bloc.state;
                if (currentState is StudentsLoadedState) {
                  return currentState;
                }
                return null;
              });

        final optionsState = state is FeedbackOptionsLoadedState
            ? state
            : context.select<TeacherCommentBloc, FeedbackOptionsLoadedState?>(
                (bloc) {
                final currentState = bloc.state;
                if (currentState is FeedbackOptionsLoadedState) {
                  return currentState;
                }
                return null;
              });

        final operationState =
            state is BulkFeedbackOperationState ? state : null;

        // If operation is in progress, show loading overlay
        if (operationState != null && operationState.isInProgress) {
          return _buildLoadingOverlay(operationState);
        }

        // If we have both students and options, show the bulk form
        if (studentsState != null && optionsState != null) {
          return _buildBulkForm(
            context,
            studentsState.selectedStudents,
            optionsState.options,
            optionsState.selectedOptionIds,
          );
        }

        // Otherwise show loading
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildBulkForm(
    BuildContext context,
    Set<dynamic> selectedStudents,
    List<TeacherFeedbackOption> options,
    Set<int> selectedOptionIds,
  ) {
    final bool noStudentsSelected = selectedStudents.isEmpty;
    final bool noOptionsSelected = selectedOptionIds.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with icon
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6C8997).withOpacity(0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(
            children: [
              const Icon(Icons.people, color: Color(0xFF6C8997)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Toplu Görüş Ekleme',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${selectedStudents.length} öğrenci seçili',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Feedback options section
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Feedback selection header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Eklenecek Görüşler',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C8997),
                      ),
                    ),
                    // Select/deselect all button
                    TextButton.icon(
                      icon: Icon(
                        selectedOptionIds.length == options.length
                            ? Icons.deselect
                            : Icons.select_all,
                        size: 20,
                      ),
                      label: Text(
                        selectedOptionIds.length == options.length
                            ? 'Tümünü Kaldır'
                            : 'Tümünü Seç',
                      ),
                      onPressed: () {
                        if (selectedOptionIds.length == options.length) {
                          context.read<TeacherCommentBloc>().add(
                              const UpdateSelectedFeedbackOptionsEvent({}));
                        } else {
                          context.read<TeacherCommentBloc>().add(
                                UpdateSelectedFeedbackOptionsEvent(
                                  options.map((option) => option.id).toSet(),
                                ),
                              );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Feedback options list
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: options.map((option) {
                      final isSelected = selectedOptionIds.contains(option.id);
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (bool? value) {
                          final Set<int> updatedSelection =
                              Set.from(selectedOptionIds);

                          if (value ?? false) {
                            updatedSelection.add(option.id);
                          } else {
                            updatedSelection.remove(option.id);
                          }

                          context.read<TeacherCommentBloc>().add(
                                UpdateSelectedFeedbackOptionsEvent(
                                    updatedSelection),
                              );
                        },
                        title: Text(option.gorusMetni),
                        activeColor: const Color(0xFF6C8997),
                        dense: true,
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit button
                ElevatedButton(
                  onPressed: (noStudentsSelected || noOptionsSelected)
                      ? null
                      : () {
                          context.read<TeacherCommentBloc>().add(
                                AddBulkFeedbackEvent(
                                  students: Set.from(selectedStudents),
                                  feedbackOptionIds: selectedOptionIds,
                                ),
                              );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C8997),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    (noStudentsSelected || noOptionsSelected)
                        ? (noStudentsSelected ? 'Öğrenci Seçin' : 'Görüş Seçin')
                        : '${selectedStudents.length} Öğrenciye ${selectedOptionIds.length} Görüş Ekle',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay(BulkFeedbackOperationState state) {
    return Stack(
      children: [
        // Semi-transparent background
        Container(
          color: Colors.black.withOpacity(0.1),
        ),

        // Loading card
        Center(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF6C8997)),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Görüşler Ekleniyor',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İşleniyor: ${state.successCount} / ${state.totalCount}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
