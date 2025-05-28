import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/homework_model.dart';

class HomeworkListItem extends StatelessWidget {
  final Homework homework;
  final bool isSelected;
  final Function(Homework) onTap;

  const HomeworkListItem({
    Key? key,
    required this.homework,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isSelected ? Colors.deepPurple.shade50 : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          homework.odevAdi,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Teslim Tarihi: ${DateFormat('dd MMMM yyyy', 'tr_TR').format(homework.teslimTarihi)}',
          style: TextStyle(
            color: _isOverdue(homework.teslimTarihi)
                ? Colors.red
                : Colors.grey.shade700,
          ),
        ),
        onTap: () => onTap(homework),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.deepPurpleAccent)
            : null,
      ),
    );
  }

  bool _isOverdue(DateTime dueDate) {
    final now = DateTime.now();
    return dueDate.isBefore(DateTime(now.year, now.month, now.day));
  }
}
