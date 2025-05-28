import 'package:flutter/material.dart';

class DropdownCard<T> extends StatelessWidget {
  final String title;
  final String hint;
  final T? selectedValue;
  final List<T> items;
  final Function(T?) onChanged;
  final String Function(T) getLabel;

  const DropdownCard({
    super.key,
    required this.title,
    required this.hint,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    required this.getLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButton<T>(
              value: selectedValue,
              hint: Text(hint),
              isExpanded: true,
              items: items.map((T value) {
                return DropdownMenuItem<T>(
                  value: value,
                  child: Text(getLabel(value)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
} 