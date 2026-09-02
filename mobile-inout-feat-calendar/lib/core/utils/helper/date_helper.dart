import 'package:intl/intl.dart';
import 'package:mobile_in_out/core/utils/helper/log_helper.dart';

class DateHelper {
  static String? convertStringToDateTime(DateTime date) {
    try {
      var format = DateFormat("MMMM dd,yyyy HH:mm");
      return format.format(date);
    } catch (e) {
      LogHelper.logDebug('Error occurred while trying to parse the date: $e');
      return null;
    }
  }

  static String? convertStringToDateTimeFormat(
    DateTime date,
    String formatString,
  ) {
    try {
      var format = DateFormat(formatString);
      return format.format(date);
    } catch (e) {
      return null;
    }
  }

  static String? convertDateStringToFormat(
    String? dateString,
    String formatString,
  ) {
    if (dateString == null || dateString.isEmpty) return null;

    final parsedDate = DateTime.tryParse(dateString);
    if (parsedDate == null) return null;

    try {
      var format = DateFormat(formatString);
      return format.format(parsedDate);
    } catch (e) {
      return null;
    }
  }

  // get time zone
  static String getTimeZone() {
    return DateTime.now().timeZoneName;
  }

  // Format date get Time HH:mm
  static String getFormattedTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String stringToTimeAgo(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '-';
    }

    try {
      final DateTime now = DateTime.now().toUtc();
      final DateTime date = DateTime.parse(dateString).toUtc();

      final Duration difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else if (difference.inDays == 1) {
        return 'yesterday';
      } else {
        return DateFormat('dd/MM/yyyy').format(date.toLocal());
      }
    } catch (e) {
      return '-';
    }
  }

  static Duration getDiffTime(String time, AbsenceType type) {
    final now = DateTime.now();

    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    var dateTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (type == AbsenceType.checkIn) {
      return now.difference(dateTime);
    } else {
      return dateTime.difference(now);
    }
  }

  /// Combines [dateText] (yyyy-MM-dd) and [timeText] into an ISO8601 string
  /// kept in local time (no timezone conversion / offset suffix),
  /// e.g. "2026-08-23T10:00:00", matching how the app stores & displays dates.
  static String? toIso8601(String dateText, String timeText) {
    if (dateText.isEmpty || timeText.isEmpty) return null;

    // Normalize locale-specific separators (e.g. "14.30" in id locale)
    final normalizedTime = timeText.trim().replaceAll('.', ':');

    int hour;
    int minute;

    final isAmPm = RegExp(
      r'(AM|PM)',
      caseSensitive: false,
    ).hasMatch(normalizedTime);
    if (isAmPm) {
      final cleaned = normalizedTime.replaceAll(RegExp(r'\s'), '');
      final isPm = cleaned.toUpperCase().endsWith('PM');
      final digits = cleaned.replaceAll(RegExp(r'[AaPpMm]'), '');
      final parts = digits.split(':');
      if (parts.length < 2) return null;
      hour = int.tryParse(parts[0]) ?? 0;
      minute = int.tryParse(parts[1]) ?? 0;
      if (isPm && hour != 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;
    } else {
      final timeParts = normalizedTime.split(':');
      if (timeParts.length < 2) return null;
      hour = int.tryParse(timeParts[0]) ?? 0;
      minute = int.tryParse(timeParts[1]) ?? 0;
    }

    final combined = '${dateText}T${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
    final parsed = DateTime.tryParse(combined);
    if (parsed == null) return null;

    return parsed.toIso8601String();
  }
}

enum AbsenceType { checkIn, checkOut }
