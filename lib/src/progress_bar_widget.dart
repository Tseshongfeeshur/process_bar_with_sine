import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'progress_bar_enums.dart';
import 'progress_bar_painter.dart';
import 'sine_wave_config.dart';
import 'thumb_drag_details.dart';
import 'time_format.dart';

/// 用于显示或设置正在播放的音频或视频内容位置的进度条组件。
///
/// 该组件本身不播放音频或视频内容，但可以与音频插件配合使用。
/// 它是 Flutter Slider 组件的更便捷替代方案。
///
/// 相比基础的进度条，该组件增强支持：
/// - 可自定义的滑块形状（圆形、方形、菱形、三角形、自定义绘制）
/// - 可自定义进度条圆角半径
/// - 已走部分的正弦波浪线动画（类似 Material Design 3 风格）
/// - 进度条与滑块之间的可配置间隙
class ProgressBar extends StatefulWidget {
  /// 必须设置当前音频或视频进度 [progress] 和 [total] 总时长。
  /// 可选设置 [buffered] 缓冲进度。
  ///
  /// 当用户将滑块拖到新位置时，可通过 [onSeek] 回调获得通知，
  /// 以便更新音视频播放器。
  const ProgressBar({
    super.key,
    required this.progress,
    required this.total,
    this.buffered,
    this.onSeek,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.barHeight = 5.0,
    this.baseBarColor,
    this.progressBarColor,
    this.bufferedBarColor,
    this.barCapShape = BarCapShape.round,
    this.barBorderRadius,
    this.thumbRadius = 10.0,
    this.thumbColor,
    this.thumbGlowColor,
    this.thumbGlowRadius = 30.0,
    this.thumbCanPaintOutsideBar = true,
    this.thumbShape = ThumbShape.circle,
    this.thumbCustomPainter,
    this.thumbBarGap = 0.0,
    this.thumbGap = 0.0,
    this.thumbWidget,
    this.timeLabelLocation,
    this.timeLabelType,
    this.timeLabelTextStyle,
    this.timeLabelPadding = 0.0,
    this.sineWaveConfig,
  });

  /// 媒体的已播放时间。
  ///
  /// 不应大于 [total] 总时长。
  final Duration progress;

  /// 媒体的总时长。
  final Duration total;

  /// 媒体的当前缓冲内容。
  ///
  /// 适用于流媒体内容。如果是本地文件，可以省略。
  final Duration? buffered;

  /// 用户移动滑块后的回调。
  ///
  /// 当用户在进度条上移动滑块后，此回调会触发。
  /// 在触摸事件结束之前不会触发。
  ///
  /// 你可以获取用户选择的播放位置并传递给媒体播放器。
  ///
  /// 如需在拖动过程中持续获取进度更新，请参见 [onDragUpdate]。
  final ValueChanged<Duration>? onSeek;

  /// 用户开始移动滑块时的回调。
  ///
  /// 拖动开始时只调用一次，提供 [ThumbDragDetails]。
  ///
  /// 当你需要在滑块上方添加时间标签和/或视频预览等内容，
  /// 并需要进行初始化时，此方法非常有用。
  ///
  /// 如果只想在拖动完成后跳转到新的播放位置，请使用 [onSeek]。
  final ThumbDragStartCallback? onDragStart;

  /// 用户正在移动滑块时的回调。
  ///
  /// 滑块位置变化时会反复调用，提供 [ThumbDragDetails]。
  /// 当前滑块时间不会超过 [total] 或小于零，因此你可以
  /// 使用此信息来限制拖动位置值。
  ///
  /// 当你需要更新滑块上方的时间标签和/或视频预览位置时，
  /// 此方法非常有用。
  ///
  /// 如果只想在拖动完成后跳转到新的播放位置，请使用 [onSeek]。
  final ThumbDragUpdateCallback? onDragUpdate;

