import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math' show max;

import 'package:flutter/services.dart';

/// Custom scroll behavior to allow drag scrolling with mouse
class CustomMouseScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

/// Utility class for advanced scrollable tables
class ScrollableTableHelper {
  /// Handles mouse wheel scrolling with special handling for horizontal scroll
  static void handleMouseScroll(
      PointerScrollEvent event, ScrollController horizontalController) {
    // Calculate scroll speed factor - adjust according to preference
    const double scrollFactor = 3.0;

    // Get the horizontal scroll position details
    final horizontalPosition = horizontalController.position;

    if (event.kind == PointerDeviceKind.mouse) {
      // Check if shift is pressed for horizontal scrolling or if it's a horizontal scroll event
      final bool isShiftPressed = HardwareKeyboard.instance.logicalKeysPressed
          .contains(LogicalKeyboardKey.shift);
      final bool isHorizontalScroll =
          event.scrollDelta.dx.abs() > event.scrollDelta.dy.abs();

      if (isShiftPressed || isHorizontalScroll) {
        // Horizontal scrolling
        final double horizontalDelta =
            isHorizontalScroll ? event.scrollDelta.dx : event.scrollDelta.dy;
        final double newOffset =
            horizontalPosition.pixels + horizontalDelta * scrollFactor;

        // Apply bounds
        final double boundedOffset = newOffset.clamp(
            horizontalPosition.minScrollExtent,
            horizontalPosition.maxScrollExtent);

        horizontalPosition.jumpTo(boundedOffset);

        // Prevent default handling
      }
    }
  }

  /// Creates a custom scrollbar for horizontal scrolling without using the same controller
  static Widget buildCustomHorizontalScrollbar({
    required ScrollController controller,
    required double contentWidth,
    double height = 8,
    double thickness = 8,
    Radius radius = const Radius.circular(4),
    bool thumbVisibility = true,
    Color? thumbColor,
  }) {
    // Create a separate controller for the scrollbar's scrollable
    final scrollbarController = ScrollController();

    // Sync the main controller with the scrollbar controller
    controller.addListener(() {
      // Only sync if the scrollbar controller is attached and positions are different
      if (scrollbarController.hasClients &&
          scrollbarController.offset != controller.offset) {
        scrollbarController.jumpTo(controller.offset);
      }
    });

    return SizedBox(
      height: height,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(GlobalContext.context)
            .copyWith(scrollbars: false),
        child: Scrollbar(
          controller: scrollbarController,
          thickness: thickness,
          radius: radius,
          thumbVisibility: thumbVisibility,
          child: SingleChildScrollView(
            controller: scrollbarController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(width: contentWidth),
          ),
        ),
      ),
    );
  }

  /// Creates a custom scrollbar for vertical scrolling without using the same controller
  static Widget buildCustomVerticalScrollbar({
    required ScrollController controller,
    required double contentHeight,
    double width = 8,
    double thickness = 8,
    Radius radius = const Radius.circular(4),
    bool thumbVisibility = true,
    Color? thumbColor,
  }) {
    // Create a separate controller for the scrollbar's scrollable
    final scrollbarController = ScrollController();

    // Sync the main controller with the scrollbar controller
    controller.addListener(() {
      // Only sync if the scrollbar controller is attached and positions are different
      if (scrollbarController.hasClients &&
          scrollbarController.offset != controller.offset) {
        scrollbarController.jumpTo(controller.offset);
      }
    });

    return SizedBox(
      width: width,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(GlobalContext.context)
            .copyWith(scrollbars: false),
        child: Scrollbar(
          controller: scrollbarController,
          thickness: thickness,
          radius: radius,
          thumbVisibility: thumbVisibility,
          child: SingleChildScrollView(
            controller: scrollbarController,
            physics: const NeverScrollableScrollPhysics(),
            child: SizedBox(height: contentHeight),
          ),
        ),
      ),
    );
  }

  /// Creates a floating scroll indicator
  static Widget buildScrollIndicator({
    Color? backgroundColor,
    EdgeInsets padding = const EdgeInsets.all(8),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.blue.shade600,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'Mouse ile sürükle',
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
          SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swipe, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Icon(Icons.mouse, color: Colors.white, size: 16),
            ],
          ),
        ],
      ),
    );
  }
}

/// Helper to provide global context - add this to your main.dart
class GlobalContext {
  static late BuildContext context;

  static void initialize(BuildContext ctx) {
    context = ctx;
  }
}

/// Extension to calculate preferred size for widgets
extension PreferredSizeExtension on Widget {
  Size? get preferredSize {
    RenderBox? renderBox;
    try {
      renderBox = key as RenderBox;
    } catch (e) {
      return const Size.fromHeight(40); // Default height if not available
    }
    return renderBox?.size ?? const Size.fromHeight(40);
  }
}
