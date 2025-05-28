import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/models/teacher_feedback_option_model.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_feedback/teacher_feedback_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_feedback/teacher_feedback_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/teacher_feedback/teacher_feedback_state.dart'
    as states;
import 'package:ogrenci_takip_sistemi/widgets/feedback/teacher_feedback_option_item.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğretmen Görüşü Ekleme'),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_ind),
            tooltip: 'Görüş Atama',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TeacherCommentPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<TeacherFeedbackBloc, states.TeacherFeedbackState>(
        listener: (context, state) {
          if (state is states.TeacherFeedbackOperationSuccess) {
            UIHelpers.showSuccessMessage(context, state.message);
          } else if (state is states.TeacherFeedbackError) {
            UIHelpers.showErrorMessage(context, state.message);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Feedback input field
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Öğretmen Görüşü',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),

                // Action buttons
                _buildActionButtons(state),

                const SizedBox(height: 20),

                // Feedback options list
                _buildFeedbackList(state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(states.TeacherFeedbackState state) {
    final bool hasSelection = state is states.TeacherFeedbackOptionsLoaded &&
        state.selectedOption != null;

    return Row(
      children: [
        // Add or Update button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              if (hasSelection) {
                final selectedOption =
                    (state as states.TeacherFeedbackOptionsLoaded)
                        .selectedOption!;
                _updateFeedbackOption(selectedOption);
              } else {
                _addFeedbackOption();
              }
            },
            icon: Icon(hasSelection ? Icons.update : Icons.add),
            label: Text(hasSelection ? 'Güncelle' : 'Ekle'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  hasSelection ? Colors.orange : Colors.deepPurpleAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // Show Delete button if an option is selected
        if (hasSelection) ...[
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                final selectedOption =
                    (state as states.TeacherFeedbackOptionsLoaded)
                        .selectedOption!;
                _deleteFeedbackOption(selectedOption);
              },
              icon: const Icon(Icons.delete),
              label: const Text('Sil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Clear selection button
          IconButton(
            onPressed: _clearSelection,
            icon: const Icon(Icons.clear),
            tooltip: 'Seçimi temizle',
          ),
        ],
      ],
    );
  }

  Widget _buildFeedbackList(states.TeacherFeedbackState state) {
    if (state is states.TeacherFeedbackLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is states.TeacherFeedbackOptionsLoaded) {
      final options = state.options;
      final selectedOption = state.selectedOption;

      if (options.isEmpty) {
        return const Expanded(
          child: Center(
            child: Text('Henüz hiç görüş eklenmemiş',
                style: TextStyle(fontSize: 16)),
          ),
        );
      }

      return Expanded(
        child: ListView.builder(
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected =
                selectedOption != null && option.id == selectedOption.id;

            return TeacherFeedbackOptionItem(
              option: option,
              isSelected: isSelected,
              onTap: () => _selectFeedbackOption(option),
            );
          },
        ),
      );
    }

    // Default view for other states
    return const Expanded(
      child: Center(
        child: Text('Görüşler yüklenemedi', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
