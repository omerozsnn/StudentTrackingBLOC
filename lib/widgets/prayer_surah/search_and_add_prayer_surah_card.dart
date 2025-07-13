import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/core/theme/app_colors.dart';

class SearchAndAddPrayerSurahCard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final VoidCallback onAdd;
  final FocusNode focusNode;
  final bool isEditing;

  const SearchAndAddPrayerSurahCard({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.onAdd,
    required this.focusNode,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    bool hasText = controller.text.isNotEmpty;

    return Column(
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(
                  isEditing ? Icons.edit_note : Icons.search,
                  color: AppColors.secondary,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Dua veya Sure ara veya ekle...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                label: 'Ara',
                onPressed: hasText ? onSearch : null,
                color: AppColors.accent,
                icon: Icons.search,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                label: isEditing ? 'Güncelle' : 'Ekle',
                onPressed: hasText ? onAdd : null,
                color: isEditing ? AppColors.warning : AppColors.secondary,
                icon: isEditing ? Icons.update : Icons.add,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoBar(),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    required IconData icon,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: color.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildInfoBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8F9FA), Color(0xFFE3F2FD)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: Color(0xFF3498DB), width: 4),
        ),
      ),
      child: const Row(
        children: [
          Text("💡", style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Aramak veya eklemek için dua/sure adını yazın. Düzenlemek için listeden seçin.',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
} 