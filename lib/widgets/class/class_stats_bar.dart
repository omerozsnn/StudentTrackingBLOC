import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/core/theme/app_colors.dart';

class ClassStatsBar extends StatelessWidget {
  final int classCount;
  final int studentCount; // Placeholder for now

  const ClassStatsBar({
    super.key,
    required this.classCount,
    required this.studentCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade200,
            AppColors.secondary.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(13),
          bottomRight: Radius.circular(13),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.school_outlined,
            label: 'Toplam Sınıf',
            value: classCount.toString(),
            color: AppColors.primary,
          ),
          _buildStatItem(
            icon: Icons.person_outline,
            label: 'Toplam Öğrenci',
            value: studentCount.toString(), // Using placeholder
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 