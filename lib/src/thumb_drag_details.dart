import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

/// 滑块拖拽事件的详细信息。
class ThumbDragDetails {
  const ThumbDragDetails({
    this.timeStamp = Duration.zero,
    this.globalPosition = Offset.zero,
    this.localPosition = Offset.zero,
  });

  /// 滑块在进度条上的时间位置。
  final Duration timeStamp;

  /// 拖拽事件的全局坐标。
  final Offset globalPosition;

  /// 拖拽事件相对于进度条的本地坐标。
  final Offset localPosition;

  @override
  String toString() => '${objectRuntimeType(this, 'ThumbDragDetails')}('
      'time: $timeStamp, '
      'global: $globalPosition, '
      'local: $localPosition)';
}

/// 滑块开始拖拽时的回调签名。
typedef ThumbDragStartCallback = void Function(ThumbDragDetails details);

/// 滑块拖拽中位置变化时的回调签名。
typedef ThumbDragUpdateCallback = void Function(ThumbDragDetails details);
