import 'dart:math';

import 'package:flutter/material.dart';

import 'progress_bar_enums.dart';
import 'sine_wave_config.dart';

/// 进度条组件的自定义绘制器。
///
/// 负责绘制进度条的所有视觉元素：底色条、缓冲条、已走进度条（可选正弦波浪）、
/// 滑块及其光晕、时间标签。
class ProgressBarPainter extends CustomPainter {
  ProgressBarPainter({
    required this.progressFraction,
    required this.bufferedFraction,
    required this.barHeight,
    required this.baseBarColor,
    required this.progressBarColor,
    required this.bufferedBarColor,
    required this.barCapShape,
    this.barBorderRadius,
    required this.thumbRadius,
    required this.thumbColor,
    required this.thumbGlowColor,
    required this.thumbGlowRadius,
    required this.thumbCanPaintOutsideBar,
    required this.thumbShape,
    this.lineThumbWidth = 4.0,
    this.lineThumbHeight = 14.0,
    this.lineThumbBorderRadius = 2.0,
    required this.thumbBarGap,
    required this.thumbGap,
    required this.isDragging,
    this.leftLabel,
    this.rightLabel,
    required this.timeLabelLocation,
    required this.timeLabelPadding,
    this.sineWaveConfig,
    this.waveAnimation,
    super.repaint,
  });

  /// 当前进度在总时长中的比例 (0.0 ~ 1.0)。
  final double progressFraction;

  /// 缓冲进度在总时长中的比例 (0.0 ~ 1.0)。
  final double bufferedFraction;

  /// 进度条的垂直粗细。
  final double barHeight;

  /// 未播放部分的颜色。
  final Color baseBarColor;

  /// 已播放部分的颜色。
  final Color progressBarColor;

  /// 缓冲部分的颜色。
  final Color bufferedBarColor;

  /// 进度条端点的形状。
  final BarCapShape barCapShape;

  /// 进度条的自定义圆角半径。非 `null` 时覆盖 [barCapShape] 行为。
  final double? barBorderRadius;

  /// 滑块半径。
  final double thumbRadius;

  /// 滑块颜色。
  final Color thumbColor;

  /// 滑块拖拽时的光晕颜色。
  final Color thumbGlowColor;

  /// 滑块拖拽时的光晕半径。
  final double thumbGlowRadius;

  /// 滑块是否可以绘制在进度条边界之外。
  final bool thumbCanPaintOutsideBar;

  /// 滑块形状。
  final ThumbShape thumbShape;

  /// line 形状滑块的宽度。默认 4.0。
  final double lineThumbWidth;

  /// line 形状滑块的高度。默认 14.0。
  final double lineThumbHeight;

  /// line 形状滑块的圆角半径。默认 2.0。
  final double lineThumbBorderRadius;

  /// 进度条端点与滑块之间的视觉间隙。
  final double thumbBarGap;

  /// 滑块周围的间隙，使进度条在滑块处断开为左右两段。
  final double thumbGap;

  /// 用户当前是否正在拖拽滑块。
  final bool isDragging;

  /// 左侧时间标签（已布局好的 [TextPainter]）。
  final TextPainter? leftLabel;

  /// 右侧时间标签（已布局好的 [TextPainter]）。
  final TextPainter? rightLabel;

  /// 时间标签相对于进度条的位置。
  final TimeLabelLocation timeLabelLocation;

  /// 时间标签与进度条之间的额外间距。
  final double timeLabelPadding;

  /// 正弦波浪配置。为 `null` 时不渲染波浪。
  final SineWaveConfig? sineWaveConfig;

  /// 波浪动画驱动器，在 [paint] 中读取当前值以确保动画帧间相位更新。
  final Animation<double>? waveAnimation;

  double get _defaultSidePadding {
    const minPadding = 5.0;
    return thumbCanPaintOutsideBar ? thumbRadius + minPadding : minPadding;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    switch (timeLabelLocation) {
      case TimeLabelLocation.above:
      case TimeLabelLocation.below:
        _drawWithLabelsAboveOrBelow(canvas, size);
      case TimeLabelLocation.sides:
        _drawWithLabelsOnSides(canvas, size);
      case TimeLabelLocation.none:
        _drawWithoutLabels(canvas, size);
    }

    canvas.restore();
  }

