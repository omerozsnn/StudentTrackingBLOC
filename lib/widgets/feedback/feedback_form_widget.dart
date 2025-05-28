import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_comment/teacher_comment_state.dart';
import 'package:ogrenci_takip_sistemi/models/teacher_feedback_option_model.dart';

class FeedbackFormWidget extends StatelessWidget {
  final int? studentId;

  const FeedbackFormWidget({
    Key? key,
    this.studentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (studentId == null) {
      return Container(); // Don't show anything if no student is selected
    }

    print('Building feedback form for student ID: $studentId');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 32),
        const Text(
          'Yeni Görüş Ekle',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6C8997),
          ),
        ),
        const SizedBox(height: 16),

        // Direct options display
        _DirectFeedbackOptionsWidget(studentId: studentId!),
      ],
    );
  }
}

class _DirectFeedbackOptionsWidget extends StatefulWidget {
  final int studentId;

  const _DirectFeedbackOptionsWidget({required this.studentId});

  @override
  State<_DirectFeedbackOptionsWidget> createState() =>
      _DirectFeedbackOptionsWidgetState();
}

class _DirectFeedbackOptionsWidgetState
    extends State<_DirectFeedbackOptionsWidget> {
  final Set<int> _selectedOptionIds = {};

  @override
  Widget build(BuildContext context) {
    // Get the TeacherCommentBloc instance
    final teacherCommentBloc = BlocProvider.of<TeacherCommentBloc>(context);

    // Log the current state type
    final state = teacherCommentBloc.state;
    print('Current state in feedback form: ${state.runtimeType}');

    // Always request options if they're not already loaded
    if (state is TeacherCommentInitial || state is TeacherCommentLoading) {
      teacherCommentBloc.add(LoadFeedbackOptionsEvent());
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('Görüş seçenekleri yükleniyor...')
            ],
          ),
        ),
      );
    }

    // Get options directly from the bloc using the getter
    final options = teacherCommentBloc.feedbackOptions;

    print('Options available directly from bloc: ${options.length}');

    // If no options are available yet, trigger a load
    if (options.isEmpty) {
      teacherCommentBloc.add(LoadFeedbackOptionsEvent());
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('Görüş seçenekleri yükleniyor...')
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Options list
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, width: 1.0),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = _selectedOptionIds.contains(option.id);

              return CheckboxListTile(
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _selectedOptionIds.add(option.id);
                    } else {
                      _selectedOptionIds.remove(option.id);
                    }
                  });
                },
                title: Text(
                  option.gorusMetni,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                activeColor: const Color(0xFF6C8997),
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Add button
        ElevatedButton(
          onPressed: _selectedOptionIds.isEmpty
              ? null
              : () {
                  context.read<TeacherCommentBloc>().add(
                        AddFeedbackEvent(
                          studentId: widget.studentId,
                          feedbackOptionIds: _selectedOptionIds,
                        ),
                      );
                  // Clear selections after adding
                  setState(() {
                    _selectedOptionIds.clear();
                  });
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C8997),
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            disabledBackgroundColor: const Color(0xFF6C8997).withOpacity(0.3),
          ),
          child: Text(
            _selectedOptionIds.isEmpty
                ? 'Görüş Seçin'
                : '${_selectedOptionIds.length} Görüş Ekle',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
