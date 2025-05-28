import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/okul_denemesi_model.dart';

class OkulDenemesiItem extends StatelessWidget {
  final OkulDenemesi deneme;
  final bool isSelected;
  final VoidCallback onTap;

  const OkulDenemesiItem({
    super.key,
    required this.deneme,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Colors.deepPurpleAccent, width: 2)
            : BorderSide.none,
      ),
      color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
      elevation: isSelected ? 8 : 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          deneme.sinavAdi,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.deepPurple : Colors.black,
          ),
        ),
        subtitle: Text(
          'Yanlış Götürme Oranı: ${deneme.yanlisGoturmeOrani}, Tarih: ${DateFormat('yyyy-MM-dd').format(deneme.sinavTarihi)}',
        ),
        onTap: onTap,
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.deepPurpleAccent)
            : null,
      ),
    );
  }
}