  /// 用户完成滑块移动后的回调。
  ///
  /// 拖动结束时只调用一次。
  ///
  /// 当你需要在拖动结束时释放某些资源时，此方法非常有用。
  ///
  /// 此方法在 [onSeek] 之前直接调用。
  final VoidCallback? onDragEnd;

  /// 进度条的垂直粗细。
  final double barHeight;

  /// 播放开始前进度条的颜色。
  ///
  /// 默认为主题主色的透明版本（24% 不透明度）。
  final Color? baseBarColor;

  /// 当前播放位置左侧进度条的颜色。
  ///
  /// 默认为主题的主色。
  final Color? progressBarColor;

  /// [progress] 位置到 [buffered] 位置之间进度条的颜色。
  ///
  /// 默认为主题主色的透明版本，比 [baseBarColor] 略深。
  final Color? bufferedBarColor;

  /// 进度条左端和右端的形状。
  ///
  /// 此设置影响总时长的底色条、当前进度条和缓冲进度条。
  /// 默认为 [BarCapShape.round]。
  final BarCapShape barCapShape;

  /// 进度条的圆角半径。
  ///
  /// 当非 `null` 时，使用此半径绘制圆角矩形进度条，
  /// 覆盖 [barCapShape] 的行为。
  /// 当为 `null` 时，回退到 [barCapShape] 的行为（round 使用半高圆角）。
  final double? barBorderRadius;

  /// 可移动进度条滑块的圆形半径。
  final double thumbRadius;

  /// 可移动进度条滑块的圆形颜色。
  ///
  /// 默认为主题的主色。
  final Color? thumbColor;

  /// 可移动进度条滑块按下效果的颜色。
  ///
  /// 默认为 alpha 值为 80 的 [thumbColor]。
  final Color? thumbGlowColor;

  /// 可移动进度条滑块按下效果光晕的半径。
  ///
  /// 默认为 30.0。
  final double thumbGlowRadius;

  /// 滑块半径在开始处是否延伸到进度条之前，或在结束处延伸到进度条之后。
  ///
  /// 默认为 `true`，表示在没有侧边标签时，滑块将绘制在组件边界之外。
  /// 你可以用 `Padding` 包裹 [ProgressBar] 来为滑块留出额外空间。
  ///
  /// 设置为 `false` 时，滑块将被限制在进度条宽度内。
  /// 这有利于在播放开始和结束处将滑块与垂直标签对齐。
  final bool thumbCanPaintOutsideBar;

  /// 滑块的视觉形状。
  ///
  /// 默认为 [ThumbShape.circle]。
  final ThumbShape thumbShape;

  /// 当 [thumbShape] 为 [ThumbShape.custom] 时使用的自定义滑块绘制器。
  final ThumbShapePainter? thumbCustomPainter;

  /// 进度条端点与滑块之间的视觉间隙。
  ///
  /// 正值表示更大的间隙，负值表示滑块会与进度条端点重叠。
  /// 默认为 0.0。
  final double thumbBarGap;

  /// 滑块周围的间隙，使进度条在滑块处断开为左右两段。
  ///
  /// 设为大于 0 的值时，进度条会在滑块两侧留出间隙，视觉上被滑块
  /// 分成左右两段。每一段的两个端点都会应用圆角（如果设置了
  /// [barBorderRadius]）或线条端点样式（根据 [barCapShape]）。
  /// 默认为 0.0（不分段）。
  final double thumbGap;

  /// 自定义滑块组件。
  ///
  /// 当非 `null` 时，以此 Widget 替代内置的滑块绘制。
  /// Widget 的尺寸由外部决定（建议尺寸为 `thumbRadius * 2`）。
  /// 默认为 `null`（使用内置滑块绘制）。
  final Widget? thumbWidget;

  /// [progress] 和 [total] 时长文本标签的位置。
  ///
  /// 默认标签显示在进度条下方，但你也可以将它们放在上方、两侧或完全移除。
  final TimeLabelLocation? timeLabelLocation;

