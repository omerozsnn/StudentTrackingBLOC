import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';
import 'package:ogrenci_takip_sistemi/core/theme/app_colors.dart';

class ClassListView extends StatelessWidget {
  final List<Classes> classes;
  final Classes? selectedClass;
  final Function(Classes) onSelect;
  final Function(Classes) onEdit;
  final Function(int) onDelete;
  final String? searchTerm;

  const ClassListView({
    super.key,
    required this.classes,
    this.selectedClass,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    this.searchTerm,
  });

  @override
  Widget build(BuildContext context) {
    final filteredClasses = searchTerm == null || searchTerm!.isEmpty
        ? classes
        : classes
            .where((c) =>
                c.sinifAdi.toLowerCase().contains(searchTerm!.toLowerCase()))
            .toList();

    if (filteredClasses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              const Text(
                'Sonuç bulunamadı',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                searchTerm != null && searchTerm!.isNotEmpty
                    ? '"$searchTerm" adında bir sınıf eklemeyi deneyin.'
                    : 'Henüz hiç sınıf eklenmemiş.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Text(
            'Mevcut Sınıflar (${filteredClasses.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView.builder(
              itemCount: filteredClasses.length,
              itemBuilder: (context, index) {
                final sinif = filteredClasses[index];
                final isSelected = selectedClass?.id == sinif.id;
                return _buildClassListItem(context, sinif, isSelected);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassListItem(BuildContext context, Classes sinif, bool isSelected) {
    return InkWell(
      onTap: () => onSelect(sinif),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.warning : AppColors.secondary,
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3498DB), Color(0xFF1ABC9C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.school, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                sinif.sinifAdi,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isSelected ? AppColors.secondary : AppColors.textPrimary,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.accent),
              onPressed: () => onEdit(sinif),
              tooltip: 'Düzenle',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => onDelete(sinif.id),
              tooltip: 'Sil',
            ),
          ],
        ),
      ),
    );
  }
} 