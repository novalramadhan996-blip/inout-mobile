import 'package:table_calendar/table_calendar.dart';

class CalendarRange {
  final DateTime start;
  final DateTime end;

  const CalendarRange({required this.start, required this.end});
}

CalendarRange getCalendarRange({
  required DateTime focusedDay,
  required CalendarFormat format,
  StartingDayOfWeek startingDayOfWeek = StartingDayOfWeek.monday,
  bool sixWeekMonthsEnforced = false,
}) {
  switch (format) {
    case CalendarFormat.week:
      final firstDay = _firstDayOfWeek(focusedDay, startingDayOfWeek);

      return CalendarRange(
        start: firstDay,
        end: firstDay.add(const Duration(days: 6)),
      );

    case CalendarFormat.twoWeeks:
      final firstDay = _firstDayOfWeek(focusedDay, startingDayOfWeek);

      return CalendarRange(
        start: firstDay,
        end: firstDay.add(const Duration(days: 13)),
      );

    case CalendarFormat.month:
      final firstVisible = _firstVisibleDayOfMonth(
        focusedDay,
        startingDayOfWeek,
      );

      final lastDayOfMonth = DateTime(focusedDay.year, focusedDay.month + 1, 0);

      final lastVisible = _lastVisibleDayOfMonth(
        lastDayOfMonth,
        startingDayOfWeek,
      );

      if (sixWeekMonthsEnforced) {
        return CalendarRange(
          start: firstVisible,
          end: firstVisible.add(const Duration(days: 41)),
        );
      }

      return CalendarRange(start: firstVisible, end: lastVisible);
  }
}

DateTime _lastVisibleDayOfMonth(
  DateTime lastDayOfMonth,
  StartingDayOfWeek startingDayOfWeek,
) {
  final lastWeekday = startingDayOfWeek == StartingDayOfWeek.sunday ? 7 : 6;

  int diff = lastWeekday - lastDayOfMonth.weekday;

  if (diff < 0) {
    diff += 7;
  }

  return DateTime(
    lastDayOfMonth.year,
    lastDayOfMonth.month,
    lastDayOfMonth.day,
  ).add(Duration(days: diff));
}

DateTime _firstDayOfWeek(DateTime day, StartingDayOfWeek startingDayOfWeek) {
  final firstWeekday = startingDayOfWeek == StartingDayOfWeek.sunday ? 1 : 7;

  int diff = day.weekday - firstWeekday;

  if (diff < 0) {
    diff += 7;
  }

  return DateTime(day.year, day.month, day.day).subtract(Duration(days: diff));
}

DateTime _firstVisibleDayOfMonth(
  DateTime focusedDay,
  StartingDayOfWeek startingDayOfWeek,
) {
  final firstOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);

  return _firstDayOfWeek(firstOfMonth, startingDayOfWeek);
}
