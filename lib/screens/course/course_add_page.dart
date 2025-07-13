import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/course/course_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/course/course_event.dart';
import 'package:ogrenci_takip_sistemi/blocs/course/course_state.dart';
import 'package:ogrenci_takip_sistemi/models/courses_model.dart';
import 'package:ogrenci_takip_sistemi/screens/course/course_class_assign_page.dart';
import 'package:ogrenci_takip_sistemi/utils/ui_helpers.dart';
import 'package:ogrenci_takip_sistemi/core/theme/app_colors.dart';
import 'package:ogrenci_takip_sistemi/widgets/course/course_list_view.dart';
import 'package:ogrenci_takip_sistemi/widgets/course/course_stats_bar.dart';
import 'package:ogrenci_takip_sistemi/widgets/course/search_and_add_course_card.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/loading_indicator.dart';

class CourseAddPage extends StatefulWidget {
  const CourseAddPage({super.key});

  @override
  _CourseAddPageState createState() => _CourseAddPageState();
}

class _CourseAddPageState extends State<CourseAddPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _searchTerm;

  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(LoadCourses());
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (context.read<CourseBloc>().state.selectedCourse == null) {
      setState(() {
        _searchTerm = _controller.text;
      });
    }
  }
  
  void _onSelectCourse(Course course) {
    final courseBloc = context.read<CourseBloc>();
    if (courseBloc.state.selectedCourse?.id == course.id) {
      // Deselecting
      courseBloc.add(const SelectCourse(null));
      _controller.clear();
    } else {
      // Selecting for edit
      _controller.removeListener(_onSearchChanged);
      courseBloc.add(SelectCourse(course));
      _controller.text = course.dersAdi;
      setState(() {
        _searchTerm = null;
      });
      _controller.addListener(_onSearchChanged);
    }
  }

  void _onEditCourse(Course course) {
    _onSelectCourse(course);
    _focusNode.requestFocus();
  }

  void _addOrUpdateCourse() {
    final courseBloc = context.read<CourseBloc>();
    final selectedCourse = courseBloc.state.selectedCourse;

    if (_controller.text.isNotEmpty) {
      if (selectedCourse == null) {
        // Add new course
        final newCourse = Course(id: 0, dersAdi: _controller.text);
        courseBloc.add(AddCourse(newCourse));
      } else {
        // Update existing course
        final updatedCourse = selectedCourse.copyWith(dersAdi: _controller.text);
        courseBloc.add(UpdateCourse(updatedCourse));
      }
      _controller.clear();
      _focusNode.unfocus();
      courseBloc.add(const SelectCourse(null));

    } else {
      UIHelpers.showErrorMessage(context, 'Ders adı zorunludur!');
    }
  }

  Future<void> _removeCourse(int courseId) async {
    final confirm = await UIHelpers.showConfirmationDialog(
      context: context,
      title: 'Emin misiniz?',
      content: 'Bu dersi silmek istediğinizden emin misiniz?',
    );

    if (confirm) {
      context.read<CourseBloc>().add(DeleteCourse(courseId));
      _controller.clear();
      context.read<CourseBloc>().add(const SelectCourse(null));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CourseBloc, CourseState>(
      listener: (context, state) {
        if (state is CourseOperationSuccess) {
          UIHelpers.showSuccessMessage(context, state.message);
        } else if (state is CourseError) {
          UIHelpers.showErrorMessage(context, state.message);
        }
      },
      builder: (context, state) {
        final courses = state.courses;
        final isLoading = state is CourseLoading;

        return Container(
          color: AppColors.background,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: _buildUnifiedCard(state, courses, isLoading),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnifiedCard(CourseState state, List<Course> courses, bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3498DB), 
            Color(0xFF1ABC9C), 
            Color(0xFFF39C12), 
            Color(0xFFE74C3C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4)
          )
        ]
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: SearchAndAddCourseCard(
                controller: _controller,
                focusNode: _focusNode,
                isEditing: state.selectedCourse != null,
                onSearch: () {
                  _focusNode.unfocus();
                },
                onAdd: _addOrUpdateCourse,
              ),
            ),
            const Divider(height: 1, indent: 24, endIndent: 24),
            Expanded(
              child: isLoading && courses.isEmpty
                  ? const LoadingIndicator()
                  : CourseListView(
                      courses: courses,
                      selectedCourse: state.selectedCourse,
                      onSelect: _onSelectCourse,
                      onEdit: _onEditCourse,
                      onDelete: _removeCourse,
                      searchTerm: _searchTerm,
                    ),
            ),
            CourseStatsBar(
              courseCount: courses.length,
            )
          ],
        ),
      ),
    );
  }
} 