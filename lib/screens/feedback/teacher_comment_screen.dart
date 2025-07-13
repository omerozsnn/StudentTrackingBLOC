import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/api.dart/teacherFeedbackApi.dart'
    as feedback_api;
import 'package:ogrenci_takip_sistemi/api.dart/classApi.dart' as class_api;
import 'package:ogrenci_takip_sistemi/api.dart/studentControlApi.dart'
    as student_api;
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_repository.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_state.dart';
import 'package:ogrenci_takip_sistemi/screens/feedback/teacher_feedback_option_screen.dart';
import 'package:ogrenci_takip_sistemi/utils/snackbar_helper.dart';
import 'package:ogrenci_takip_sistemi/widgets/feedback/class_selection_widget.dart';
import 'package:ogrenci_takip_sistemi/widgets/feedback/student_list_widget.dart';
import 'package:ogrenci_takip_sistemi/widgets/feedback/student_detail_widget.dart';
import 'package:ogrenci_takip_sistemi/widgets/feedback/bulk_feedback_widget.dart';
import 'package:ogrenci_takip_sistemi/widgets/feedback/feedback_card_widget.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/modern_app_header.dart';

// For backward compatibility - exports TeacherCommentScreen as TeacherCommentPage
export 'package:ogrenci_takip_sistemi/widgets/feedback/feedback_card_widget.dart';

// Backward compatibility classes
class TeacherCommentPage extends StatelessWidget {
  const TeacherCommentPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const TeacherCommentScreen();
  }
}

// Legacy FeedbackCard wrapper for backward compatibility
class FeedbackCard extends StatelessWidget {
  final Map<String, dynamic> feedback;
  final VoidCallback onDelete;

  const FeedbackCard({
    Key? key,
    required this.feedback,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if we're in a BLoC context
    final hasBloc = context.findAncestorWidgetOfExactType<
            BlocProvider<TeacherCommentBloc>>() !=
        null;

    if (hasBloc) {
      // If we're in the new architecture, use the BLoC implementation
      return FeedbackCardWidget(feedback: feedback);
    } else {
      // Otherwise, use the legacy implementation with the provided onDelete callback
      return _buildLegacyFeedbackCard();
    }
  }

  // Legacy implementation for backward compatibility
  Widget _buildLegacyFeedbackCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: const Color(0xFF6C8997).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.comment,
              color: Color(0xFF6C8997),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feedback['gorus_metni'] ?? 'Görüş bulunamadı',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  if (feedback['ek_gorus'] != null &&
                      feedback['ek_gorus'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Ek Görüş: ${feedback['ek_gorus']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      _formatDate(feedback['tarih']),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}

class TeacherCommentScreen extends StatelessWidget {
  const TeacherCommentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final feedbackApiService =
            feedback_api.ApiService(baseUrl: 'http://localhost:3000');
        final classApiService =
            class_api.ApiService(baseUrl: 'http://localhost:3000');
        final studentApiService =
            student_api.StudentApiService(baseUrl: 'http://localhost:3000');

        final repository = TeacherCommentRepository(
          feedbackApiService: feedbackApiService,
          classApiService: classApiService,
          studentApiService: studentApiService,
        );

        final bloc = TeacherCommentBloc(repository: repository)
          ..add(LoadClassesEvent());

        return bloc;
      },
      child: _TeacherCommentScreenContent(),
    );
  }
}

class _TeacherCommentScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<TeacherCommentBloc, TeacherCommentState>(
      listener: (context, state) {
        if (state is TeacherCommentOperationSuccess) {
          SnackbarHelper.showSuccessSnackBar(context, state.message);
        } else if (state is TeacherCommentError) {
          SnackbarHelper.showErrorSnackBar(context, state.message);
        }
      },
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    // Determine if we're in multi-select mode
    final isMultiSelectMode = context.select<TeacherCommentBloc, bool>((bloc) {
      final state = bloc.state;
      if (state is StudentsLoadedState) {
        return state.isMultiSelectMode;
      }
      return false;
    });

    return Material(
      color: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isMultiSelectMode)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people,
                            size: 16, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 4),
                        Text(
                          'Toplu Atama Modu',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                ModernActionButton(
                  label:
                      isMultiSelectMode ? 'İptal' : 'Toplu Atama',
                  icon: isMultiSelectMode ? Icons.close : Icons.people_outline,
                  onPressed: () {
                    context.read<TeacherCommentBloc>().add(
                          ToggleMultiSelectModeEvent(!isMultiSelectMode),
                        );
                  },
                  isOutlined: !isMultiSelectMode,
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // Left panel - Class and student list
                Expanded(
                  flex: 2,
                  child: Card(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const ClassSelectionWidget(),
                        Expanded(
                          child: StudentListWidget(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right panel - Either student details or bulk feedback form
                Expanded(
                  flex: 3,
                  child: Card(
                    margin: const EdgeInsets.fromLTRB(0, 8, 16, 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: isMultiSelectMode
                        ? BulkFeedbackWidget() // Show bulk mode
                        : StudentDetailWidget(), // Show student details
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
