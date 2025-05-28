import 'package:flutter/material.dart';

class SnackbarHelper {
  static void showSnackBar({
    required BuildContext context,
    required String message,
    IconData? icon,
    Color backgroundColor = Colors.black87,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(
      context: context,
      message: message,
      icon: Icons.check_circle,
      backgroundColor: Colors.green.shade700,
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(
      context: context,
      message: message,
      icon: Icons.error_outline,
      backgroundColor: Colors.red.shade700,
    );
  }

  static void showInfoSnackBar(BuildContext context, String message) {
    showSnackBar(
      context: context,
      message: message,
      icon: Icons.info_outline,
      backgroundColor: Colors.blue.shade700,
    );
  }

  static void showWarningSnackBar(BuildContext context, String message) {
    showSnackBar(
      context: context,
      message: message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: Colors.orange.shade700,
    );
  }

  static void showLoadingSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 16),
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.blue.shade700,
          duration: const Duration(seconds: 30),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  static void hideCurrentSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
