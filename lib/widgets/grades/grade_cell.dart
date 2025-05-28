import 'package:flutter/material.dart';

class GradeCell extends StatelessWidget {
  final Map<String, dynamic> student;
  final String gradeType;
  final Function(Map<String, dynamic>, String) onTap;

  const GradeCell({
    Key? key,
    required this.student,
    required this.gradeType,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure grades field exists
    final grades = student['grades'] ?? {};
    final hasGrade = grades is Map &&
        grades.containsKey(gradeType) &&
        grades[gradeType] != null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () => onTap(student, gradeType),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: hasGrade ? Colors.blue.shade100 : Colors.grey.shade200,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            hasGrade ? grades[gradeType].toString() : '-',
            style: TextStyle(
              color: hasGrade ? Colors.black87 : Colors.red,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
