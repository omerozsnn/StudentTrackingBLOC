import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';

class ClassCourseSelector extends StatelessWidget {
  final List<Classes> classes;
  final String? selectedClass;
  final List<Map<String, dynamic>> courses;
  final String? selectedCourse;
  final int selectedSemester;
  final Function(String) onClassChanged;
  final Function(String) onCourseChanged;
  final Function(int) onSemesterChanged;

  const ClassCourseSelector({
    Key? key,
    required this.classes,
    required this.selectedClass,
    required this.courses,
    required this.selectedCourse,
    required this.selectedSemester,
    required this.onClassChanged,
    required this.onCourseChanged,
    required this.onSemesterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Building ClassCourseSelector with semester: $selectedSemester");

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown(
              hint: 'Sınıf Seçin',
              value: selectedClass,
              items: classes.map((Classes classItem) {
                return DropdownMenuItem<String>(
                  value: classItem.sinifAdi,
                  child: Text(classItem.sinifAdi),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onClassChanged(value);
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildDropdown(
              hint: 'Ders Seçin',
              value: selectedCourse,
              items: courses.map((course) {
                return DropdownMenuItem<String>(
                  value: course['ders_adi'],
                  child: Text(course['ders_adi']),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onCourseChanged(value);
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSemesterDropdown(),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterDropdown() {
    print("Building semester dropdown with selected value: $selectedSemester");

    final semesterItems = [1, 2].map((int value) {
      return DropdownMenuItem<String>(
        value: value.toString(),
        child: Text('$value. Dönem'),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          key: ValueKey('semester-dropdown-$selectedSemester'),
          hint: Text('Dönem Seçin'),
          value: selectedSemester.toString(),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down_circle_outlined),
          items: semesterItems,
          onChanged: (value) {
            print("Semester dropdown value changed to: $value");
            if (value != null) {
              onSemesterChanged(int.parse(value));
            }
          },
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint),
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down_circle_outlined),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
