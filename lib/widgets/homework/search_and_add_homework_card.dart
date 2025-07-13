import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

class SearchAndAddHomeworkCard extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController dueDateController;
  final FocusNode titleFocusNode;
  final FocusNode dueDateFocusNode;
  final bool isEditing;
  final VoidCallback onAdd;
  final VoidCallback? onDelete;
  final VoidCallback? onClear;

  const SearchAndAddHomeworkCard({
    super.key,
    required this.titleController,
    required this.dueDateController,
    required this.titleFocusNode,
    required this.dueDateFocusNode,
    required this.isEditing,
    required this.onAdd,
    this.onDelete,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isEditing ? Icons.edit_note : Icons.add_task,
                color: colorScheme.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Ödevi Düzenle' : 'Yeni Ödev Ekle',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    isEditing ? 'Seçili ödevi düzenleyin' : 'Ödev bilgilerini girin',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Form Fields
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ödev Adı',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: titleController,
                    focusNode: titleFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Ödev adını girin...',
                      prefixIcon: Icon(Icons.assignment, color: colorScheme.primary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Teslim Tarihi',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dueDateController,
                    focusNode: dueDateFocusNode,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: InputDecoration(
                      hintText: 'Tarih seçin',
                      prefixIcon: Icon(Icons.calendar_today, color: colorScheme.secondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      filled: true,
                      fillColor: colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _canAdd() ? onAdd : null,
                icon: Icon(
                  isEditing ? Icons.update : Icons.add,
                  color: colorScheme.onSecondary,
                ),
                label: Text(
                  isEditing ? 'Güncelle' : 'Ekle',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canAdd() ? colorScheme.secondary : colorScheme.onSurface.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            if (isEditing) ...[
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onDelete,
                icon: Icon(Icons.delete, color: colorScheme.onError),
                label: Text(
                  'Sil',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onError,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
            if (isEditing || titleController.text.isNotEmpty) ...[
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onClear,
                icon: Icon(Icons.clear, color: colorScheme.onSurface),
                label: Text(
                  'Temizle',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppColors.border),
                  ),
                  elevation: 1,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  bool _canAdd() {
    return titleController.text.trim().isNotEmpty && 
           dueDateController.text.trim().isNotEmpty;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.secondary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      dueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }
} 