import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/student_model.dart';

class StudentSelectionCard extends StatelessWidget {
  final Student student;
  final bool isSelected;
  final Function(bool) onSelectionChanged;
  final VoidCallback? onTap;

  const StudentSelectionCard({
    Key? key,
    required this.student,
    required this.isSelected,
    required this.onSelectionChanged,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isSelected
            ? BorderSide(color: Colors.teal, width: 2)
            : BorderSide.none,
      ),
      color: isSelected ? Colors.teal.shade50 : Colors.white,
      child: ListTile(
        title: Text(
          student.adSoyad ?? 'Ad Soyad Yok',
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.teal : Colors.black87,
          ),
        ),
        onTap: onTap,
        trailing: Checkbox(
          value: isSelected,
          activeColor: Colors.teal,
          onChanged: (bool? value) {
            if (value != null) {
              onSelectionChanged(value);
            }
          },
        ),
      ),
    );
  }
}
