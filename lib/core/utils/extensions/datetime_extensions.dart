extension DateTimeExtensions on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  String get relativeLabel {
    final diff = DateTime.now().difference(this);
    if (diff.inDays == 0) return '오늘';
    if (diff.inDays == 1) return '어제';
    if (diff.inDays < 7)  return '${diff.inDays}일 전';
    return '$month/$day';
  }
}
