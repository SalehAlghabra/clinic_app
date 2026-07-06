import 'package:intl/intl.dart';

class DateFormatters {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatTime(String time24) {
    try {
      // Laravel returns time like H:i:s or H:i.
      // E.g., '14:30:00' -> '02:30 PM'
      final timeParts = time24.split(':');
      if (timeParts.length >= 2) {
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final tempDate = DateTime(2026, 1, 1, hour, minute);
        return DateFormat('hh:mm a').format(tempDate);
      }
      return time24;
    } catch (_) {
      return time24;
    }
  }

  static String formatDateString(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateString;
    }
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }
}
