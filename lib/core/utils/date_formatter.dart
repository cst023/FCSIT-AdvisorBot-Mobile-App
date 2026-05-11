import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatMessageTime(DateTime dt) {
    return DateFormat.jm().format(dt);
  }

  static String formatMessageDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    return DateFormat('EEE, d MMM').format(dt);
  }
}