  void _drawWithLabelsAboveOrBelow(Canvas canvas, Size size) {
    final isLabelBelow = timeLabelLocation == TimeLabelLocation.below;
    final barAreaHeight = _computeBarAreaHeight();
    final labelHeight = leftLabel?.height ?? 0.0;

    final labelY = isLabelBelow ? barAreaHeight + timeLabelPadding : 0.0;
    leftLabel?.paint(canvas, Offset(0, labelY));
    final rl = rightLabel;
    if (rl != null) {
      rl.paint(canvas, Offset(size.width - rl.width, labelY));
    }

    final barY = isLabelBelow ? 0.0 : labelHeight + timeLabelPadding;
    canvas.save();
    canvas.translate(0, barY);
    _drawBarContent(canvas, Size(size.width, barAreaHeight));
    canvas.restore();
  }

  void _drawWithLabelsOnSides(Canvas canvas, Size size) {
    final leftLabel = this.leftLabel;
    final rightLabel = this.rightLabel;

    final verticalOffset = size.height / 2 - (leftLabel?.height ?? 0) / 2;
    leftLabel?.paint(canvas, Offset(0, verticalOffset));
    final rl2 = rightLabel;
    if (rl2 != null) {
      rl2.paint(canvas, Offset(size.width - rl2.width, verticalOffset));
    }

    final leftLabelWidth = leftLabel?.width ?? 0.0;
    final rightLabelWidth = rightLabel?.width ?? 0.0;
    final barWidth = size.width -
        2 * _defaultSidePadding -
        2 * timeLabelPadding -
        leftLabelWidth -
        rightLabelWidth;
    final barAreaHeight = _computeBarAreaHeight();
    final barDx = leftLabelWidth + _defaultSidePadding + timeLabelPadding;
    final barDy = size.height / 2 - barAreaHeight / 2;

    canvas.save();
    canvas.translate(barDx, barDy);
    _drawBarContent(canvas, Size(barWidth, barAreaHeight));
    canvas.restore();
  }

  void _drawWithoutLabels(Canvas canvas, Size size) {
    final barAreaHeight = _computeBarAreaHeight();
    final barDy = size.height / 2 - barAreaHeight / 2;
    canvas.save();
    canvas.translate(0, barDy);
    _drawBarContent(canvas, Size(size.width, barAreaHeight));
    canvas.restore();
  }

  double _computeBarAreaHeight() {
    double base = max(2 * thumbRadius, barHeight);
    final config = sineWaveConfig;
    if (config != null && !config.clampToBarBounds) {
      base += config.effectiveAmplitude * 2;
    }
    return base;
  }

  /// 在给定的区域内绘制进度条主体（底色、缓冲、已走部分、滑块）。
  void _drawBarContent(Canvas canvas, Size barAreaSize) {
    final config = sineWaveConfig;
    final waveOverflow = (config != null && !config.clampToBarBounds)
        ? config.effectiveAmplitude
        : 0.0;
    final barY = waveOverflow;
    final barPaintAreaHeight = barAreaSize.height - waveOverflow;

    canvas.save();
    canvas.translate(0, barY);

    final barPaintSize = Size(barAreaSize.width, barPaintAreaHeight);
    final capRadius =
        barCapShape == BarCapShape.round ? barHeight / 2 : 0.0;
    final inset = capRadius + thumbBarGap;
    final adjustedWidth = barPaintSize.width - inset * 2;

    if (config != null && config.amplitude > 0 && progressFraction > 0) {
      // 波浪模式：已走部分以正弦曲线绘制，后方以平直底色条和缓冲条填充
      final wavePhase = (waveAnimation?.value ?? 0.0) * 2 * pi;

      double waveEndX;
      double remainingStartX;
      if (thumbGap > 0 && progressFraction < 1.0) {
        final thumbCenterX = inset + adjustedWidth * progressFraction;
        waveEndX =
            (thumbCenterX - thumbRadius - thumbGap).clamp(inset, barPaintSize.width);
        remainingStartX = thumbCenterX + thumbRadius + thumbGap;
      } else {
        waveEndX = inset + adjustedWidth * progressFraction;
        remainingStartX = waveEndX;
      }

      _drawProgressBarWithWave(canvas, barPaintSize, config, wavePhase, waveEndX);

      // 绘制已走部分后方的剩余底色条和缓冲条
      if (progressFraction < 1.0) {
        final halfH = barHeight / 2;
        canvas.save();
        canvas.clipRect(Rect.fromLTRB(
          remainingStartX,
          barPaintAreaHeight / 2 - halfH,
          barPaintSize.width,
          barPaintAreaHeight / 2 + halfH,
        ));
        _drawBaseBar(canvas, barPaintSize);
        _drawBufferedBar(canvas, barPaintSize);
        canvas.restore();
      }
    } else {
      _drawBaseBar(canvas, barPaintSize);
      _drawBufferedBar(canvas, barPaintSize);
      _drawProgressBar(canvas, barPaintSize);
    }

    _drawThumb(canvas, barPaintSize);
    canvas.restore();
  }

