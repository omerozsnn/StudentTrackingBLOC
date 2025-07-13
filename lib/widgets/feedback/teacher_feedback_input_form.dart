import 'package:flutter/material.dart';
import '../common/gradient_border_container.dart';

class TeacherFeedbackInputForm extends StatelessWidget {
  final TextEditingController controller;
  final bool hasSelection;
  final VoidCallback onAdd;
  final VoidCallback onUpdate;
  final VoidCallback? onDelete;
  final VoidCallback? onClear;

  const TeacherFeedbackInputForm({
    super.key,
    required this.controller,
    required this.hasSelection,
    required this.onAdd,
    required this.onUpdate,
    this.onDelete,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GradientBorderContainer(
      borderRadius: BorderRadius.circular(20),
      gradientColors: [
        colorScheme.primary.withOpacity(0.3),
        colorScheme.secondary.withOpacity(0.3),
      ],
      padding: const EdgeInsets.all(2),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hasSelection ? Icons.edit : Icons.add_comment,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  hasSelection ? 'Görüş Düzenle' : 'Yeni Görüş Ekle',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (hasSelection && onClear != null)
                  IconButton(
                    onPressed: onClear,
                    icon: Icon(
                      Icons.clear,
                      color: colorScheme.outline,
                    ),
                    tooltip: 'Seçimi Temizle',
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Input field
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Öğretmen Görüşü',
                hintText: 'Öğrenci hakkındaki görüşünüzü yazın...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: colorScheme.surface,
                prefixIcon: Icon(
                  Icons.comment_outlined,
                  color: colorScheme.primary,
                ),
              ),
              style: theme.textTheme.bodyMedium,
            ),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                // Primary action button (Add/Update)
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: hasSelection ? onUpdate : onAdd,
                    icon: Icon(
                      hasSelection ? Icons.update : Icons.add,
                      size: 20,
                    ),
                    label: Text(
                      hasSelection ? 'Güncelle' : 'Ekle',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasSelection 
                        ? colorScheme.tertiary 
                        : colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                
                // Delete button (only shown when editing)
                if (hasSelection && onDelete != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, size: 20),
                      label: const Text(
                        'Sil',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
} 