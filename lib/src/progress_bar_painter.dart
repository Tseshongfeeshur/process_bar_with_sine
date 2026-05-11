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
    this.thumbCustomPainter,
    required this.thumbBarGap,
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

  /// 进度条的自定义圆角半径。为 `null` 时回退到 [barCapShape] 行为。
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

  /// 自定义滑块绘制器（当 [thumbShape] 为 [ThumbShape.custom] 时使用）。
  final ThumbShapePainter? thumbCustomPainter;

  /// 进度条端点与滑块边缘之间的视觉间隙。
  final double thumbBarGap;

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

  /// 当标签在两侧时，进度条与标签之间的默认间距。
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
        break;
      case TimeLabelLocation.sides:
        _drawWithLabelsOnSides(canvas, size);
        break;
      case TimeLabelLocation.none:
        _drawWithoutLabels(canvas, size);
        break;
    }

    canvas.restore();
  }

  /// 绘制上下布局的标签和进度条。
  ///
  /// | -------O---------------- |
  /// | 01:23              05:00 |
  ///
  /// 或者：
  ///
  /// | 01:23              05:00 |
  /// | -------O---------------- |
  void _drawWithLabelsAboveOrBelow(Canvas canvas, Size size) {
    final isLabelBelow = timeLabelLocation == TimeLabelLocation.below;
    final barAreaHeight = _computeBarAreaHeight();
    final labelHeight = leftLabel?.height ?? 0.0;

    // 绘制时间标签
    final labelY = isLabelBelow ? barAreaHeight + timeLabelPadding : 0.0;
    leftLabel?.paint(canvas, Offset(0, labelY));
    final rl = rightLabel;
    if (rl != null) {
      final rightDx = size.width - rl.width;
      rl.paint(canvas, Offset(rightDx, labelY));
    }

    // 绘制进度条
    final barY = isLabelBelow ? 0.0 : labelHeight + timeLabelPadding;
    final barAreaSize = Size(size.width, barAreaHeight);
    canvas.save();
    canvas.translate(0, barY);
    _drawBarContent(canvas, barAreaSize);
    canvas.restore();
  }

  /// 绘制两侧布局的标签和进度条。
  ///
  /// | 01:23 -------O---------------- 05:00 |
  void _drawWithLabelsOnSides(Canvas canvas, Size size) {
    final leftLabel = this.leftLabel;
    final rightLabel = this.rightLabel;

    // 垂直居中标签
    final verticalOffset = size.height / 2 - (leftLabel?.height ?? 0) / 2;
    leftLabel?.paint(canvas, Offset(0, verticalOffset));
    final rl2 = rightLabel;
    if (rl2 != null) {
      final rightDx = size.width - rl2.width;
      rl2.paint(canvas, Offset(rightDx, verticalOffset));
    }

    // 计算进度条区域
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

  /// 绘制无标签的进度条。
  ///
  /// | -------O---------------- |
  void _drawWithoutLabels(Canvas canvas, Size size) {
    final barAreaHeight = _computeBarAreaHeight();
    final barDy = size.height / 2 - barAreaHeight / 2;
    canvas.save();
    canvas.translate(0, barDy);
    _drawBarContent(canvas, Size(size.width, barAreaHeight));
    canvas.restore();
  }

  /// 计算进度条区域的高度。
  double _computeBarAreaHeight() {
    double base = max(2 * thumbRadius, barHeight);
    final config = sineWaveConfig;
    if (config != null && !config.clampToBarBounds) {
      base += config.amplitude * 2;
    }
    return base;
  }

  /// 在给定的区域内绘制进度条主体（底色、缓冲、已走部分、滑块）。
  void _drawBarContent(Canvas canvas, Size barAreaSize) {
    // 由于波浪可能超出顶部，计算条的垂直偏移
    final config2 = sineWaveConfig;
    final waveOverflow = (config2 != null && !config2.clampToBarBounds)
        ? config2.amplitude
        : 0.0;
    final barY = waveOverflow;
    final barPaintAreaHeight = barAreaSize.height - waveOverflow;

    canvas.save();
    canvas.translate(0, barY);

    final barPaintSize = Size(barAreaSize.width, barPaintAreaHeight);

    // 计算进度条的物理范围用于区域划分
    final capRadius =
        barCapShape == BarCapShape.round ? barHeight / 2 : 0.0;
    final inset = capRadius + thumbBarGap;
    final adjustedWidth = barPaintSize.width - inset * 2;

    if (config2 != null && config2.amplitude > 0 && progressFraction > 0) {
      // 波浪模式：已走部分只绘制正弦曲线，后方绘制平直底色条和缓冲条
      final progressEndX = inset + adjustedWidth * progressFraction;
      final wavePhase = (waveAnimation?.value ?? 0.0) * 2 * pi;

      _drawProgressBarWithWave(canvas, barPaintSize, config2, wavePhase);

      // 绘制已走部分后方的剩余底色条
      if (progressFraction < 1.0) {
        final halfH = barHeight / 2;
        canvas.save();
        canvas.clipRect(Rect.fromLTRB(
          progressEndX, barPaintAreaHeight / 2 - halfH,
          barPaintSize.width, barPaintAreaHeight / 2 + halfH,
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

  /// 绘制底色进度条（全长）。
  void _drawBaseBar(Canvas canvas, Size availableSize) {
    _drawBarSegment(
      canvas: canvas,
      availableSize: availableSize,
      widthProportion: 1.0,
      color: baseBarColor,
    );
  }

  /// 绘制缓冲进度条。
  void _drawBufferedBar(Canvas canvas, Size availableSize) {
    _drawBarSegment(
      canvas: canvas,
      availableSize: availableSize,
      widthProportion: bufferedFraction,
      color: bufferedBarColor,
    );
  }

  /// 绘制已走进度部分（无波浪时的直线模式）。
  void _drawProgressBar(Canvas canvas, Size availableSize) {
    _drawBarSegment(
      canvas: canvas,
      availableSize: availableSize,
      widthProportion: progressFraction,
      color: progressBarColor,
    );
  }

  /// 绘制一个进度条线段。
  void _drawBarSegment({
    required Canvas canvas,
    required Size availableSize,
    required double widthProportion,
    required Color color,
  }) {
    if (widthProportion <= 0.0) return;

    final strokeCap = barCapShape == BarCapShape.round
        ? StrokeCap.round
        : StrokeCap.square;
    final paint = Paint()
      ..color = color
      ..strokeCap = strokeCap
      ..strokeWidth = barHeight
      ..style = PaintingStyle.stroke;

    final capRadius = barCapShape == BarCapShape.round ? barHeight / 2 : 0.0;
    final inset = capRadius + thumbBarGap;
    final adjustedWidth = availableSize.width - inset * 2;
    if (adjustedWidth <= 0) return;

    final dx = widthProportion * adjustedWidth + inset;
    final startPoint = Offset(inset, availableSize.height / 2);
    final endPoint = Offset(dx, availableSize.height / 2);

    if (barBorderRadius != null && barBorderRadius! > 0) {
      // 使用圆角矩形而非描边线条
      _drawRoundedBarSegment(
        canvas: canvas,
        availableSize: availableSize,
        endX: dx,
        inset: inset,
        color: color,
      );
      return;
    }

    canvas.drawLine(startPoint, endPoint, paint);
  }

  /// 使用圆角矩形方式绘制进度条线段。
  void _drawRoundedBarSegment({
    required Canvas canvas,
    required Size availableSize,
    required double endX,
    required double inset,
    required Color color,
  }) {
    final radius = barBorderRadius ?? barHeight / 2;
    final rect = RRect.fromLTRBR(
      inset,
      availableSize.height / 2 - barHeight / 2,
      endX,
      availableSize.height / 2 + barHeight / 2,
      Radius.circular(radius),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rect, paint);
  }

  /// 绘制带正弦波浪的进度条已走部分。
  /// 以与进度条等粗细的描边曲线绘制正弦波。
  void _drawProgressBarWithWave(Canvas canvas, Size availableSize, SineWaveConfig config, double wavePhase) {
    if (progressFraction <= 0) return;
    final capRadius =
        barCapShape == BarCapShape.round ? barHeight / 2 : 0.0;
    final inset = capRadius + thumbBarGap;
    final adjustedWidth = availableSize.width - inset * 2;
    if (adjustedWidth <= 0) return;

    final barLeft = inset;
    final progressRight = inset + adjustedWidth * progressFraction;
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
      // 从起点开始：在 barLeft 处计算正弦值
      final startY = centerY +
          sin(phaseOffset + wavePhase) * config.amplitude;
      path.moveTo(barLeft, startY);

      // 以 4px 步长采样正弦波，在 60fps 下视觉上已足够平滑
      const step = 4.0;
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
          barLeft,
          centerY - halfH,
          progressRight,
          centerY + halfH,
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
      final glowPaint = Paint()..color = thumbGlowColor;
      canvas.drawCircle(center, thumbGlowRadius, glowPaint);
    }

    // 绘制滑块
    final thumbPaint = Paint()
      ..color = thumbColor
      ..style = PaintingStyle.fill;

    switch (thumbShape) {
      case ThumbShape.circle:
        canvas.drawCircle(center, thumbRadius, thumbPaint);
        break;
      case ThumbShape.square:
        canvas.drawRect(
          Rect.fromCenter(
              center: center, width: thumbRadius * 2, height: thumbRadius * 2),
          thumbPaint,
        );
        break;
      case ThumbShape.diamond:
        _drawDiamondThumb(canvas, center, thumbRadius, thumbPaint);
        break;
      case ThumbShape.triangle:
        _drawTriangleThumb(canvas, center, thumbRadius, thumbPaint);
        break;
      case ThumbShape.custom:
        thumbCustomPainter?.paint(canvas, center, thumbRadius, thumbPaint);
        break;
    }
  }

  /// 绘制菱形滑块。
  void _drawDiamondThumb(
      Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius, center.dy)
      ..lineTo(center.dx, center.dy + radius)
      ..lineTo(center.dx - radius, center.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  /// 绘制三角形滑块（尖角朝上）。
  void _drawTriangleThumb(
      Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..lineTo(center.dx + radius, center.dy + radius * 0.866)
      ..lineTo(center.dx - radius, center.dy + radius * 0.866)
      ..close();
    canvas.drawPath(path, paint);
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
        oldDelegate.thumbBarGap != thumbBarGap ||
        oldDelegate.isDragging != isDragging ||
        oldDelegate.leftLabel != leftLabel ||
        oldDelegate.rightLabel != rightLabel ||
        oldDelegate.timeLabelLocation != timeLabelLocation ||
        oldDelegate.timeLabelPadding != timeLabelPadding ||
        oldDelegate.sineWaveConfig != sineWaveConfig ||
        oldDelegate.waveAnimation != waveAnimation;
  }
}
