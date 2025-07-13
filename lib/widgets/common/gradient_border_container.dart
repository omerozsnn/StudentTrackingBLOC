import 'package:flutter/material.dart';
import 'package:ogrenci_takip_sistemi/core/theme/app_colors.dart';

class GradientBorderContainer extends StatelessWidget {
  final Widget child;
  final List<Color>? gradientColors;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final List<BoxShadow>? boxShadow;

  const GradientBorderContainer({
    super.key,
    required this.child,
    this.gradientColors,
    this.borderRadius,
    this.padding,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final defaultGradientColors = [
      AppColors.secondary,
      AppColors.accent,
      AppColors.warning,
      AppColors.error,
    ];

    final defaultBoxShadow = [
      BoxShadow(
        color: theme.shadowColor.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      )
    ];

    return Container(
      padding: padding ?? const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? defaultGradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: boxShadow ?? defaultBoxShadow,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: borderRadius?.subtract(const BorderRadius.all(Radius.circular(3))) ??
              BorderRadius.circular(13),
        ),
        child: child,
      ),
    );
  }
} 