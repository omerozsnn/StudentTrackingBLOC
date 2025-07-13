import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/course/course_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/course/course_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/course/course_state.dart';
import 'package:ogrenci_takip_sistemi/blocs/course_class/course_class_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/course_class/course_class_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/course_class/course_class_state.dart';
import 'package:ogrenci_takip_sistemi/models/courses_model.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';
import 'package:ogrenci_takip_sistemi/models/course_classes_model.dart';
import 'package:ogrenci_takip_sistemi/utils/ui_helpers.dart';
import 'package:ogrenci_takip_sistemi/core/theme/app_colors.dart';
import 'package:ogrenci_takip_sistemi/api.dart/classApi.dart' as classApi;
import 'package:ogrenci_takip_sistemi/widgets/course/course_assignment_panel.dart';
import 'package:ogrenci_takip_sistemi/widgets/course/class_assignment_panel.dart';

class CourseClassAssignPage extends StatefulWidget {
  const CourseClassAssignPage({super.key});

  @override
  _CourseClassAssignPageState createState() => _CourseClassAssignPageState();
}

class _CourseClassAssignPageState extends State<CourseClassAssignPage> {
  // API services
  final classApi.ApiService classApiService =
      classApi.ApiService(baseUrl: 'http://localhost:3000');

  // State variables
  List<Classes> classes = [];
  Course? selectedCourse;
  Set<int> selectedClassIds = {};
  String searchQuery = '';
  bool selectAll = false;
  bool isLoading = true;
  List<CourseClass> courseClasses = [];

  // Controllers
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadClasses();
    // Load courses through BLoC
    context.read<CourseBloc>().add(LoadCoursesForDropdown());
    // Load course classes to get assignment counts
    context.read<CourseClassBloc>().add(LoadCourseClasses());
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadClasses() async {
    try {
      final data = await classApiService.getClassesForDropdown();
      if (mounted) {
        setState(() {
          classes = data.map<Classes>((classItem) => classItem).toList();
        });
      }
    } catch (error) {
      if (mounted) {
        UIHelpers.showErrorMessage(context, 'Sınıflar yüklenemedi: $error');
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = searchController.text;
    });
  }

  void _onCourseSelected(Course course) {
    setState(() {
      selectedCourse = course;
      selectedClassIds.clear();
      selectAll = false;
    });
  }

  void _onClassSelectionChanged(int classId, bool isSelected) {
    setState(() {
      if (isSelected) {
        selectedClassIds.add(classId);
      } else {
        selectedClassIds.remove(classId);
      }
      selectAll = selectedClassIds.length == classes.length;
    });
  }

  void _onSelectAllChanged(bool? value) {
    setState(() {
      selectAll = value ?? false;
      if (selectAll) {
        selectedClassIds = classes.map((c) => c.id).toSet();
      } else {
        selectedClassIds.clear();
      }
    });
  }

  void _clearSelections() {
    setState(() {
      selectedCourse = null;
      selectedClassIds.clear();
      selectAll = false;
      searchQuery = '';
      searchController.clear();
    });
  }

  int _getAssignmentCount(int courseId) {
    return courseClasses.where((cc) => cc.dersId == courseId).length;
  }

  Future<void> _assignCourseToClasses() async {
    if (selectedCourse == null || selectedClassIds.isEmpty) {
      UIHelpers.showErrorMessage(context, 'Lütfen bir ders ve en az bir sınıf seçin.');
      return;
    }

    UIHelpers.showLoadingDialog(context, 'Ders sınıflara atanıyor...');

    try {
      int successCount = 0;
      int totalCount = selectedClassIds.length;

      for (int classId in selectedClassIds) {
        final newCourseClass = CourseClass(
          id: 0, // auto incremented by the database
          sinifId: classId,
          dersId: selectedCourse!.id,
        );

        context.read<CourseClassBloc>().add(AddCourseClass(newCourseClass));
        successCount++;
      }

      if (mounted) {
        UIHelpers.hideLoadingDialog(context);
        UIHelpers.showSuccessDialog(
          context: context,
          title: 'Başarılı',
          message: '${selectedCourse!.dersAdi} dersi $successCount sınıfa başarıyla atandı.',
          onConfirm: () {
            _clearSelections();
          },
        );
      }
    } catch (error) {
      if (mounted) {
        UIHelpers.hideLoadingDialog(context);
        UIHelpers.showErrorMessage(context, 'Ders atama işlemi başarısız oldu: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : BlocListener<CourseClassBloc, CourseClassState>(
              listener: (context, state) {
                if (state is CourseClassOperationSuccess) {
                  // Handle success in the assignment method
                  // Reload course classes to update assignment counts
                  context.read<CourseClassBloc>().add(LoadCourseClasses());
                } else if (state is CourseClassError) {
                  UIHelpers.showErrorMessage(context, state.message);
                } else if (state is CourseClassesLoaded) {
                  // Update courseClasses list when data is loaded
                  setState(() {
                    courseClasses = state.courseClasses;
                  });
                }
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 800;
                  
                  if (isWideScreen) {
                    return _buildWideScreenLayout();
                  } else {
                    return _buildNarrowScreenLayout();
                  }
                },
              ),
            ),
    );
  }

  Widget _buildWideScreenLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 1, child: _buildCoursePanel()),
                const SizedBox(width: 16),
                Expanded(flex: 1, child: _buildClassPanel()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildNarrowScreenLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: _buildCoursePanel(),
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 1,
            child: _buildClassPanel(),
          ),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildCoursePanel() {
    return CourseAssignmentPanel(
      searchController: searchController,
      searchQuery: searchQuery,
      selectedCourse: selectedCourse,
      onCourseSelected: _onCourseSelected,
      getAssignmentCount: _getAssignmentCount,
    );
  }

  Widget _buildClassPanel() {
    return ClassAssignmentPanel(
      selectedCourse: selectedCourse,
      classes: classes,
      selectedClassIds: selectedClassIds,
      selectAll: selectAll,
      onSelectAllChanged: _onSelectAllChanged,
      onClassSelectionChanged: _onClassSelectionChanged,
    );
  }

  Widget _buildActionButtons() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.assignment_turned_in, color: colorScheme.onPrimary),
            label: Text(
              selectedClassIds.isEmpty 
                  ? 'Sınıf Seçin'
                  : 'Seçili Sınıflara Ata (${selectedClassIds.length})',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedCourse != null && selectedClassIds.isNotEmpty
                  ? colorScheme.secondary
                  : colorScheme.onSurface.withOpacity(0.3),
              disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 5,
            ),
            onPressed: selectedCourse != null && selectedClassIds.isNotEmpty
                ? _assignCourseToClasses
                : null,
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          icon: Icon(Icons.clear, color: colorScheme.onError),
          label: Text(
            'Temizle',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onError,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.error,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
          ),
          onPressed: _clearSelections,
        ),
      ],
    );
  }
} 