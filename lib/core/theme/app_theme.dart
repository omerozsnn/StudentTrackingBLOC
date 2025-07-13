import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_colors_dark.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.error,
      onPrimary: Colors.white, // Assuming white text on primary color
      onSecondary: Colors.white, // Assuming white text on secondary color
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
      onError: Colors.white, // Assuming white text on error color
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.surface, // Use surface color (white) for icons/text on primary appbar
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.surface, // Use surface color (white) for title
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.zero, // Reset margin, individual cards can set their own if needed
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.surface, // Text on elevated buttons (white on blue)
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Default padding
      ),
    ),
    textTheme: TextTheme(
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary), 
        bodyLarge: TextStyle(fontSize: 14, color: AppColors.textPrimary), 
        bodyMedium: TextStyle(fontSize: 14, color: AppColors.textSecondary), 
        labelLarge: TextStyle(fontSize: 12, color: AppColors.textSecondary), 
      ).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
      ),
       inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface, 
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondary)
      ),
      iconTheme: IconThemeData(
        color: AppColors.primary, // Default icon color
      )
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColorsDark.primary,
    scaffoldBackgroundColor: AppColorsDark.background,
    colorScheme: ColorScheme.dark(
      primary: AppColorsDark.primary,
      secondary: AppColorsDark.secondary,
      surface: AppColorsDark.surface,
      background: AppColorsDark.background,
      error: AppColorsDark.error,
      onPrimary: AppColorsDark.textPrimary, // Text on primary color
      onSecondary: AppColorsDark.textPrimary, // Text on secondary color
      onSurface: AppColorsDark.textPrimary,
      onBackground: AppColorsDark.textPrimary,
      onError: AppColorsDark.textPrimary, // Text on error color
      brightness: Brightness.dark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsDark.primary,
      foregroundColor: AppColorsDark.textPrimary,
      elevation: 2,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColorsDark.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColorsDark.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsDark.secondary,
        foregroundColor: AppColorsDark.textPrimary, // Text on elevated buttons
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    textTheme: TextTheme(
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColorsDark.textPrimary), 
        bodyLarge: TextStyle(fontSize: 14, color: AppColorsDark.textPrimary), 
        bodyMedium: TextStyle(fontSize: 14, color: AppColorsDark.textSecondary), 
        labelLarge: TextStyle(fontSize: 12, color: AppColorsDark.textSecondary), 
      ).apply(
          bodyColor: AppColorsDark.textPrimary,
          displayColor: AppColorsDark.textPrimary,
      ),
    inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsDark.surface, 
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColorsDark.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColorsDark.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColorsDark.secondary, width: 2), // Use secondary for focus in dark
        ),
        labelStyle: TextStyle(color: AppColorsDark.textSecondary)
      ),
      iconTheme: IconThemeData(
        color: AppColorsDark.textPrimary, // Default icon color for dark theme
      )
  );
} 