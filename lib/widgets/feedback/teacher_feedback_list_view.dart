import 'package:flutter/material.dart';
import '../../models/teacher_feedback_option_model.dart';
import 'teacher_feedback_option_card.dart';
import '../common/gradient_border_container.dart';

class TeacherFeedbackListView extends StatelessWidget {
  final List<TeacherFeedbackOption> options;
  final TeacherFeedbackOption? selectedOption;
  final Function(TeacherFeedbackOption) onOptionTap;
  final bool isLoading;

  const TeacherFeedbackListView({
    super.key,
    required this.options,
    this.selectedOption,
    required this.onOptionTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return _buildLoadingState(context);
    }

    if (options.isEmpty) {
      return _buildEmptyState(context);
    }

    return GradientBorderContainer(
      borderRadius: BorderRadius.circular(20),
      gradientColors: [
        colorScheme.primary.withOpacity(0.1),
        colorScheme.secondary.withOpacity(0.1),
      ],
      child: Container(
        padding: const EdgeInsets.all(16),
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
                  child: const Icon(
                    Icons.list_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Mevcut Görüşler',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${options.length} görüş',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Feedback list
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = selectedOption?.id == option.id;
                  
                  return TeacherFeedbackOptionCard(
                    option: option,
                    isSelected: isSelected,
                    onTap: () => onOptionTap(option),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GradientBorderContainer(
      borderRadius: BorderRadius.circular(20),
      gradientColors: [
        colorScheme.primary.withOpacity(0.1),
        colorScheme.secondary.withOpacity(0.1),
      ],
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Görüşler yükleniyor...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GradientBorderContainer(
      borderRadius: BorderRadius.circular(20),
      gradientColors: [
        colorScheme.primary.withOpacity(0.1),
        colorScheme.secondary.withOpacity(0.1),
      ],
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.comment_outlined,
                size: 48,
                color: colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '📝 Henüz Görüş Yok',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Yeni bir öğretmen görüşü ekleyerek başlayın.\nBu görüşleri daha sonra öğrencilere atayabilirsiniz.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 