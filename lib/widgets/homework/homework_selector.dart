import 'package:flutter/material.dart';
import '../../models/homework_model.dart';

class HomeworkSelector extends StatelessWidget {
  final List<Homework> homeworks;
  final Homework? selectedHomework;
  final Function(Homework?) onHomeworkSelected;

  const HomeworkSelector({
    Key? key,
    required this.homeworks,
    this.selectedHomework,
    required this.onHomeworkSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ödev Seçin',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int?>(
              value: selectedHomework?.id,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: 'Atanacak ödevi seçin',
                prefixIcon: const Icon(Icons.assignment, color: Colors.teal),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text(
                    'Ödev seçin',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                ...homeworks.map((homework) {
                  return DropdownMenuItem<int?>(
                    value: homework.id,
                    child: Text(
                      homework.odevAdi,
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                if (value == null) {
                  onHomeworkSelected(null);
                } else {
                  final selectedHomework = homeworks.firstWhere(
                    (homework) => homework.id == value,
                    orElse: () => homeworks.first,
                  );
                  onHomeworkSelected(selectedHomework);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
