import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'progress_bar_enums.dart';
import 'progress_bar_painter.dart';
import 'sine_wave_config.dart';
import 'thumb_drag_details.dart';
import 'time_format.dart';

/// 用于显示或设置正在播放的音频或视频内容位置的增强版进度条组件。
///
/// 相比原版 [ProgressBar]，增强支持：
/// - 可自定义滑块形状（[ThumbShape.circle] / [ThumbShape.line]）
/// - 可自定义进度条圆角半径（[barBorderRadius]）
/// - 已走部分的正弦波浪线动画（[sineWaveConfig]）
/// - 进度条与滑块之间的可配置间隙（[thumbBarGap] / [thumbGap]）
///
/// 所有新增参数均有默认值，仅使用原版参数时行为与之一致。
class ProgressBar extends StatefulWidget {
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
    this.lineThumbWidth = 4.0,
    this.lineThumbHeight = 14.0,
    this.lineThumbBorderRadius = 2.0,
    this.thumbBarGap = 0.0,
    this.thumbGap = 0.0,
    this.timeLabelLocation,
    this.timeLabelType,
    this.timeLabelTextStyle,
    this.timeLabelPadding = 0.0,
    this.sineWaveConfig,
  });

  /// 媒体的已播放时间。
  final Duration progress;

  /// 媒体的总时长。
  final Duration total;

  /// 媒体的当前缓冲内容。
  final Duration? buffered;

  /// 用户移动滑块后的回调。
  final ValueChanged<Duration>? onSeek;

  /// 用户开始移动滑块时的回调。
  final ThumbDragStartCallback? onDragStart;

  /// 用户正在移动滑块时的回调。
  final ThumbDragUpdateCallback? onDragUpdate;

  /// 用户完成滑块移动后的回调。
  final VoidCallback? onDragEnd;

  /// 进度条的垂直粗细。默认 5.0。
  final double barHeight;

  /// 播放开始前进度条的颜色。
  final Color? baseBarColor;

  /// 当前播放位置左侧进度条的颜色。
  final Color? progressBarColor;

  /// [progress] 到 [buffered] 之间进度条的颜色。
  final Color? bufferedBarColor;

  /// 进度条左端和右端的形状。默认 [BarCapShape.round]。
  final BarCapShape barCapShape;

  /// 进度条的圆角半径。非 `null` 时覆盖 [barCapShape] 行为，
  /// 每段两端均应用圆角。
  final double? barBorderRadius;

  /// 可移动滑块的半径。默认 10.0。
  final double thumbRadius;

  /// 滑块颜色。
  final Color? thumbColor;

  /// 滑块拖拽光晕颜色。
  final Color? thumbGlowColor;

  /// 滑块拖拽光晕半径。默认 30.0。
  final double thumbGlowRadius;

  /// 滑块是否可绘制在进度条边界之外。默认 `true`。
  final bool thumbCanPaintOutsideBar;

  /// 滑块的视觉形状。默认 [ThumbShape.circle]。
  final ThumbShape thumbShape;

  /// line 形状滑块的宽度。默认 4.0。
  final double lineThumbWidth;

  /// line 形状滑块的高度。默认 14.0。
  final double lineThumbHeight;

  /// line 形状滑块的圆角半径。默认 2.0。
  final double lineThumbBorderRadius;

  /// 进度条端点与滑块之间的视觉间隙。默认 0.0。
  final double thumbBarGap;

  /// 滑块周围的间隙，使进度条在滑块处断开为左右两段。默认 0.0。
  final double thumbGap;

  /// 时间标签相对于进度条的位置。
  final TimeLabelLocation? timeLabelLocation;

  /// 右侧时间标签的显示内容。
  final TimeLabelType? timeLabelType;

  /// 时间标签的 [TextStyle]。
  final TextStyle? timeLabelTextStyle;

  /// 时间标签与进度条之间的额外间距。默认 0.0。
  final double timeLabelPadding;

  /// 正弦波浪线动画配置。`null` 时渲染平直进度条。
  final SineWaveConfig? sineWaveConfig;

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar>
    with TickerProviderStateMixin {
  late _EagerHorizontalDragGestureRecognizer _drag;

  // 拖拽期间为手指对应的比例值；null 表示未在拖拽，此时由 widget.progress 驱动。
  double? _dragValue;

  AnimationController? _waveController;

  // 标签缓存
  TextPainter? _cachedLeftLabel;
  TextPainter? _cachedRightLabel;

  static const _defaultTimeLabelLocation = TimeLabelLocation.below;

  @override
  void initState() {
    super.initState();
    _drag = _EagerHorizontalDragGestureRecognizer()
      ..onStart = _onDragStart
      ..onUpdate = _onDragUpdate
      ..onEnd = _onDragEnd
      ..onCancel = _finishDrag;
    _initWaveController();
  }

  // 当前有效进度比例：拖拽时取手指位置，否则从 widget.progress 实时计算。
  double get _effectiveFraction =>
      _dragValue ?? _proportionOfTotal(widget.progress);

  @override
  void didUpdateWidget(covariant ProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.progress != widget.progress ||
        oldWidget.total != widget.total) {
      _clearLabelCache();
    }

    // 仅变更速度或创建/移除配置时才重建动画控制器，避免修改振幅等参数时动画跳归
    final newConfig = widget.sineWaveConfig;
    final oldConfig = oldWidget.sineWaveConfig;
    if (newConfig != oldConfig) {
      // 配置从无到有或从有到无
      if ((newConfig == null) != (oldConfig == null)) {
        _waveController?.dispose();
        _waveController = null;
        _initWaveController();
      } else if (newConfig != null && oldConfig != null) {
        // 两者均非 null：仅速度变化时调整 duration
        if (newConfig.speed != oldConfig.speed) {
          final newDuration = _waveDuration;
          if (_waveController?.duration != newDuration) {
            _waveController?.duration = newDuration;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _waveController?.dispose();
    _drag.dispose();
    super.dispose();
  }

  // ---- 正弦波动画 ----

  void _initWaveController() {
    if (widget.sineWaveConfig != null) {
      _waveController = AnimationController(
        vsync: this,
        duration: _waveDuration,
      )..repeat();
    }
  }

  Duration get _waveDuration {
    final speed = widget.sineWaveConfig?.speed ?? 1.0;
    return Duration(milliseconds: (2000 / speed).round());
  }

  // ---- 手势处理 ----

  void _onDragStart(DragStartDetails details) {
    _dragValue = _fractionFromLocalPosition(details.localPosition);
    widget.onDragStart?.call(ThumbDragDetails(
      timeStamp: _currentThumbDuration(),
      globalPosition: details.globalPosition,
      localPosition: details.localPosition,
    ));
    setState(() {});
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _dragValue = _fractionFromLocalPosition(details.localPosition);
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
    _dragValue = null;
    setState(() {});
  }

  Duration _currentThumbDuration() {
    final fraction = _effectiveFraction;
    return Duration(
        milliseconds: (fraction * widget.total.inMilliseconds).round());
  }

  double _fractionFromLocalPosition(Offset localPosition) {
    final dx = localPosition.dx;
    double leftInset = 0.0;
    double rightInset = 0.0;

    final loc = widget.timeLabelLocation ?? _defaultTimeLabelLocation;
    if (loc == TimeLabelLocation.sides) {
      final leftWidth = _cachedLeftLabel?.width ?? 0.0;
      final rightWidth = _cachedRightLabel?.width ?? 0.0;
      final sidePad = widget.thumbCanPaintOutsideBar
          ? widget.thumbRadius + 5.0
          : 5.0;
      leftInset = leftWidth + sidePad + widget.timeLabelPadding;
      rightInset = rightWidth + sidePad + widget.timeLabelPadding;
    }

    final capRadius = widget.barCapShape == BarCapShape.round
        ? widget.barHeight / 2
        : 0.0;
    final barStart = leftInset + capRadius + widget.thumbBarGap;
    final barEnd =
        context.size!.width - rightInset - capRadius - widget.thumbBarGap;
    final barWidth = barEnd - barStart;
    final position = (dx - barStart).clamp(0.0, barWidth);
    return barWidth > 0 ? position / barWidth : 0.0;
  }

  // ---- 标签缓存 ----

  void _ensureLabelsCached(TextStyle textStyle, TextScaler textScaler) {
    _cachedLeftLabel ??= _buildLeftLabel(textStyle, textScaler);
    _cachedRightLabel ??= _buildRightLabel(textStyle, textScaler);
  }

  void _clearLabelCache() {
    _cachedLeftLabel = null;
    _cachedRightLabel = null;
  }

  TextPainter _buildLeftLabel(TextStyle style, TextScaler textScaler) {
    return _layoutLabel(formatDuration(widget.progress), style, textScaler);
  }

  TextPainter _buildRightLabel(TextStyle style, TextScaler textScaler) {
    final labelType = widget.timeLabelType ?? TimeLabelType.totalTime;
    final text = labelType == TimeLabelType.remainingTime
        ? '-${formatDuration(widget.total - widget.progress)}'
        : formatDuration(widget.total);
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

  // ---- 尺寸计算 ----

  double _computeDesiredHeight(TextStyle textStyle, TextScaler textScaler) {
    _ensureLabelsCached(textStyle, textScaler);

    final barAreaHeight = _computeBarAreaHeight();
    final labelHeight = _cachedLeftLabel?.height ?? 0.0;
    final loc = widget.timeLabelLocation ?? _defaultTimeLabelLocation;

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
      base += config.effectiveAmplitude * 2;
    }
    return base;
  }

  double _proportionOfTotal(Duration duration) {
    if (widget.total.inMilliseconds == 0) return 0.0;
    return (duration.inMilliseconds / widget.total.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  // ---- 无障碍 ----

  static const double _semanticActionUnit = 0.05;

  void _semanticIncrease() {
    final newFraction =
        (_effectiveFraction + _semanticActionUnit).clamp(0.0, 1.0);
    _dragValue = newFraction;
    widget.onSeek?.call(_currentThumbDuration());
    _dragValue = null;
    setState(() {});
  }

  void _semanticDecrease() {
    final newFraction =
        (_effectiveFraction - _semanticActionUnit).clamp(0.0, 1.0);
    _dragValue = newFraction;
    widget.onSeek?.call(_currentThumbDuration());
    _dragValue = null;
    setState(() {});
  }

  // ---- 构建 ----

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final textStyle = widget.timeLabelTextStyle ?? theme.textTheme.bodyLarge;
    final textScaler = MediaQuery.textScalerOf(context);

    final baseBarColor =
        widget.baseBarColor ?? primaryColor.withValues(alpha: 0.24);
    final progressBarColor = widget.progressBarColor ?? primaryColor;
    final bufferedBarColor =
        widget.bufferedBarColor ?? primaryColor.withValues(alpha: 0.24);
    final thumbColor = widget.thumbColor ?? primaryColor;
    final thumbGlowColor = widget.thumbGlowColor ??
        thumbColor.withValues(alpha: 0.31);

    final buffered = widget.buffered ?? Duration.zero;

    final resolvedStyle = textStyle ?? const TextStyle();
    _ensureLabelsCached(resolvedStyle, textScaler);

    final desiredHeight = _computeDesiredHeight(resolvedStyle, textScaler);

    final fraction = _effectiveFraction;

    final painter = ProgressBarPainter(
      progressFraction: fraction,
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
      lineThumbWidth: widget.lineThumbWidth,
      lineThumbHeight: widget.lineThumbHeight,
      lineThumbBorderRadius: widget.lineThumbBorderRadius,
      thumbBarGap: widget.thumbBarGap,
      thumbGap: widget.thumbGap,
      isDragging: _dragValue != null,
      leftLabel: _cachedLeftLabel,
      rightLabel: _cachedRightLabel,
      timeLabelLocation:
          widget.timeLabelLocation ?? _defaultTimeLabelLocation,
      timeLabelPadding: widget.timeLabelPadding,
      sineWaveConfig: widget.sineWaveConfig,
      waveAnimation: _waveController,
      repaint: _waveController,
    );

    final increased = (fraction + _semanticActionUnit).clamp(0.0, 1.0);
    final decreased = (fraction - _semanticActionUnit).clamp(0.0, 1.0);

    return Semantics(
      label: '进度条',
      value: '${(fraction * 100).round()}%',
      increasedValue: '${(increased * 100).round()}%',
      decreasedValue: '${(decreased * 100).round()}%',
      onIncrease: _semanticIncrease,
      onDecrease: _semanticDecrease,
      child: Listener(
        onPointerDown: _handlePointerDown,
        child: SizedBox(
          width: double.infinity,
          height: desiredHeight,
          child: CustomPaint(painter: painter),
        ),
      ),
    );
  }

  void _handlePointerDown(PointerDownEvent event) {
    _drag.addPointer(event);
  }
}

/// 始终在收拾竞技场中获胜的手势识别器。
///
/// 防止在可滑动的标签页布局中使用时页面滑动替代滑块拖动。
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
