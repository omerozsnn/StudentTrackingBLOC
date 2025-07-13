import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/models/teacher_feedback_option_model.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_feedback/teacher_feedback_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_feedback/teacher_feedback_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_feedback/teacher_feedback_state.dart'
    as states;
import 'package:ogrenci_takip_sistemi/widgets/feedback/teacher_feedback_input_form.dart';
import 'package:ogrenci_takip_sistemi/widgets/feedback/teacher_feedback_list_view.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/modern_app_header.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/gradient_border_container.dart';
import 'package:ogrenci_takip_sistemi/utils/ui_helpers.dart';
import 'package:ogrenci_takip_sistemi/screens/feedback/teacher_comment_screen.dart';

class TeacherFeedbackOptionScreen extends StatefulWidget {
  const TeacherFeedbackOptionScreen({super.key});

  @override
  _TeacherFeedbackOptionScreenState createState() =>
      _TeacherFeedbackOptionScreenState();
}

class _TeacherFeedbackOptionScreenState
    extends State<TeacherFeedbackOptionScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load teacher feedback options when screen initializes
    context.read<TeacherFeedbackBloc>().add(LoadTeacherFeedbackOptions());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addFeedbackOption() {
    if (_controller.text.trim().isNotEmpty) {
      context
          .read<TeacherFeedbackBloc>()
          .add(AddTeacherFeedbackOption(_controller.text.trim()));
      _controller.clear();
    } else {
      UIHelpers.showErrorMessage(context, 'Lütfen bir görüş metni girin');
    }
  }

  void _updateFeedbackOption(TeacherFeedbackOption option) {
    if (_controller.text.trim().isNotEmpty) {
      context
          .read<TeacherFeedbackBloc>()
          .add(UpdateTeacherFeedbackOption(option.id, _controller.text.trim()));
      _controller.clear();
    } else {
      UIHelpers.showErrorMessage(context, 'Lütfen bir görüş metni girin');
    }
  }

  Future<void> _deleteFeedbackOption(TeacherFeedbackOption option) async {
    final confirm = await UIHelpers.showConfirmationDialog(
        context: context,
        title: 'Görüş Sil',
        content: 'Bu görüşü silmek istediğinizden emin misiniz?');

    if (confirm && context.mounted) {
      context
          .read<TeacherFeedbackBloc>()
          .add(DeleteTeacherFeedbackOption(option.id));
      _controller.clear();
    }
  }

  void _selectFeedbackOption(TeacherFeedbackOption option) {
    context
        .read<TeacherFeedbackBloc>()
        .add(SelectTeacherFeedbackOption(option.id));
    _controller.text = option.gorusMetni;
  }

  void _clearSelection() {
    context
        .read<TeacherFeedbackBloc>()
        .add(ClearSelectedTeacherFeedbackOption());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeacherFeedbackBloc, states.TeacherFeedbackState>(
      listener: (context, state) {
        if (state is states.TeacherFeedbackOperationSuccess) {
          UIHelpers.showSuccessMessage(context, state.message);
        } else if (state is states.TeacherFeedbackError) {
          UIHelpers.showErrorMessage(context, state.message);
        }
      },
      builder: (context, state) {
        final hasSelection = state is states.TeacherFeedbackOptionsLoaded &&
            state.selectedOption != null;

        final options = state is states.TeacherFeedbackOptionsLoaded
            ? state.options
            : <TeacherFeedbackOption>[];

        final selectedOption =
            state is states.TeacherFeedbackOptionsLoaded
                ? state.selectedOption
                : null;

        final isLoading = state is states.TeacherFeedbackLoading;

        return Material(
          color: Theme.of(context).colorScheme.background,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: _buildUnifiedCard(
                      state, options, selectedOption, hasSelection, isLoading),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnifiedCard(
    states.TeacherFeedbackState state, 
    List<TeacherFeedbackOption> options, 
    TeacherFeedbackOption? selectedOption, 
    bool hasSelection, 
    bool isLoading
  ) {
    return GradientBorderContainer(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            children: [
              // Input form section
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: TeacherFeedbackInputForm(
                  controller: _controller,
                  hasSelection: hasSelection,
                  onAdd: _addFeedbackOption,
                  onUpdate: () {
                    if (hasSelection) {
                      final selected = (state as states.TeacherFeedbackOptionsLoaded).selectedOption!;
                      _updateFeedbackOption(selected);
                    }
                  },
                  onDelete: hasSelection ? () {
                    final selected = (state as states.TeacherFeedbackOptionsLoaded).selectedOption!;
                    _deleteFeedbackOption(selected);
                  } : null,
                  onClear: hasSelection ? _clearSelection : null,
                ),
              ),
              
              const Divider(height: 1, indent: 24, endIndent: 24),
              
              // Feedback list section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: TeacherFeedbackListView(
                    options: options,
                    selectedOption: selectedOption,
                    onOptionTap: _selectFeedbackOption,
                    isLoading: isLoading,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
