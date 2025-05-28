import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/teacher_feedback_option_model.dart';

class TeacherFeedbackOptionItem extends StatelessWidget {
  final TeacherFeedbackOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const TeacherFeedbackOptionItem({
    required this.option,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Colors.deepPurpleAccent, width: 2)
            : BorderSide.none,
      ),
      color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
      elevation: isSelected ? 8 : 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          option.gorusMetni,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.deepPurple : Colors.black,
          ),
        ),
        selected: isSelected,
        onTap: onTap,
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.deepPurpleAccent)
            : null,
      ),
    );
  }
}
