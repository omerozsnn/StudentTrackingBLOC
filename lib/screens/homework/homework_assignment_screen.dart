import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../blocs/homework/homework_bloc.dart';
import '../../blocs/homework/homework_event.dart';
import '../../blocs/homework/homework_state.dart';
import '../../blocs/class/class_bloc.dart';
import '../../blocs/class/class_event.dart';
import '../../blocs/class/class_state.dart';
import '../../blocs/student/student_bloc.dart';
import '../../blocs/student/student_event.dart';
import '../../blocs/student/student_state.dart';
import '../../blocs/student_homework/student_homework_bloc.dart';
import '../../blocs/student_homework/student_homework_event.dart';
import '../../blocs/student_homework/student_homework_state.dart';
import '../../models/homework_model.dart';
import '../../models/classes_model.dart';
import '../../models/student_homework_model.dart';
import '../../utils/ui_helpers.dart';
import '../../widgets/homework/homework_selector.dart';
import '../../widgets/homework/class_selector.dart';
import '../../widgets/homework/student_selector.dart';
import '../homework/homework_screen.dart';

class HomeworkAssignmentScreen extends StatefulWidget {
  const HomeworkAssignmentScreen({Key? key}) : super(key: key);

  @override
  State<HomeworkAssignmentScreen> createState() =>
      _HomeworkAssignmentScreenState();
}

class _HomeworkAssignmentScreenState extends State<HomeworkAssignmentScreen> {
  Homework? _selectedHomework;
  Classes? _selectedClass;
  List<int> _selectedStudentIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null);
    context.read<HomeworkBloc>().add(const LoadHomeworks());
    context.read<ClassBloc>().add(LoadClasses());
  }

  void _handleClassSelected(Classes? classItem) {
    setState(() {
      _selectedClass = classItem;
      _selectedStudentIds = [];
    });

    if (classItem != null) {
      context.read<StudentBloc>().add(LoadStudentsByClass(classItem.sinifAdi));
    }
  }

  void _handleHomeworkSelected(Homework? homework) {
    setState(() => _selectedHomework = homework);
  }

  void _handleStudentSelectionChanged(List<int> studentIds) {
    setState(() => _selectedStudentIds = studentIds);
  }

  Future<void> _assignHomework() async {
    if (_selectedHomework == null) {
      UIHelpers.showErrorMessage(context, 'Lütfen bir ödev seçin');
      return;
    }

    if (_selectedStudentIds.isEmpty) {
      UIHelpers.showErrorMessage(context, 'Lütfen en az bir öğrenci seçin');
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<StudentHomework> homeworkAssignments =
          _selectedStudentIds.map((studentId) {
        return StudentHomework(
          ogrenciId: studentId,
          odevId: _selectedHomework!.id!,
        );
      }).toList();

      context
          .read<StudentHomeworkBloc>()
          .add(AddBulkStudentHomeworks(homeworkAssignments));
      UIHelpers.showSuccessMessage(
        context,
        'Ödev başarıyla ${_selectedStudentIds.length} öğrenciye atandı!',
      );

      setState(() => _selectedStudentIds = []);
    } catch (e) {
      UIHelpers.showErrorMessage(
        context,
        'Ödev atama sırasında bir hata oluştu: ${e.toString()}',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ödev Atama'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Ödev Ekle',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeworkScreen()),
              ).then((_) =>
                  context.read<HomeworkBloc>().add(const LoadHomeworks()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocListener<StudentHomeworkBloc, StudentHomeworkState>(
        listener: (context, state) {
          if (state.status == StudentHomeworkStatus.error) {
            UIHelpers.showErrorMessage(
                context, state.errorMessage ?? 'Bir hata oluştu');
          }
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BlocBuilder<HomeworkBloc, HomeworkState>(
                        builder: (context, state) {
                          return state.status == HomeworkStatus.loading
                              ? const Center(child: CircularProgressIndicator())
                              : HomeworkSelector(
                                  homeworks: state.homeworks,
                                  selectedHomework: _selectedHomework,
                                  onHomeworkSelected: _handleHomeworkSelected,
                                );
                        },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<ClassBloc, ClassState>(
                        builder: (context, state) {
                          return state is ClassLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ClassSelector(
                                  classes: state.classes,
                                  selectedClass: _selectedClass,
                                  onClassSelected: _handleClassSelected,
                                );
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_selectedClass != null)
                        BlocBuilder<StudentBloc, StudentState>(
                          builder: (context, state) {
                            if (state is StudentLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (state is StudentsLoaded) {
                              return SizedBox(
                                height: 400,
                                child: StudentSelector(
                                  students: state.students,
                                  selectedStudentIds: _selectedStudentIds,
                                  onSelectionChanged:
                                      _handleStudentSelectionChanged,
                                ),
                              );
                            }
                            return const Center(
                                child: Text(
                                    'Öğrenci yüklenirken bir sorun oluştu'));
                          },
                        ),
                      const SizedBox(height: 20),
                      if (_selectedClass != null)
                        Center(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.assignment_turned_in),
                            label: Text(
                              'Ödevi ${_selectedStudentIds.length} Öğrenciye Ata',
                              style: const TextStyle(fontSize: 16),
                            ),
                            onPressed: _selectedStudentIds.isNotEmpty
                                ? _assignHomework
                                : null,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
