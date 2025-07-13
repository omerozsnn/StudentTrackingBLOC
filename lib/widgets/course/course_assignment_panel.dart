import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/course/course_bloc.dart';
import 'package:ogrenci_takip_sistemi/blocs/course/course_state.dart';
import 'package:ogrenci_takip_sistemi/models/courses_model.dart';
import 'package:ogrenci_takip_sistemi/core/theme/app_colors.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/gradient_border_container.dart';
import 'package:ogrenci_takip_sistemi/widgets/course/course_assignment_item.dart';

class CourseAssignmentPanel extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final Course? selectedCourse;
  final Function(Course) onCourseSelected;
  final Function(int) getAssignmentCount;

  const CourseAssignmentPanel({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedCourse,
    required this.onCourseSelected,
    required this.getAssignmentCount,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBorderContainer(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.book, 
                         color: Theme.of(context).colorScheme.primary, 
                         size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'DERSLER',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search bar
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Ders Ara...',
                    prefixIcon: Icon(Icons.search, 
                                   color: Theme.of(context).colorScheme.secondary, 
                                   size: 22),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
          // Course list
          Expanded(
            child: BlocBuilder<CourseBloc, CourseState>(
              builder: (context, state) {
                if (state is CourseLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CoursesLoaded) {
                  final filteredCourses = state.courses.where((course) {
                    return course.dersAdi.toLowerCase().contains(searchQuery.toLowerCase());
                  }).toList();

                  if (filteredCourses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, 
                               size: 48, 
                               color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                          const SizedBox(height: 16),
                          Text(
                            'Sonuç bulunamadı',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredCourses.length,
                    itemBuilder: (context, index) {
                      final course = filteredCourses[index];
                      final isSelected = selectedCourse?.id == course.id;
                      
                      return CourseAssignmentItem(
                        course: course,
                        isSelected: isSelected,
                        assignmentCount: getAssignmentCount(course.id),
                        onTap: () => onCourseSelected(course),
                      );
                    },
                  );
                } else if (state is CourseError) {
                  return Center(
                    child: Text(
                      'Hata: ${state.message}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                }
                return Center(
                  child: Text(
                    'Dersler yüklenemiyor',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 