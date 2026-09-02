import 'package:intl/intl.dart';

extension DateExtension on DateTime {
  String toDayName() {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String toShortMonthName() {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  String toFormattedDate() {
    return '${toShortMonthName()} $day, $year - ${toDayName()}';
  }

  String toFormattedDateSecondary() {
    return '${toShortMonthName()} $day, $year';
  }
}

extension DateTimeFormat on DateTime {
  String formatTime() {
    DateTime dateTime;
    try {
      dateTime = add(Duration(hours: 7));
      return DateFormat('hh:mm a').format(dateTime);
    } catch (e) {
      return '-';
    }
  }

  String formatTimeDefaut() {
    try {
      return DateFormat('hh:mm a').format(this);
    } catch (e) {
      return '-';
    }
  }

  String formatTime24Hours() {
    DateTime dateTime;
    try {
      dateTime = add(Duration(hours: 7));
      return DateFormat('HH:mm').format(dateTime);
    } catch (e) {
      return '-';
    }
  }
}

extension DateTimeFormated on String {
  String formatDateTime() {
    if (this == '') return '';

    DateTime dateTime;
    try {
      // Fix timezone if needed
      var timeString = replaceFirst(RegExp(r'\+(\d):(\d)$'), r'+0$1:0$2');

      dateTime = DateTime.parse(timeString);
    } catch (e) {
      return '-';
    }

    // Convert to GMT+7
    dateTime = dateTime.add(Duration(hours: 7));

    final formatted = DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    return formatted;
  }
}
