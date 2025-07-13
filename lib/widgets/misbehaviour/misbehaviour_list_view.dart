import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/misbehaviour_model.dart';
import 'package:ogrenci_takip_sistemi/core/theme/app_colors.dart';
import 'package:ogrenci_takip_sistemi/widgets/misbehaviour/misbehaviour_item.dart';

class MisbehaviourListView extends StatelessWidget {
  final List<Misbehaviour> misbehaviours;
  final Misbehaviour? selectedMisbehaviour;
  final Function(Misbehaviour) onSelect;
  final Function(Misbehaviour) onEdit;
  final Function(int) onDelete;
  final String? searchTerm;

  const MisbehaviourListView({
    super.key,
    required this.misbehaviours,
    this.selectedMisbehaviour,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
    this.searchTerm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final filteredMisbehaviours = searchTerm == null || searchTerm!.isEmpty
        ? misbehaviours
        : misbehaviours
            .where((m) =>
                m.yaramazlikAdi.toLowerCase().contains(searchTerm!.toLowerCase()))
            .toList();

    if (filteredMisbehaviours.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                searchTerm != null && searchTerm!.isNotEmpty 
                    ? Icons.search_off 
                    : Icons.warning_amber_rounded,
                size: 64, 
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(height: 16),
              Text(
                searchTerm != null && searchTerm!.isNotEmpty
                    ? 'Sonuç bulunamadı'
                    : 'Henüz hiç yaramazlık eklenmemiş',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                searchTerm != null && searchTerm!.isNotEmpty
                    ? '"$searchTerm" adında bir yaramazlık eklemeyi deneyin.'
                    : 'İlk yaramazlığı eklemek için yukarıdaki formu kullanın.',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            'Yaramazlıklar (${filteredMisbehaviours.length})',
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
              itemCount: filteredMisbehaviours.length,
              itemBuilder: (context, index) {
                final misbehaviour = filteredMisbehaviours[index];
                final isSelected = selectedMisbehaviour?.id == misbehaviour.id;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: MisbehaviourItem(
                          name: misbehaviour.yaramazlikAdi,
                          isSelected: isSelected,
                          onTap: () => onSelect(misbehaviour),
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.accent),
                          onPressed: () => onEdit(misbehaviour),
                          tooltip: 'Düzenle',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: () => onDelete(misbehaviour.id!),
                          tooltip: 'Sil',
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
} 