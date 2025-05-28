import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/prayer_surah_model.dart';

class PrayerSurahForm extends StatelessWidget {
  final TextEditingController controller;
  final PrayerSurah? selectedPrayerSurah;
  final VoidCallback onAdd;
  final VoidCallback onUpdate;
  final VoidCallback? onDelete;

  const PrayerSurahForm({
    Key? key,
    required this.controller,
    this.selectedPrayerSurah,
    required this.onAdd,
    required this.onUpdate,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Sure veya Dua Adı',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: selectedPrayerSurah == null ? onAdd : onUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedPrayerSurah == null
                      ? Colors.deepPurpleAccent
                      : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  selectedPrayerSurah == null ? 'Ekle' : 'Güncelle',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 5),
            if (selectedPrayerSurah != null && onDelete != null)
              Expanded(
                child: ElevatedButton(
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Sil', style: TextStyle(fontSize: 16)),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
