import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/prayer_surah_model.dart';

class PrayerSurahCard extends StatelessWidget {
  final PrayerSurah prayerSurah;
  final bool isSelected;
  final Function(PrayerSurah) onTap;

  const PrayerSurahCard({
    Key? key,
    required this.prayerSurah,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

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
          prayerSurah.duaSureAdi,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.deepPurple : Colors.black,
          ),
        ),
        selected: isSelected,
        onTap: () => onTap(prayerSurah),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.deepPurpleAccent)
            : null,
      ),
    );
  }
}
