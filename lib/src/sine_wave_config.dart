import 'dart:ui';

/// 进度条已走部分的正弦波浪线动画配置。
///
/// 传入到 [ProgressBar.sineWaveConfig] 时，已走部分以流动的正弦波浪动画填充。
/// 传入 `null`（默认值）则渲染平直进度条。
class SineWaveConfig {
  const SineWaveConfig({
    this.amplitude = 3.0,
    this.cycleCount = 2.0,
    this.speed = 1.0,
    this.waveColor,
    this.waveCount = 1,
    this.clampToBarBounds = false,
    this.reservedAmplitude,
  });

  /// 正弦波偏离中心线的峰值幅度，单位逻辑像素。默认 3.0。
  final double amplitude;

  /// 可见进度宽度上的完整周期数。默认 2.0。
  final double cycleCount;

  /// 动画速度倍率。1.0 为基准速度，2.0 为两倍速度。
  final double speed;

  /// 波浪颜色覆盖，`null` 时使用 progressBarColor。
  final Color? waveColor;

  /// 叠加波浪层数，>1 时产生丰富波纹效果。
  final int waveCount;

  /// 是否将波浪裁剪到进度条边界内。
  final bool clampToBarBounds;

  /// 预留振幅高度。组件高度始终按此值与 [amplitude] 中的较大者计算，
  /// 避免调整振幅时进度条高度跟随变化。默认 `null` 时仅按 [amplitude] 计算。
  final double? reservedAmplitude;

  /// 实际用于计算组件高度的振幅值。
  double get effectiveAmplitude {
    if (reservedAmplitude != null) {
      return amplitude > reservedAmplitude! ? amplitude : reservedAmplitude!;
    }
    return amplitude;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SineWaveConfig &&
        other.amplitude == amplitude &&
        other.cycleCount == cycleCount &&
        other.speed == speed &&
        other.waveColor == waveColor &&
        other.waveCount == waveCount &&
        other.clampToBarBounds == clampToBarBounds &&
        other.reservedAmplitude == reservedAmplitude;
  }

  @override
  int get hashCode => Object.hash(
        amplitude,
        cycleCount,
        speed,
        waveColor,
        waveCount,
        clampToBarBounds,
        reservedAmplitude,
      );
}
