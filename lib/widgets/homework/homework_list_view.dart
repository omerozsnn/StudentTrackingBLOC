import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/homework_model.dart';
import 'package:ogrenci_takip_sistemi/core/theme/app_colors.dart';
import 'package:ogrenci_takip_sistemi/widgets/homework/homework_card.dart';

class HomeworkListView extends StatelessWidget {
  final List<Homework> homeworks;
  final Homework? selectedHomework;
  final Function(Homework) onSelect;
  final Function(Homework) onEdit;
  final Function(int) onDelete;
  final String? searchTerm;

  const HomeworkListView({
    super.key,
    required this.homeworks,
    this.selectedHomework,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    this.searchTerm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final filteredHomeworks = searchTerm == null || searchTerm!.isEmpty
        ? homeworks
        : homeworks
            .where((h) =>
                h.odevAdi.toLowerCase().contains(searchTerm!.toLowerCase()))
            .toList();

    if (filteredHomeworks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                searchTerm != null && searchTerm!.isNotEmpty 
                    ? Icons.search_off 
                    : Icons.assignment_outlined,
                size: 64, 
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(height: 16),
              Text(
                searchTerm != null && searchTerm!.isNotEmpty
                    ? 'Sonuç bulunamadı'
                    : 'Henüz hiç ödev eklenmemiş',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                searchTerm != null && searchTerm!.isNotEmpty
                    ? '"$searchTerm" adında bir ödev eklemeyi deneyin.'
                    : 'İlk ödevi eklemek için yukarıdaki formu kullanın.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Sort homeworks by due date
    final sortedHomeworks = List<Homework>.from(filteredHomeworks);
    sortedHomeworks.sort((a, b) => a.teslimTarihi.compareTo(b.teslimTarihi));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            'Ödevler (${sortedHomeworks.length})',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView.builder(
              itemCount: sortedHomeworks.length,
              itemBuilder: (context, index) {
                final homework = sortedHomeworks[index];
                final isSelected = selectedHomework?.id == homework.id;
                
                return HomeworkCard(
                  homework: homework,
                  isSelected: isSelected,
                  onTap: () => onSelect(homework),
                  onEdit: () => onEdit(homework),
                  onDelete: homework.id != null ? () => onDelete(homework.id!) : null,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
} 