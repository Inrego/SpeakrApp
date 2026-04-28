import 'package:intl/intl.dart';

/// "Today" / "Yesterday" / weekday / "Mon D" — matches `fmtDate`
/// in direction-a-2.jsx (lines 5-13). Uses the device timezone.
String formatRelativeDay(DateTime when, {DateTime? today}) {
  final now = today ?? DateTime.now();
  final tDay = DateTime(now.year, now.month, now.day);
  final wDay = DateTime(when.year, when.month, when.day);
  final diff = tDay.difference(wDay).inDays;
  if (diff <= 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff < 7) return DateFormat.EEEE().format(when);
  return DateFormat.MMMd().format(when);
}

/// "9:41 AM"-style timestamp.
String formatHourMinute(DateTime when) =>
    DateFormat.jm().format(when.toLocal());

/// "47:12" / "01:18" duration. Accepts seconds.
String formatDuration(double seconds) {
  if (seconds.isNaN || seconds.isNegative) return '00:00';
  final total = seconds.floor();
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  String two(int n) => n.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}

String formatBytes(int? bytes) {
  if (bytes == null || bytes <= 0) return '—';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var v = bytes.toDouble();
  var i = 0;
  while (v >= 1024 && i < units.length - 1) {
    v /= 1024;
    i++;
  }
  return v >= 10 ? '${v.toStringAsFixed(0)} ${units[i]}' : '${v.toStringAsFixed(1)} ${units[i]}';
}
