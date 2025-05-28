import 'package:flutter/material.dart';

class KdsAssignmentOptionCard extends StatelessWidget {
  final String selectedOption;
  final Function(String) onOptionChanged;

  const KdsAssignmentOptionCard({
    Key? key,
    required this.selectedOption,
    required this.onOptionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "KDS Atama Yöntemi",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildOptionChip('Sınıf Seviyesine Göre', 'level'),
                _buildOptionChip('Belirli Sınıfa Göre', 'class'),
                _buildOptionChip('Toplu KDS Atama', 'multiple'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Seçim chip'i
  Widget _buildOptionChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: selectedOption == value,
      onSelected: (bool selected) {
        if (selected) {
          onOptionChanged(value);
        }
      },
      selectedColor: Colors.teal.shade100,
      backgroundColor: Colors.grey.shade100,
    );
  }
}
