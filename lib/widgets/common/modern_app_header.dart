import 'package:flutter/material.dart';

class ModernAppHeader extends StatelessWidget {
  final String title;
  final String emoji;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Color? titleColor;
  final Color? iconColor;
  final EdgeInsets? padding;
  final bool showBackButton;
  final bool centerTitle;

  const ModernAppHeader({
    super.key,
    required this.title,
    required this.emoji,
    this.onBack,
    this.actions,
    this.titleColor,
    this.iconColor,
    this.padding,
    this.showBackButton = true,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final defaultTitleColor = titleColor ?? colorScheme.primary;
    final defaultIconColor = iconColor ?? colorScheme.primary;

    if (centerTitle) {
      return Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            if (showBackButton)
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: defaultIconColor,
                  size: 22,
                ),
                onPressed: onBack ?? () => Navigator.of(context).pop(),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surface,
                  padding: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
            const Spacer(),
            Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: defaultTitleColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Placeholder for actions to balance the row
            if (actions != null)
              Row(mainAxisSize: MainAxisSize.min, children: actions!)
            else if (showBackButton)
              const Opacity(
                opacity: 0,
                child: IconButton(icon: Icon(Icons.arrow_back_ios_new), onPressed: null),
              ),
          ],
        ),
      );
    }

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Back button
          if (showBackButton)
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: defaultIconColor,
                size: 22,
              ),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surface,
                padding: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          
          if (showBackButton) const SizedBox(width: 12),
          
          // Emoji
          Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
          
          const SizedBox(width: 12),
          
          // Title
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: defaultTitleColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Actions
          if (actions != null) ...[
            const SizedBox(width: 16),
            ...actions!,
          ],
        ],
      ),
    );
  }
}

class ModernActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? iconAsset;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isOutlined;
  final EdgeInsets? padding;

  const ModernActionButton({
    super.key,
    required this.label,
    this.icon,
    this.iconAsset,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.isOutlined = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget iconWidget;
    if (iconAsset != null) {
      iconWidget = Image.asset(
        iconAsset!,
        height: 20,
        width: 20,
        color: isOutlined ? colorScheme.primary : Colors.white,
      );
    } else if (icon != null) {
      iconWidget = Icon(
        icon!,
        size: 20,
        color: isOutlined ? colorScheme.primary : Colors.white,
      );
    } else {
      iconWidget = const SizedBox.shrink();
    }

    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: iconWidget,
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: foregroundColor ?? colorScheme.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: backgroundColor ?? colorScheme.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: iconWidget,
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? colorScheme.primary,
        foregroundColor: foregroundColor ?? Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
} 