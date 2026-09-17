class Formatters {
  Formatters._();

  static String formatDuration(Duration duration, {bool negative = false}) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final prefix = negative ? '-' : '';
    return '$prefix$minutes:$seconds';
  }

  static String formatSeconds(int totalSeconds, {bool negative = false}) {
    final duration = Duration(seconds: totalSeconds);
    return formatDuration(duration, negative: negative);
  }
}
