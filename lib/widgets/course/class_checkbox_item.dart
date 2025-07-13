import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';
import 'package:ogrenci_takip_sistemi/core/theme/app_colors.dart';

class ClassCheckboxItem extends StatelessWidget {
  final Classes classItem;
  final bool isSelected;
  final Function(bool?) onChanged;

  const ClassCheckboxItem({
    super.key,
    required this.classItem,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected 
            ? colorScheme.secondary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isSelected 
            ? Border.all(color: colorScheme.secondary.withOpacity(0.3))
            : null,
      ),
      child: CheckboxListTile(
        title: Text(
          '${classItem.sinifAdi} Sınıfı',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        value: isSelected,
        activeColor: colorScheme.secondary,
        checkColor: colorScheme.onSecondary,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
} 