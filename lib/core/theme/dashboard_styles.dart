import 'package:flutter/material.dart';
import 'app_colors.dart';

class DashboardStyles {
  // Panel Decorations
  static BoxDecoration calendarPanelDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border(top: BorderSide(color: AppColors.calendarBorder, width: 4)), // Using calendarBorder
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 15,
        offset: Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration assignmentsPanelDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border(top: BorderSide(color: AppColors.assignmentsBorder, width: 4)), // Using assignmentsBorder
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 15,
        offset: Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration rankingPanelDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border(top: BorderSide(color: AppColors.rankingBorder, width: 4)), // Using rankingBorder
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 15,
        offset: Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration actionsPanelDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border(top: BorderSide(color: AppColors.actionsBorder, width: 4)), // Using actionsBorder
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 15,
        offset: Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration activitiesPanelDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border(top: BorderSide(color: AppColors.activitiesBorder, width: 4)), // Using activitiesBorder
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 15,
        offset: Offset(0, 4),
      ),
    ],
  );

  // Text Styles
  static TextStyle panelTitleStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle cardContentStyle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
  );

  static TextStyle cardSubtitleStyle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
  );

  // Button Styles
  static ButtonStyle quickActionButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.textPrimary,
    elevation: 2,
    padding: EdgeInsets.all(16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: AppColors.border, width: 1),
    ),
  );
} 