import 'package:flutter/material.dart';

class ErrorBanner extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final double padding;
  final Function()? onRetry;

  const ErrorBanner({
    Key? key,
    required this.message,
    this.backgroundColor = Colors.red,
    this.textColor = Colors.white,
    this.icon = Icons.error_outline,
    this.padding = 16.0,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 36),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: textColor, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
} 