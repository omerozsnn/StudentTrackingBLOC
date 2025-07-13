import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/models/homework_model.dart';
import 'package:ogrenci_takip_sistemi/core/theme/app_colors.dart';

class HomeworkStatsBar extends StatelessWidget {
  final List<Homework> homeworks;

  const HomeworkStatsBar({
    super.key,
    required this.homeworks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final totalCount = homeworks.length;
    final overdueCount = homeworks.where((h) => h.teslimTarihi.isBefore(DateTime.now())).length;
    final todayCount = homeworks.where((h) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final homeworkDate = DateTime(h.teslimTarihi.year, h.teslimTarihi.month, h.teslimTarihi.day);
      return homeworkDate.isAtSameMomentAs(today);
    }).length;
    final upcomingCount = homeworks.where((h) {
      final daysLeft = h.teslimTarihi.difference(DateTime.now()).inDays;
      return daysLeft > 0 && daysLeft <= 7;
    }).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(13),
          bottomRight: Radius.circular(13),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            title: 'Toplam',
            count: totalCount,
            color: colorScheme.primary,
            icon: Icons.assignment,
          ),
          _buildDivider(context),
          _buildStatItem(
            context,
            title: 'Geciken',
            count: overdueCount,
            color: colorScheme.error,
            icon: Icons.warning,
          ),
          _buildDivider(context),
          _buildStatItem(
            context,
            title: 'Bugün',
            count: todayCount,
            color: AppColors.warning,
            icon: Icons.today,
          ),
          _buildDivider(context),
          _buildStatItem(
            context,
            title: 'Yaklaşan',
            count: upcomingCount,
            color: AppColors.success,
            icon: Icons.schedule,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
    );
  }
} 