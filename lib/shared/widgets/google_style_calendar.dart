import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart'; // Adjusted import path

class GoogleStyleCalendar extends StatefulWidget {
  final List<DateTime> assignmentDates;

  const GoogleStyleCalendar({
    Key? key,
    this.assignmentDates = const [], // Default to empty list
  }) : super(key: key);

  @override
  _GoogleStyleCalendarState createState() => _GoogleStyleCalendarState();
}

class _GoogleStyleCalendarState extends State<GoogleStyleCalendar> {
  DateTime _currentMonth = DateTime.now();
  Set<int> _hoveredDays = {}; // To track hovered day numbers

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  String _getMonthName(int month) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return months[month - 1];
  }

  Widget _buildLegendItem(Color color, String text, BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
          )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardTheme = theme.cardTheme;

    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    // Adjust for Dart's weekday (Monday=1, Sunday=7) to typical calendar (Sunday=0 or 1)
    // Assuming a week starts on Monday for day abbreviations P,S,Ç,P,C,C,P
    final firstWeekdayOfMonth = firstDayOfMonth.weekday; 

    final today = DateTime.now();

    // Normalize assignment dates to ignore time component for accurate day matching
    final Set<DateTime> normalizedAssignmentDates = widget.assignmentDates.map((date) => DateTime(date.year, date.month, date.day)).toSet();

    return Card(
      elevation: cardTheme.elevation ?? 4,
      shape: cardTheme.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // color: cardTheme.color, // Card color will be from theme, container below will have its own surface.
      // margin: cardTheme.margin, // Card margin will be from theme
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface, // Use theme surface color for container
          borderRadius: BorderRadius.circular(12), // Match card shape or define independently
          border: Border(top: BorderSide(color: AppColors.calendarBorder, width: 4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12.0), // Overall padding for the calendar content
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Takvim başlığı (Month and Year)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface)
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, size: 20, color: theme.iconTheme.color),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: _previousMonth,
                    ),
                    SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.chevron_right, size: 20, color: theme.iconTheme.color),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),

            // Gün isimleri (Day Abbreviations)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'] // Updated Turkish day names
                  .map((day) => SizedBox(
                        width: 32, // Adjusted width for better spacing
                        child: Text(
                          day,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                          textAlign: TextAlign.center,
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 8),

            // Takvim günleri (Calendar Grid)
            ...List.generate(6, (weekIndex) {
              // Check if this week row is necessary (if it contains any days of the current month)
              bool weekIsNecessary = false;
              for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
                final dayNumber = weekIndex * 7 + dayIndex - firstWeekdayOfMonth + 2; // +1 for 1-based day, +1 for Monday start
                 if (dayNumber > 0 && dayNumber <= daysInMonth) {
                  weekIsNecessary = true;
                  break;
                }
              }
              if (!weekIsNecessary && weekIndex > 0) { // Always show first week if month starts late in it
                // If the first day of the month is Sunday (weekday 7) and it's the first week, 
                // but the loop for days starts from Monday, we might miss this check for the first row.
                // Simplified logic: if no days of current month, and not the first row that might contain start of month, hide.
                if (!(weekIndex == 0 && (firstWeekdayOfMonth-1 + daysInMonth > 0))) return SizedBox.shrink();
              }

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 2.0), // spacing between weeks
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (dayIndex) {
                    // Adjust dayNumber calculation for 1-based firstWeekdayOfMonth (Monday=1...Sunday=7)
                    final dayNumber = weekIndex * 7 + dayIndex - (firstWeekdayOfMonth -1) + 1;

                    final bool isCurrentMonthDay = dayNumber > 0 && dayNumber <= daysInMonth;
                    final currentDate = isCurrentMonthDay
                        ? DateTime(_currentMonth.year, _currentMonth.month, dayNumber)
                        : null;

                    bool isTodayFlag = false;
                    bool isAssignmentDateFlag = false;

                    if (currentDate != null) {
                      isTodayFlag = currentDate.year == today.year &&
                                    currentDate.month == today.month &&
                                    currentDate.day == today.day;
                      isAssignmentDateFlag = normalizedAssignmentDates.contains(currentDate);
                    }

                    final bool isHovered = _hoveredDays.contains(dayNumber) && isCurrentMonthDay;

                    BoxDecoration? cellDecoration;
                    TextStyle cellTextStyle = theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.4) // Default for non-current month days
                    );

                    if (isCurrentMonthDay) {
                       if (isTodayFlag) {
                        cellDecoration = BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle);
                        cellTextStyle = theme.textTheme.bodyMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.bold);
                      } else if (isAssignmentDateFlag) {
                        cellDecoration = BoxDecoration(color: AppColors.calendarwarning, shape: BoxShape.circle);
                        // Choose text color for warning background based on contrast
                        final warningTextColor = ThemeData.estimateBrightnessForColor(AppColors.calendarwarning) == Brightness.dark
                                              ? Colors.white : AppColors.textPrimary;
                        cellTextStyle = theme.textTheme.bodyMedium!.copyWith(color: warningTextColor, fontWeight: FontWeight.bold);
                      } else if (isHovered) {
                        cellDecoration = BoxDecoration(color: AppColors.secondary.withOpacity(0.2), shape: BoxShape.circle);
                        cellTextStyle = theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onSurface);
                      } else {
                        cellTextStyle = theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onSurface);
                      }
                    }
                    
                    return MouseRegion(
                      onEnter: isCurrentMonthDay ? (_) => setState(() => _hoveredDays.add(dayNumber)) : null,
                      onExit: isCurrentMonthDay ? (_) => setState(() => _hoveredDays.remove(dayNumber)) : null,
                      cursor: isCurrentMonthDay ? SystemMouseCursors.click : SystemMouseCursors.basic,
                      child: GestureDetector(
                        onTap: isCurrentMonthDay ? () { /* Add onTap functionality if needed */ } : null,
                        child: Container(
                          width: 32, // Cell width
                          height: 32, // Cell height
                          decoration: cellDecoration,
                          child: Center(
                            child: Text(
                              isCurrentMonthDay ? dayNumber.toString() : '',
                              style: cellTextStyle,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
            SizedBox(height: 12),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(AppColors.secondary, "Bugün", context),
                SizedBox(width: 20), // Increased spacing for legend
                _buildLegendItem(AppColors.calendarwarning, "Ödev Tarihi", context),
              ],
            ),
            SizedBox(height: 4), // Padding at the bottom
          ],
        ),
      ),
    );
  }
} 