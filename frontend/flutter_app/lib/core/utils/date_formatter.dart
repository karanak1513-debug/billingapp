import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _timeOnly = DateFormat('hh:mm a');
  static final DateFormat _dateOnly = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFull = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _receiptDate = DateFormat('dd MMM yyyy, h:mm a');

  static String formatTime(DateTime dateTime) => _timeOnly.format(dateTime);
  static String formatDate(DateTime dateTime) => _dateOnly.format(dateTime);
  static String formatFull(DateTime dateTime) => _dateTimeFull.format(dateTime);
  static String formatReceipt(DateTime dateTime) =>
      _receiptDate.format(dateTime);

  /// Returns friendly relative dates like "Today, 4:15 PM" or "Yesterday, 3:20 PM"
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return 'Today, ${_timeOnly.format(dateTime)}';
    } else if (date == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${_timeOnly.format(dateTime)}';
    } else {
      return _dateTimeFull.format(dateTime);
    }
  }
}
