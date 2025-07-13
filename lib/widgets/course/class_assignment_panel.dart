import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/courses_model.dart';
import 'package:ogrenci_takip_sistemi/models/classes_model.dart';
import 'package:ogrenci_takip_sistemi/core/theme/app_colors.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/gradient_border_container.dart';
import 'package:ogrenci_takip_sistemi/widgets/course/class_checkbox_item.dart';
import 'package:ogrenci_takip_sistemi/widgets/common/info_message_widget.dart';

class ClassAssignmentPanel extends StatelessWidget {
  final Course? selectedCourse;
  final List<Classes> classes;
  final Set<int> selectedClassIds;
  final bool selectAll;
  final Function(bool?) onSelectAllChanged;
  final Function(int, bool) onClassSelectionChanged;

  const ClassAssignmentPanel({
    super.key,
    required this.selectedCourse,
    required this.classes,
    required this.selectedClassIds,
    required this.selectAll,
    required this.onSelectAllChanged,
    required this.onClassSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBorderContainer(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,  
              children: [
                Row(
                  children: [
                    Icon(Icons.school, 
                         color: Theme.of(context).colorScheme.secondary, 
                         size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedCourse != null 
                            ? 'ATANACAK SINIFLAR (Ders: ${selectedCourse!.dersAdi})'
                            : 'ATANACAK SINIFLAR',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Select all checkbox
                CheckboxListTile(
                  title: Text(
                    'Hepsini Seç',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16,
                    ),
                  ),
                  value: selectAll,
                  activeColor: Theme.of(context).colorScheme.secondary,
                  checkColor: Theme.of(context).colorScheme.onSecondary,
                  onChanged: selectedCourse != null ? onSelectAllChanged : null,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          // Class list
          Expanded(
            child: selectedCourse == null
                ? const InfoMessageWidget(
                    message: 'Sınıf atamak için önce bir ders seçin',
                  )
                : classes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school_outlined, 
                                 size: 48, 
                                 color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                            const SizedBox(height: 16),
                            Text(
                              'Sınıf bulunamadı',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          if (selectedCourse != null)
                            const InfoMessageWidget(
                              message: 'Bu dersi atamak istediğiniz sınıfları işaretleyin',
                            ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: classes.length,
                              itemBuilder: (context, index) {
                                final classItem = classes[index];
                                final isSelected = selectedClassIds.contains(classItem.id);
                                
                                return ClassCheckboxItem(
                                  classItem: classItem,
                                  isSelected: isSelected,
                                  onChanged: (bool? value) {
                                    onClassSelectionChanged(classItem.id, value ?? false);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
} 