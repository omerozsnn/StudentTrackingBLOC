import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/deneme_sinavi_model.dart';

class DenemeSinaviCard extends StatelessWidget {
  final DenemeSinavi denemeSinavi;
  final bool isSelected;
  final Function() onTap;
  final String uniteAdi;

  const DenemeSinaviCard({
    Key? key,
    required this.denemeSinavi,
    required this.isSelected,
    required this.onTap,
    required this.uniteAdi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Colors.deepPurpleAccent, width: 2)
            : BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          denemeSinavi.denemeSinaviAdi ?? 'İsimsiz Deneme',
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.deepPurple : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Soru Sayısı: ${denemeSinavi.soruSayisi ?? "Belirtilmemiş"}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.book_outlined,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Ünite: $uniteAdi',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: isSelected
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.deepPurpleAccent,
                  size: 24,
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
} 