  void _drawBaseBar(Canvas canvas, Size availableSize) {
    _drawBarSegment(
      canvas: canvas,
      availableSize: availableSize,
      widthProportion: 1.0,
      color: baseBarColor,
    );
  }

  void _drawBufferedBar(Canvas canvas, Size availableSize) {
    _drawBarSegment(
      canvas: canvas,
      availableSize: availableSize,
      widthProportion: bufferedFraction,
      color: bufferedBarColor,
    );
  }

  void _drawProgressBar(Canvas canvas, Size availableSize) {
    _drawBarSegment(
      canvas: canvas,
      availableSize: availableSize,
      widthProportion: progressFraction,
      color: progressBarColor,
    );
  }

  /// 绘制一个进度条线段。当 [thumbGap] > 0 时，在滑块位置断开为左右两段，
  /// 每段两端均应用圆角（若 [barBorderRadius] 非 null）或端点样式。
  void _drawBarSegment({
    required Canvas canvas,
    required Size availableSize,
    required double widthProportion,
    required Color color,
  }) {
    if (widthProportion <= 0.0) return;

    final capRadius = barCapShape == BarCapShape.round ? barHeight / 2 : 0.0;
    final inset = capRadius + thumbBarGap;
    final adjustedWidth = availableSize.width - inset * 2;
    if (adjustedWidth <= 0) return;

    final fullEnd = inset + adjustedWidth * widthProportion;

    if (thumbGap > 0 && progressFraction > 0 && progressFraction < 1.0) {
      final thumbCenterX = inset + adjustedWidth * progressFraction;
      final gapStart = thumbCenterX - thumbRadius - thumbGap;
      final gapEnd = thumbCenterX + thumbRadius + thumbGap;

      // 左侧段
      final leftEnd = fullEnd < gapStart ? fullEnd : gapStart;
      if (leftEnd > inset) {
        _drawBarLine(canvas, availableSize, inset, leftEnd, color);
      }

      // 右侧段
      if (fullEnd > gapEnd) {
        final rightStart = gapEnd > inset ? gapEnd : inset;
        _drawBarLine(canvas, availableSize, rightStart, fullEnd, color);
      }
    } else {
      _drawBarLine(canvas, availableSize, inset, fullEnd, color);
    }
  }

