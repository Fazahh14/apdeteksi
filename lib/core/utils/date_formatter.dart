class DateFormatter {
  DateFormatter._();

  static const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  static const monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt',
    'Nov', 'Des'
  ];
  static const monthsFull = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli',
    'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  static String rowDate(DateTime d) =>
      '${days[d.weekday - 1]}, ${d.day} ${monthsShort[d.month - 1]}';

  static String groupTitle(DateTime d, [DateTime? now]) {
    final today = now ?? DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final label = isSameDay(d, today)
        ? 'Hari ini'
        : isSameDay(d, yesterday)
            ? 'Kemarin'
            : '${days[d.weekday - 1]}';
    return '$label • ${d.day} ${monthsShort[d.month - 1]}';
  }

  static String rangeText(DateTime start, DateTime end) {
    if (isSameDay(start, end)) {
      return '${end.day} ${monthsFull[end.month - 1]} ${end.year}';
    }
    if (start.month == end.month) {
      return '${start.day} – ${end.day} ${monthsFull[end.month - 1]} ${end.year}';
    }
    return '${start.day} ${monthsFull[start.month - 1]} – '
        '${end.day} ${monthsFull[end.month - 1]} ${end.year}';
  }
}
