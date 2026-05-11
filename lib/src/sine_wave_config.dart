import 'dart:ui';

/// 自定义滑块形状的绘制委托。
///
/// 当 [ThumbShape] 为 [ThumbShape.custom] 时，提供此实现来绘制自定义滑块。
abstract class ThumbShapePainter {
  /// 在 [center] 处使用给定的 [paint] 样式绘制滑块。
  ///
  /// [radius] 是滑块的尺寸参考（等于 `thumbRadius`）。
  /// 实现可以自由绘制更大或更小的形状。
  void paint(Canvas canvas, Offset center, double radius, Paint paint);
}

/// 进度条已走部分的正弦波浪线动画配置。
///
/// 传入到 [SineProgressBar.sineWaveConfig] 时，进度条的已走部分会以流动的
/// 正弦波浪动画填充，产生流畅、有活力的视觉效果。
///
/// 传入 `null`（默认值）可完全禁用正弦波浪，渲染为平坦的进度条。
class SineWaveConfig {
  const SineWaveConfig({
    this.amplitude = 3.0,
    this.cycleCount = 2.0,
    this.speed = 1.0,
    this.waveColor,
    this.waveCount = 1,
    this.clampToBarBounds = false,
  });

  /// 正弦波偏离进度条中心线的峰值幅度，单位为逻辑像素。默认 3.0。
  ///
  /// 设为 0 时，波浪不可见，但动画控制器仍在运行。
  final double amplitude;

  /// 在可见进度条宽度上的完整正弦周期数。默认 2.0。
  /// 值越大，波浪越密集。
  final double cycleCount;

  /// 动画速度倍率。1.0 = 基准速度（约 2 秒一个完整相位周期）。2.0 = 两倍速度。
  final double speed;

  /// 波浪部分的颜色覆盖。为 `null` 时使用 `progressBarColor`。
  final Color? waveColor;

  /// 叠加的波浪层数。大于 1 时产生更丰富的波纹效果，
  /// 每层之间有相位偏移。
  final int waveCount;

  /// 是否将正弦波裁剪到进度条的矩形边界内。
  ///
  /// 为 `true` 时波浪不会超出进度条范围。
  /// 为 `false`（默认）时波浪可以延伸到进度条上方，组件高度会自动调整以容纳。
  final bool clampToBarBounds;
}
