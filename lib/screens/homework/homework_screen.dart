import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../blocs/homework/homework_bloc.dart';
import '../../blocs/homework/homework_event.dart';
import '../../blocs/homework/homework_state.dart';
import '../../models/homework_model.dart';
import '../../blocs/homework/homework_repository.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/homework/homework_form.dart';
import '../../widgets/homework/homework_list_item.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({Key? key}) : super(key: key);

  @override
  _HomeworkScreenState createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null);
    context.read<HomeworkBloc>().add(const LoadHomeworks());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _titleController.clear();
    _dueDateController.clear();
    context.read<HomeworkBloc>().add(const ClearSelection());
  }

  void _saveHomework() {
    if (_titleController.text.isEmpty || _dueDateController.text.isEmpty) {
      UIHelpers.showErrorMessage(
          context, 'Ödev adı ve teslim tarihi boş olamaz.');
      return;
    }

    final homework = Homework(
      id: context.read<HomeworkBloc>().state.selectedHomework?.id,
      odevAdi: _titleController.text,
      teslimTarihi: DateFormat('yyyy-MM-dd').parse(_dueDateController.text),
    );

    if (homework.id != null) {
      context.read<HomeworkBloc>().add(UpdateHomework(homework));
      UIHelpers.showSuccessMessage(context, 'Ödev başarıyla güncellendi!');
    } else {
      context.read<HomeworkBloc>().add(AddHomework(homework));
      UIHelpers.showSuccessMessage(context, 'Ödev başarıyla eklendi!');
    }
  }

  void _deleteHomework() {
    final selectedHomework =
        context.read<HomeworkBloc>().state.selectedHomework;
    if (selectedHomework != null && selectedHomework.id != null) {
      UIHelpers.showConfirmationDialog(
        context: context,
        title: 'Ödevi Sil',
        content: 'Bu ödevi silmek istediğinize emin misiniz?',
      ).then((confirmed) {
        if (confirmed) {
          context
              .read<HomeworkBloc>()
              .add(DeleteHomework(selectedHomework.id!));
          UIHelpers.showSuccessMessage(context, 'Ödev başarıyla silindi!');
          _clearForm();
        }
      });
    }
  }

  void _selectHomework(Homework homework) {
    if (context.read<HomeworkBloc>().state.selectedHomework?.id ==
        homework.id) {
      _clearForm();
    } else {
      _titleController.text = homework.odevAdi;
      _dueDateController.text =
          DateFormat('yyyy-MM-dd').format(homework.teslimTarihi);
      context.read<HomeworkBloc>().add(SelectHomework(homework));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödev Yönetimi'),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<HomeworkBloc, HomeworkState>(
        listener: (context, state) {
          if (state.status == HomeworkStatus.error) {
            UIHelpers.showErrorMessage(
                context, state.errorMessage ?? 'Bir hata oluştu');
          }
        },
        builder: (context, state) {
          if (state.status == HomeworkStatus.loading &&
              state.homeworks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeworkForm(
                  titleController: _titleController,
                  dueDateController: _dueDateController,
                  onSave: _saveHomework,
                  onDelete:
                      state.selectedHomework != null ? _deleteHomework : null,
                  isEditing: state.selectedHomework != null,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: state.homeworks.isEmpty
                      ? const Center(
                          child: Text(
                            'Henüz hiç ödev eklenmemiş',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.homeworks.length,
                          itemBuilder: (context, index) {
                            final homework = state.homeworks[index];
                            final isSelected =
                                state.selectedHomework?.id == homework.id;

                            return HomeworkListItem(
                              homework: homework,
                              isSelected: isSelected,
                              onTap: _selectHomework,
                            );
                          },
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
