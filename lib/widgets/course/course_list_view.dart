import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/courses_model.dart';
import 'package:ogrenci_takip_sistemi/core/theme/app_colors.dart';

class CourseListView extends StatelessWidget {
  final List<Course> courses;
  final Course? selectedCourse;
  final Function(Course) onSelect;
  final Function(Course) onEdit;
  final Function(int) onDelete;
  final String? searchTerm;

  const CourseListView({
    super.key,
    required this.courses,
    this.selectedCourse,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    this.searchTerm,
  });

  @override
  Widget build(BuildContext context) {
    final filteredCourses = searchTerm == null || searchTerm!.isEmpty
        ? courses
        : courses
            .where((c) =>
                c.dersAdi.toLowerCase().contains(searchTerm!.toLowerCase()))
            .toList();

    if (filteredCourses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              const Text(
                'Sonuç bulunamadı',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                searchTerm != null && searchTerm!.isNotEmpty
                    ? '"$searchTerm" adında bir ders eklemeyi deneyin.'
                    : 'Henüz hiç ders eklenmemiş.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            'Mevcut Dersler (${filteredCourses.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView.builder(
              itemCount: filteredCourses.length,
              itemBuilder: (context, index) {
                final course = filteredCourses[index];
                final isSelected = selectedCourse?.id == course.id;
                return _buildCourseListItem(context, course, isSelected);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseListItem(BuildContext context, Course course, bool isSelected) {
    return InkWell(
      onTap: () => onSelect(course),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.warning : AppColors.secondary,
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3498DB), Color(0xFF1ABC9C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.book, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                course.dersAdi,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isSelected ? AppColors.secondary : AppColors.textPrimary,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.accent),
              onPressed: () => onEdit(course),
              tooltip: 'Düzenle',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => onDelete(course.id),
              tooltip: 'Sil',
            ),
          ],
        ),
      ),
    );
  }
} 