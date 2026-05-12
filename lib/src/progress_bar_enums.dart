/// 进度条左端和右端的形状。
enum BarCapShape {
  /// 左端和右端是圆形的。
  round,

  /// 左端和右端是方形的。
  square,
}

/// 时间标签相对于进度条的位置。
enum TimeLabelLocation {
  /// 时间标签显示在进度条上方。
  above,

  /// 时间标签显示在进度条下方。
  below,

  /// 时间标签显示在进度条两侧。
  sides,

  /// 不显示时间标签。
  none,
}

/// 右侧时间标签的显示类型。
enum TimeLabelType {
  /// 右侧标签显示总时长。
  totalTime,

  /// 右侧标签显示剩余时间（负数形式）。
  remainingTime,
}

/// 可拖拽滑块的视觉形状。
enum ThumbShape {
  /// 实心圆形，半径为 [thumbRadius]。
  circle,

  /// 纵向圆角矩形，宽度为 4、高度为 14。
  line,
}
