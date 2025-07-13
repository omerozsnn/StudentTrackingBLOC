import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'core/theme/custom_scroll_behavior.dart';

/// A customizable scrollable table widget that supports both horizontal and vertical scrolling
/// with mouse and touch interactions.
class ScrollableTable extends StatefulWidget {
  /// The fixed header widget to display at the top of the table
  final Widget header;

  /// Builder for content items
  final IndexedWidgetBuilder itemBuilder;

  /// Number of items to build
  final int itemCount;

  /// Total width of the content
  final double contentWidth;

  /// Estimated height per item for approximating total content height
  final double estimatedItemHeight;

  /// Whether to show the scroll indicator
  final bool showScrollIndicator;

  /// Whether to show custom scrollbars
  final bool showCustomScrollbars;

  /// Custom scroll physics for the horizontal scroll view
  final ScrollPhysics? horizontalScrollPhysics;

  /// Custom scroll physics for the vertical scroll view
  final ScrollPhysics? verticalScrollPhysics;

  const ScrollableTable({
    Key? key,
    required this.header,
    required this.itemBuilder,
    required this.itemCount,
    required this.contentWidth,
    this.estimatedItemHeight = 300,
    this.showScrollIndicator = true,
    this.showCustomScrollbars = true,
    this.horizontalScrollPhysics,
    this.verticalScrollPhysics,
  }) : super(key: key);

  @override
  _ScrollableTableState createState() => _ScrollableTableState();
}

class _ScrollableTableState extends State<ScrollableTable> {
  late ScrollController _horizontalScrollController;
  late ScrollController _verticalScrollController;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
    _verticalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate content size
        final contentHeight = constraints.maxHeight;
        final contentWidth = max(widget.contentWidth, constraints.maxWidth);

        return Stack(
          children: [
            // 1. Main scrollable content area
            ScrollConfiguration(
              behavior: CustomMouseScrollBehavior(),
              child: Listener(
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent) {
                    ScrollableTableHelper.handleMouseScroll(
                        event, _horizontalScrollController);
                  }
                },
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _horizontalScrollController,
                  physics: widget.horizontalScrollPhysics ??
                      const ClampingScrollPhysics(),
                  child: SizedBox(
                    width: contentWidth,
                    height: contentHeight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fixed header row
                        widget.header,

                        // Scrollable content list
                        Expanded(
                          child: ListView.builder(
                            controller: _verticalScrollController,
                            physics: widget.verticalScrollPhysics ??
                                const ClampingScrollPhysics(),
                            itemCount: widget.itemCount,
                            itemBuilder: widget.itemBuilder,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 2. Optional floating scroll indicator
            if (widget.showScrollIndicator)
              Positioned(
                bottom: 16,
                right: 16,
                child: ScrollableTableHelper.buildScrollIndicator(),
              ),

            // 3. Optional custom scrollbars
            if (widget.showCustomScrollbars) ...[
              // Horizontal scrollbar at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ScrollableTableHelper.buildCustomHorizontalScrollbar(
                  controller: _horizontalScrollController,
                  contentWidth: contentWidth,
                ),
              ),

              // Vertical scrollbar at right
              Positioned(
                top: widget.header.preferredSize?.height ?? 40,
                bottom: 8,
                right: 0,
                child: ScrollableTableHelper.buildCustomVerticalScrollbar(
                  controller: _verticalScrollController,
                  contentHeight: widget.itemCount * widget.estimatedItemHeight,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
