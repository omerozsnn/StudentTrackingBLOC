import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../blocs/homework/homework_bloc.dart';
import '../../blocs/homework/homework_event.dart';
import '../../blocs/homework/homework_state.dart';
import '../../models/homework_model.dart';
import '../../utils/ui_helpers.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/gradient_border_container.dart';
import '../../widgets/homework/search_and_add_homework_card.dart';
import '../../widgets/homework/homework_list_view.dart';
import '../../widgets/homework/homework_stats_bar.dart';
import '../../widgets/common/loading_indicator.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({Key? key}) : super(key: key);

  @override
  _HomeworkScreenState createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _dueDateFocusNode = FocusNode();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null);
    context.read<HomeworkBloc>().add(const LoadHomeworks());
    _titleController.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _titleController.dispose();
    _dueDateController.dispose();
    _titleFocusNode.dispose();
    _dueDateFocusNode.dispose();
    super.dispose();
  }

  void _onTitleChanged() {
    setState(() {
      _searchTerm = _titleController.text;
    });
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
      _deleteHomeworkById(selectedHomework.id!);
    }
  }

  void _deleteHomeworkById(int homeworkId) {
    UIHelpers.showConfirmationDialog(
      context: context,
      title: 'Ödevi Sil',
      content: 'Bu ödevi silmek istediğinize emin misiniz?',
    ).then((confirmed) {
      if (confirmed) {
        context.read<HomeworkBloc>().add(DeleteHomework(homeworkId));
        UIHelpers.showSuccessMessage(context, 'Ödev başarıyla silindi!');
        _clearForm();
      }
    });
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
    final theme = Theme.of(context);

    return Container(
      color: AppColors.background,
      child: BlocConsumer<HomeworkBloc, HomeworkState>(
        listener: (context, state) {
          if (state.status == HomeworkStatus.error) {
            UIHelpers.showErrorMessage(
                context, state.errorMessage ?? 'Bir hata oluştu');
          }
        },
        builder: (context, state) {
          if (state.status == HomeworkStatus.loading &&
              state.homeworks.isEmpty) {
            return const LoadingIndicator();
          }

          return _buildUnifiedCard(
              state, state.homeworks, state.status == HomeworkStatus.loading);
        },
      ),
    );
  }

  Widget _buildUnifiedCard(
      HomeworkState state, List<Homework> homeworks, bool isLoading) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GradientBorderContainer(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: SearchAndAddHomeworkCard(
                titleController: _titleController,
                dueDateController: _dueDateController,
                titleFocusNode: _titleFocusNode,
                dueDateFocusNode: _dueDateFocusNode,
                isEditing: state.selectedHomework != null,
                onAdd: _saveHomework,
                onDelete: state.selectedHomework != null ? _deleteHomework : null,
                onClear: _clearForm,
              ),
            ),
            const Divider(height: 1, indent: 24, endIndent: 24),
            Expanded(
              child: isLoading && homeworks.isEmpty
                  ? const LoadingIndicator()
                  : HomeworkListView(
                      homeworks: homeworks,
                      selectedHomework: state.selectedHomework,
                      onSelect: _selectHomework,
                      onEdit: _selectHomework,
                      onDelete: (id) => _deleteHomeworkById(id),
                      searchTerm: _searchTerm,
                    ),
            ),
            HomeworkStatsBar(homeworks: homeworks),
          ],
        ),
      ),
    );
  }
}