  /// 右侧时间标签的显示内容。
  ///
  /// 右侧时间标签可以显示总时长或负数形式的剩余时间。
  /// 默认为 [TimeLabelType.totalTime]。
  final TimeLabelType? timeLabelType;

  /// 时间标签使用的 [TextStyle]。
  ///
  /// 默认为 [TextTheme.bodyLarge]。
  final TextStyle? timeLabelTextStyle;

  /// 时间标签与进度条之间的额外间距。
  ///
  /// 默认为 0.0。正数使标签远离进度条，负数使标签更靠近进度条。
  final double timeLabelPadding;

  /// 正弦波浪线动画配置。
  ///
  /// 当非 `null` 时，进度条的已走部分将以正弦波浪线动画呈现。
  /// 当为 `null`（默认）时，渲染为平坦的进度条。
  final SineWaveConfig? sineWaveConfig;

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar>
    with TickerProviderStateMixin {
  late _EagerHorizontalDragGestureRecognizer _drag;
  late double _thumbValue;
  bool _userIsDraggingThumb = false;

  AnimationController? _waveController;

  // 标签缓存
  TextPainter? _cachedLeftLabel;
  TextPainter? _cachedRightLabel;

  // 平滑进度值，在动画帧间渐进逼近目标，减少播放时抖动
  final ValueNotifier<double> _smoothedFraction = ValueNotifier(0.0);

  // ---- 动画生命周期 ----

  @override
  void initState() {
    super.initState();
    _thumbValue = _proportionOfTotal(widget.progress);
    _smoothedFraction.value = _thumbValue;
    _drag = _EagerHorizontalDragGestureRecognizer()
      ..onStart = _onDragStart
      ..onUpdate = _onDragUpdate
      ..onEnd = _onDragEnd;
    _initWaveController();
  }

  @override
  void didUpdateWidget(covariant ProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 更新滑块位置（仅在非拖拽状态）
    if (!_userIsDraggingThumb) {
      _thumbValue = _proportionOfTotal(widget.progress);
    }

    // 进度或总时长变化时清除标签缓存，确保文字标签同步更新
    if (oldWidget.progress != widget.progress ||
        oldWidget.total != widget.total) {
      _clearLabelCache();
    }

    // 正弦波配置变化时重建动画
    if (oldWidget.sineWaveConfig != widget.sineWaveConfig) {
      _waveController?.dispose();
      _waveController = null;
      _initWaveController();
    } else if (oldWidget.sineWaveConfig?.speed !=
        widget.sineWaveConfig?.speed) {
      // 仅速度变化：更新 controller 周期
      final newDuration = _waveDuration;
      if (_waveController?.duration != newDuration) {
        _waveController?.duration = newDuration;
      }
    }
  }

  @override
  void dispose() {
    _waveController?.dispose();
    _smoothedFraction.dispose();
    _drag.dispose();
    super.dispose();
  }

  // ---- 正弦波动画初始化 ----

  void _initWaveController() {
    if (widget.sineWaveConfig != null) {
      _waveController = AnimationController(
        vsync: this,
        duration: _waveDuration,
      )
        ..addListener(_onWaveTick)
        ..repeat();
    }
  }

  void _onWaveTick() {
    if (_userIsDraggingThumb) return;
    final diff = _thumbValue - _smoothedFraction.value;
    if (diff.abs() < 0.0005) {
      _smoothedFraction.value = _thumbValue;
    } else {
      _smoothedFraction.value += diff * 0.35;
    }
  }

  Duration get _waveDuration {
    final speed = widget.sineWaveConfig?.speed ?? 1.0;
    return Duration(milliseconds: (2000 / speed).round());
  }

  // ---- 手势处理 ----

  void _onDragStart(DragStartDetails details) {
    _userIsDraggingThumb = true;
    _updateThumbFromLocalPosition(details.localPosition);
    widget.onDragStart?.call(ThumbDragDetails(
      timeStamp: _currentThumbDuration(),
      globalPosition: details.globalPosition,
      localPosition: details.localPosition,
    ));
    setState(() {});
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _updateThumbFromLocalPosition(details.localPosition);
    widget.onDragUpdate?.call(ThumbDragDetails(
      timeStamp: _currentThumbDuration(),
      globalPosition: details.globalPosition,
      localPosition: details.localPosition,
    ));
    setState(() {});
  }

  void _onDragEnd(DragEndDetails details) {
    widget.onDragEnd?.call();
    widget.onSeek?.call(_currentThumbDuration());
    _finishDrag();
  }

  void _finishDrag() {
    _userIsDraggingThumb = false;
    setState(() {});
  }

  Duration _currentThumbDuration() {
    final thumbMilliseconds = _thumbValue * widget.total.inMilliseconds;
    return Duration(milliseconds: thumbMilliseconds.round());
  }

  void _updateThumbFromLocalPosition(Offset localPosition) {
    final dx = localPosition.dx;
    double leftInset = 0.0;
    double rightInset = 0.0;

    if (widget.timeLabelLocation == TimeLabelLocation.sides ||
        (widget.timeLabelLocation == null &&
            defaultTimeLabelLocation == TimeLabelLocation.sides)) {
      final loc = widget.timeLabelLocation ?? defaultTimeLabelLocation;
      if (loc == TimeLabelLocation.sides) {
        final leftWidth = _cachedLeftLabel?.width ?? 0.0;
        final rightWidth = _cachedRightLabel?.width ?? 0.0;
        final sidePad = (widget.thumbCanPaintOutsideBar)
            ? widget.thumbRadius + 5.0
            : 5.0;
        leftInset = leftWidth + sidePad + widget.timeLabelPadding;
        rightInset = rightWidth + sidePad + widget.timeLabelPadding;
      }
    }

    final capRadius =
        widget.barCapShape == BarCapShape.round ? widget.barHeight / 2 : 0.0;
    final barStart = leftInset + capRadius + widget.thumbBarGap;
    final barEnd = size.width - rightInset - capRadius - widget.thumbBarGap;
    final barWidth = barEnd - barStart;
    final position = (dx - barStart).clamp(0.0, barWidth);
    _thumbValue = barWidth > 0 ? position / barWidth : 0.0;
  }

  // ---- 标签缓存 ----

  void _ensureLabelsCached(TextStyle textStyle, TextScaler textScaler) {
    _cachedLeftLabel ??= _buildLeftLabel(textStyle, textScaler);
    _cachedRightLabel ??=
        _buildRightLabel(textStyle, textScaler, widget.total, widget.progress);
  }

  void _clearLabelCache() {
    _cachedLeftLabel = null;
    _cachedRightLabel = null;
  }

  TextPainter _buildLeftLabel(TextStyle style, TextScaler textScaler) {
    final text = formatDuration(widget.progress);
    return _layoutLabel(text, style, textScaler);
  }

  TextPainter _buildRightLabel(
      TextStyle style, TextScaler textScaler, Duration total, Duration progress) {
    final labelType = widget.timeLabelType ?? TimeLabelType.totalTime;
    final text = labelType == TimeLabelType.remainingTime
        ? '-${formatDuration(total - progress)}'
        : formatDuration(total);
    return _layoutLabel(text, style, textScaler);
  }

  TextPainter _layoutLabel(
      String text, TextStyle style, TextScaler textScaler) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: textScaler,
    );
    tp.layout(minWidth: 0, maxWidth: double.infinity);
    return tp;
  }

  static const TimeLabelLocation defaultTimeLabelLocation =
      TimeLabelLocation.below;

  // ---- 尺寸计算 ----

  Size get size {
    // 从 context 获取尺寸
    final renderObject = context.findRenderObject();
    if (renderObject is RenderBox) {
      return renderObject.size;
    }
    return Size.zero;
  }

  double _computeDesiredHeight(TextStyle textStyle, TextScaler textScaler) {
    // 确保标签已缓存
    _ensureLabelsCached(textStyle, textScaler);

    final barAreaHeight = _computeBarAreaHeight();
    final labelHeight = _cachedLeftLabel?.height ?? 0.0;
    final loc = widget.timeLabelLocation ?? defaultTimeLabelLocation;

    switch (loc) {
      case TimeLabelLocation.above:
      case TimeLabelLocation.below:
        return barAreaHeight + labelHeight + widget.timeLabelPadding;
      case TimeLabelLocation.sides:
        return max(barAreaHeight, labelHeight);
      case TimeLabelLocation.none:
        return barAreaHeight;
    }
  }

  double _computeBarAreaHeight() {
    double base = max(2 * widget.thumbRadius, widget.barHeight);
    final config = widget.sineWaveConfig;
    if (config != null && !config.clampToBarBounds) {
      base += config.amplitude * 2;
    }
    return base;
  }

  // ---- 进度计算 ----

  double _proportionOfTotal(Duration duration) {
    if (widget.total.inMilliseconds == 0) {
      return 0.0;
    }
    return duration.inMilliseconds / widget.total.inMilliseconds;
  }

  // ---- 无障碍操作 ----

  static const double _semanticActionUnit = 0.05;

  void _semanticIncrease() {
    final newValue = (_thumbValue + _semanticActionUnit).clamp(0.0, 1.0);
    _thumbValue = newValue;
    widget.onSeek?.call(_currentThumbDuration());
    setState(() {});
  }

  void _semanticDecrease() {
    final newValue = (_thumbValue - _semanticActionUnit).clamp(0.0, 1.0);
    _thumbValue = newValue;
    widget.onSeek?.call(_currentThumbDuration());
    setState(() {});
  }

  // ---- 构建 ----

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final textStyle =
        widget.timeLabelTextStyle ?? theme.textTheme.bodyLarge;
    final textScaler = MediaQuery.textScalerOf(context);

    // 解析颜色默认值
    final baseBarColor =
        widget.baseBarColor ?? primaryColor.withValues(alpha: 0.24);
    final progressBarColor = widget.progressBarColor ?? primaryColor;
    final bufferedBarColor =
        widget.bufferedBarColor ?? primaryColor.withValues(alpha: 0.24);
    final thumbColor = widget.thumbColor ?? primaryColor;
    final thumbGlowColor = widget.thumbGlowColor ??
        thumbColor.withValues(alpha: 80 / 255);

    final buffered = widget.buffered ?? Duration.zero;

    // 缓存标签
    final resolvedStyle = textStyle ?? const TextStyle();
    _ensureLabelsCached(resolvedStyle, textScaler);

    final desiredHeight = _computeDesiredHeight(resolvedStyle, textScaler);

    final painter = ProgressBarPainter(
      progressFraction: _thumbValue,
      smoothedFraction: _smoothedFraction,
      bufferedFraction: _proportionOfTotal(buffered),
      barHeight: widget.barHeight,
      baseBarColor: baseBarColor,
      progressBarColor: progressBarColor,
      bufferedBarColor: bufferedBarColor,
      barCapShape: widget.barCapShape,
      barBorderRadius: widget.barBorderRadius,
      thumbRadius: widget.thumbRadius,
      thumbColor: thumbColor,
      thumbGlowColor: thumbGlowColor,
      thumbGlowRadius: widget.thumbGlowRadius,
      thumbCanPaintOutsideBar: widget.thumbCanPaintOutsideBar,
      thumbShape: widget.thumbShape,
      thumbCustomPainter: widget.thumbCustomPainter,
      thumbBarGap: widget.thumbBarGap,
      thumbGap: widget.thumbGap,
      isDragging: _userIsDraggingThumb,
      showDefaultThumb: widget.thumbWidget == null,
      leftLabel: _cachedLeftLabel,
      rightLabel: _cachedRightLabel,
      timeLabelLocation: widget.timeLabelLocation ?? defaultTimeLabelLocation,
      timeLabelPadding: widget.timeLabelPadding,
      sineWaveConfig: widget.sineWaveConfig,
      waveAnimation: _waveController,
      repaint: _waveController,
    );

    final increased = (_thumbValue + _semanticActionUnit).clamp(0.0, 1.0);
    final decreased = (_thumbValue - _semanticActionUnit).clamp(0.0, 1.0);

    final coreChild = SizedBox(
      width: double.infinity,
      height: desiredHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tw = widget.thumbWidget;
          if (tw != null) {
            final thumbOffset = _computeThumbOffset(
              constraints.maxWidth,
              desiredHeight,
            );
            return Stack(
              children: [
                CustomPaint(painter: painter),
                Positioned(
                  left: thumbOffset.dx - widget.thumbRadius,
                  top: thumbOffset.dy - widget.thumbRadius,
                  child: tw,
                ),
              ],
            );
          }
          return CustomPaint(painter: painter);
        },
      ),
    );

    return Semantics(
      label: '进度条',
      value: '${(_thumbValue * 100).round()}%',
      increasedValue: '${(increased * 100).round()}%',
      decreasedValue: '${(decreased * 100).round()}%',
      onIncrease: _semanticIncrease,
      onDecrease: _semanticDecrease,
      child: Listener(
        onPointerDown: _handlePointerDown,
        child: coreChild,
      ),
    );
  }

  Offset _computeThumbOffset(double totalWidth, double totalHeight) {
    final capRadius =
        widget.barCapShape == BarCapShape.round ? widget.barHeight / 2 : 0.0;
    final inset = capRadius + widget.thumbBarGap;

    double barLeft = 0.0;
    double barTop = 0.0;
    double barWidth = totalWidth;

    final loc = widget.timeLabelLocation ?? defaultTimeLabelLocation;
    final labelHeight = _cachedLeftLabel?.height ?? 0.0;

    switch (loc) {
      case TimeLabelLocation.above:
        barTop = labelHeight + widget.timeLabelPadding;
        break;
      case TimeLabelLocation.below:
        barTop = 0.0;
        break;
      case TimeLabelLocation.sides:
        final leftLabelWidth = _cachedLeftLabel?.width ?? 0.0;
        final rightLabelWidth = _cachedRightLabel?.width ?? 0.0;
        final sidePad = widget.thumbCanPaintOutsideBar
            ? widget.thumbRadius + 5.0
            : 5.0;
        barLeft = leftLabelWidth + sidePad + widget.timeLabelPadding;
        barWidth = totalWidth -
            2 * sidePad -
            2 * widget.timeLabelPadding -
            leftLabelWidth -
            rightLabelWidth;
        barTop = totalHeight / 2 - _computeBarAreaHeight() / 2;
        break;
      case TimeLabelLocation.none:
        barTop = totalHeight / 2 - _computeBarAreaHeight() / 2;
        break;
    }

    final barAreaHeight = _computeBarAreaHeight();
    final swConfig = widget.sineWaveConfig;
    final waveOverflow = (swConfig != null && !swConfig.clampToBarBounds)
        ? swConfig.amplitude
        : 0.0;

    final adjustedWidth = barWidth - inset * 2;
    final thumbDx = barLeft + inset + adjustedWidth * _smoothedFraction.value;
    final thumbDy = barTop + waveOverflow + barAreaHeight / 2;

    return Offset(thumbDx, thumbDy);
  }

  void _handlePointerDown(PointerDownEvent event) {
    _drag.addPointer(event);
  }
}

/// 始终在收拾竞技场中获胜的手势识别器。
///
/// 如果不这样做，在可滑动的标签页布局中使用此组件时，
/// 尝试移动滑块会导致页面滑动而非拖动。
class _EagerHorizontalDragGestureRecognizer
    extends HorizontalDragGestureRecognizer {
  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }

  @override
  String get debugDescription => '_EagerHorizontalDragGestureRecognizer';
}
