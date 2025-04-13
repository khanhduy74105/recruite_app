class TimelineUtils {
  static String formatDate(String? date, String Function(String)? formatter) {
    if (date == null || date.isEmpty) return 'Present';
    final parsedDate = DateTime.tryParse(date);
    if (parsedDate == null) return date;
    return formatter != null ? formatter(date) : date.split('T').first;
  }

  static DateTime? parseDate(String? date) {
    return date != null && date.isNotEmpty ? DateTime.tryParse(date) : null;
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}