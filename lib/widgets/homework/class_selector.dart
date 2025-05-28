import 'package:flutter/material.dart';
import '../../models/classes_model.dart';

class ClassSelector extends StatelessWidget {
  final List<Classes> classes;
  final Classes? selectedClass;
  final Function(Classes?) onClassSelected;

  const ClassSelector({
    Key? key,
    required this.classes,
    this.selectedClass,
    required this.onClassSelected,
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
            const Text('Sınıf Seçin',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int?>(
              value: selectedClass?.id,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: 'Bir sınıf seçin',
                prefixIcon: const Icon(Icons.school, color: Colors.teal),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Sınıf seçin'),
                ),
                ...classes.map((classItem) {
                  return DropdownMenuItem<int?>(
                    value: classItem.id,
                    child: Text(
                      classItem.sinifAdi,
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                if (value == null) {
                  onClassSelected(null);
                } else {
                  final selectedClass = classes.firstWhere(
                    (classItem) => classItem.id == value,
                    orElse: () => classes.first,
                  );
                  onClassSelected(selectedClass);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
