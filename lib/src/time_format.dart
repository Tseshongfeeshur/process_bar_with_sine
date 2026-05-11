/// 将 [Duration] 格式化为时间字符串。
///
/// 格式规则：
/// - 小于一小时：`mm:ss`（分钟不补零，秒数补零到两位）
/// - 大于等于一小时：`h:mm:ss`（小时不补零，分钟和秒数补零到两位）
String formatDuration(Duration time) {
  final minutes =
      time.inMinutes.remainder(Duration.minutesPerHour).toString();
  final seconds = time.inSeconds
      .remainder(Duration.secondsPerMinute)
      .toString()
      .padLeft(2, '0');
  return time.inHours > 0
      ? '${time.inHours}:${minutes.padLeft(2, "0")}:$seconds'
      : '$minutes:$seconds';
}
