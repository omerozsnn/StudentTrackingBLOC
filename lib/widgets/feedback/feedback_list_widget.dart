import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_state.dart';
import 'package:ogrenci_takip_sistemi/widgets/feedback/feedback_card_widget.dart';

class FeedbackListWidget extends StatelessWidget {
  const FeedbackListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherCommentBloc, TeacherCommentState>(
      buildWhen: (previous, current) {
        // Rebuild for loading, feedback loaded, or error states
        return current is StudentFeedbackLoadedState ||
            current is TeacherCommentLoading ||
            current is TeacherCommentError;
      },
      builder: (context, state) {
        // If we have loaded feedback (empty or not)
        if (state is StudentFeedbackLoadedState) {
          if (state.feedbackList.isEmpty) {
            return _buildEmptyState();
          }
          return _buildFeedbackList(state.feedbackList);
        }

        // While loading, check if we already know this student has no feedback
        // This helps prevent the loading indicator from flashing when selecting a student
        if (state is TeacherCommentLoading) {
          // Try to get the current selected student from context
          final selectedStudent =
              context.select<TeacherCommentBloc, int?>((bloc) {
            final currentState = bloc.state;
            if (currentState is StudentsLoadedState &&
                currentState.selectedStudent != null) {
              return currentState.selectedStudent!.id;
            }
            return null;
          });

          // If we have a known empty feedback state, show it right away
          final hasKnownEmptyFeedback =
              context.select<TeacherCommentBloc, bool>((bloc) {
            final feedbackState = bloc.state;
            if (feedbackState is StudentFeedbackLoadedState &&
                selectedStudent != null &&
                feedbackState.studentId == selectedStudent &&
                feedbackState.feedbackList.isEmpty) {
              return true;
            }
            return false;
          });

          if (hasKnownEmptyFeedback) {
            return _buildEmptyState();
          }

          // If we don't know yet, show a short loading
          return _buildShortLoading();
        }

        // If there was an error
        if (state is TeacherCommentError) {
          return SizedBox(
            height: 150,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 40),
                  SizedBox(height: 8),
                  Text(
                    'Görüşler yüklenemedi',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        }

        // Default placeholder state - immediately show empty state
        return _buildEmptyState();
      },
    );
  }

  Widget _buildShortLoading() {
    return FutureBuilder(
        // Use a very short future to avoid flickering
        future: Future.delayed(const Duration(milliseconds: 100)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _buildEmptyState();
          }

          return SizedBox(
            height: 150,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C8997)),
              ),
            ),
          );
        });
  }

  Widget _buildFeedbackList(List<Map<String, dynamic>> feedbackList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var feedback in feedbackList)
          FeedbackCardWidget(feedback: feedback),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.comment_bank_outlined,
              size: 48,
              color: const Color(0xFF6C8997).withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Henüz görüş eklenmemiş',
              style: TextStyle(
                color: Color(0xFF6C8997),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
