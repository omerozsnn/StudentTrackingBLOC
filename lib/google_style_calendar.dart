import 'package:flutter/material.dart';

class GoogleStyleCalendar extends StatefulWidget {
  @override
  _GoogleStyleCalendarState createState() => _GoogleStyleCalendarState();
}

class _GoogleStyleCalendarState extends State<GoogleStyleCalendar> {
  DateTime _currentMonth = DateTime.now();

  // Pastel Renkler
  final Color bgOrange = Color(0xFFFFE0B2); // Açık pastel turuncu (arka plan)
  final Color textColor = Colors.black87; // Metin rengi

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
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final firstWeekdayOfMonth = firstDayOfMonth.weekday;

    return Positioned(
      top: 16,
      right: 16,
      child: Card(
        elevation: 0,
        color: bgOrange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          width: 180, // Daha da küçük genişlik
          padding: EdgeInsets.all(8), // Daha küçük padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Takvim başlığı
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: _previousMonth,
                        color: textColor,
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.chevron_right, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: _nextMonth,
                        color: textColor,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Gün isimleri
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['P', 'P', 'S', 'Ç', 'P', 'C', 'C']
                    .map((day) => SizedBox(
                          width: 20,
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 9,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ))
                    .toList(),
              ),
              SizedBox(height: 4),

              // Takvim günleri
              ...List.generate(6, (weekIndex) {
                return Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (dayIndex) {
                      final dayNumber =
                          weekIndex * 7 + dayIndex - firstWeekdayOfMonth + 1;
                      final isCurrentMonth =
                          dayNumber > 0 && dayNumber <= daysInMonth;

                      final currentDate = isCurrentMonth
                          ? DateTime(_currentMonth.year, _currentMonth.month,
                              dayNumber)
                          : null;

                      final isToday =
                          currentDate?.year == DateTime.now().year &&
                              currentDate?.month == DateTime.now().month &&
                              currentDate?.day == DateTime.now().day;

                      return SizedBox(
                        width: 20,
                        height: 20,
                        child: Container(
                          decoration: isToday
                              ? BoxDecoration(
                                  color: Colors.black87,
                                  shape: BoxShape.circle,
                                )
                              : null,
                          child: Center(
                            child: Text(
                              isCurrentMonth ? dayNumber.toString() : '',
                              style: TextStyle(
                                fontSize: 10,
                                color: isToday
                                    ? Colors.white
                                    : isCurrentMonth
                                        ? textColor
                                        : Colors.grey[500],
                                fontWeight: isToday
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
