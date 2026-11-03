/// Groups and labels timestamps the way the history pages display them.
class HistoryTimeFormat {
  HistoryTimeFormat._();

  static String dayLabel(DateTime time, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final day = _dateOnly(time);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Hôm qua';
    if (diff < 7) return '$diff ngày trước';
    return '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}/${day.year}';
  }

  static String clock(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  static String timeAgo(DateTime time, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(1, 59)} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  static DateTime _dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);
}
