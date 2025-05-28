import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';

class ClassListItem extends StatelessWidget {
  final Classes sinif;
  final bool isSelected;
  final VoidCallback onTap;

  const ClassListItem({
    Key? key,
    required this.sinif,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isSelected
            ? BorderSide(color: Colors.deepPurpleAccent, width: 2)
            : BorderSide.none,
      ),
      color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
      elevation: isSelected ? 8 : 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          sinif.sinifAdi ?? 'Sınıf adı bulunamadı',
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.deepPurple : Colors.black,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.deepPurpleAccent)
            : null,
        onTap: onTap,
        selected: isSelected,
      ),
    );
  }
}