  /// 绘制从 [fromX] 到 [toX] 的一段进度条，支持圆角矩形或线条模式。
  void _drawBarLine(
      Canvas canvas, Size availableSize, double fromX, double toX, Color color) {
    if (toX <= fromX) return;

    if (barBorderRadius != null && barBorderRadius! > 0) {
      final radius = barBorderRadius!;
      final rect = RRect.fromLTRBR(
        fromX,
        availableSize.height / 2 - barHeight / 2,
        toX,
        availableSize.height / 2 + barHeight / 2,
        Radius.circular(radius),
      );
      canvas.drawRRect(rect, Paint()..color = color);
      return;
    }

    final strokeCap = barCapShape == BarCapShape.round
        ? StrokeCap.round
        : StrokeCap.square;
    final paint = Paint()
      ..color = color
      ..strokeCap = strokeCap
      ..strokeWidth = barHeight
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(fromX, availableSize.height / 2),
      Offset(toX, availableSize.height / 2),
      paint,
    );
  }

  /// 绘制带正弦波浪的进度条已走部分。
  void _drawProgressBarWithWave(
      Canvas canvas, Size availableSize, SineWaveConfig config,
      double wavePhase, double endX) {
    if (progressFraction <= 0) return;

    final capRadius =
        barCapShape == BarCapShape.round ? barHeight / 2 : 0.0;
    final inset = capRadius + thumbBarGap;
    final adjustedWidth = availableSize.width - inset * 2;
    if (adjustedWidth <= 0) return;

    final barLeft = inset;
    final progressRight = endX;
    final centerY = availableSize.height / 2;
    final omega = 2 * pi * config.cycleCount / adjustedWidth;

    final waveColor = config.waveColor ?? progressBarColor;
    final strokeCap = barCapShape == BarCapShape.round
        ? StrokeCap.round
        : StrokeCap.square;

    for (int w = 0; w < config.waveCount; w++) {
      final phaseOffset = w * pi / 4;
      final opacity = (1.0 - w * 0.2).clamp(0.0, 1.0);
      final wavePaint = Paint()
        ..color = waveColor.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = barHeight
        ..strokeCap = strokeCap;

      final path = Path();
      final startY = centerY +
          sin(phaseOffset + wavePhase) * config.amplitude;
      path.moveTo(barLeft, startY);

      final step = max(1.5, barHeight / 4);
      for (double x = barLeft + step; x <= progressRight + step; x += step) {
        final clampedX = x > progressRight ? progressRight : x;
        final waveY = centerY +
            sin(omega * (clampedX - barLeft) + wavePhase + phaseOffset) *
                config.amplitude;
        path.lineTo(clampedX, waveY);
      }

      if (config.clampToBarBounds) {
        final halfH = barHeight / 2;
        canvas.save();
        canvas.clipRect(Rect.fromLTRB(
          barLeft, centerY - halfH, progressRight, centerY + halfH,
        ));
        canvas.drawPath(path, wavePaint);
        canvas.restore();
      } else {
        canvas.drawPath(path, wavePaint);
      }
    }
  }

  /// 绘制滑块。
  void _drawThumb(Canvas canvas, Size availableSize) {
    final capRadius =
        barCapShape == BarCapShape.round ? barHeight / 2 : 0.0;
    final inset = capRadius + thumbBarGap;
    final adjustedWidth = availableSize.width - inset * 2;

    var thumbDx = progressFraction * adjustedWidth + inset;
    if (!thumbCanPaintOutsideBar) {
      thumbDx = thumbDx.clamp(thumbRadius, availableSize.width - thumbRadius);
    }

    final center = Offset(thumbDx, availableSize.height / 2);

    // 拖拽时绘制光晕
    if (isDragging && thumbGlowRadius > 0) {
      canvas.drawCircle(center, thumbGlowRadius, Paint()..color = thumbGlowColor);
    }

    final thumbPaint = Paint()..color = thumbColor;

    switch (thumbShape) {
      case ThumbShape.circle:
        canvas.drawCircle(center, thumbRadius, thumbPaint);
      case ThumbShape.line:
        final rect = RRect.fromLTRBR(
          center.dx - lineThumbWidth / 2,
          center.dy - lineThumbHeight / 2,
          center.dx + lineThumbWidth / 2,
          center.dy + lineThumbHeight / 2,
          Radius.circular(lineThumbBorderRadius),
        );
        canvas.drawRRect(rect, thumbPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ProgressBarPainter oldDelegate) {
    return oldDelegate.progressFraction != progressFraction ||
        oldDelegate.bufferedFraction != bufferedFraction ||
        oldDelegate.barHeight != barHeight ||
        oldDelegate.baseBarColor != baseBarColor ||
        oldDelegate.progressBarColor != progressBarColor ||
        oldDelegate.bufferedBarColor != bufferedBarColor ||
        oldDelegate.barCapShape != barCapShape ||
        oldDelegate.barBorderRadius != barBorderRadius ||
        oldDelegate.thumbRadius != thumbRadius ||
        oldDelegate.thumbColor != thumbColor ||
        oldDelegate.thumbGlowColor != thumbGlowColor ||
        oldDelegate.thumbGlowRadius != thumbGlowRadius ||
        oldDelegate.thumbCanPaintOutsideBar != thumbCanPaintOutsideBar ||
        oldDelegate.thumbShape != thumbShape ||
        oldDelegate.lineThumbWidth != lineThumbWidth ||
        oldDelegate.lineThumbHeight != lineThumbHeight ||
        oldDelegate.lineThumbBorderRadius != lineThumbBorderRadius ||
        oldDelegate.thumbBarGap != thumbBarGap ||
        oldDelegate.thumbGap != thumbGap ||
        oldDelegate.isDragging != isDragging ||
        oldDelegate.leftLabel != leftLabel ||
        oldDelegate.rightLabel != rightLabel ||
        oldDelegate.timeLabelLocation != timeLabelLocation ||
        oldDelegate.timeLabelPadding != timeLabelPadding ||
        oldDelegate.sineWaveConfig != sineWaveConfig ||
        oldDelegate.waveAnimation != waveAnimation;
  }
}
