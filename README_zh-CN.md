# ProcessBar with Sine / 带正弦波浪的进度条

一个增强版 Flutter 进度条组件，支持动态正弦波浪动画。可作为媒体播放场景中标准 Flutter `Slider` 的直接替代，提供滑块形状、轨道样式和动画进度的高度自定义。

[English](README.md)

## 特性

- **正弦波浪动画** -- 已走部分以流动的正弦波浪填充（Material Design 3 / Android 媒体通知风格）
- **滑块形状可自定义** -- 内置 `circle`（圆形）和 `line`（纵向圆角矩形）两种形状，尺寸可精确调节
- **轨道圆角可配置** -- `barBorderRadius` 可覆盖默认端点样式，实现任意圆角
- **滑块间隙可调节** -- `thumbGap` 使进度条在滑块处断开为左右两段；`thumbBarGap` 控制端点与滑块间距
- **时间标签** -- 支持在上方 / 下方 / 两侧显示已播放、总时长或剩余时间
- **向后兼容** -- 所有新增参数均有合理默认值，仅使用原版参数时行为完全一致

## 快速开始

```yaml
dependencies:
  process_bar_with_sine: ^1.2.0
```

```dart
import 'package:process_bar_with_sine/process_bar_with_sine.dart';

ProgressBar(
  progress: const Duration(seconds: 30),
  total: const Duration(minutes: 2),
  onSeek: (position) { /* 跳转播放器 */ },
  // 可选：启用正弦波浪动画
  sineWaveConfig: const SineWaveConfig(
    amplitude: 3.0,
    cycleCount: 2.0,
    speed: 1.0,
  ),
  // 可选：切换滑块形状
  thumbShape: ThumbShape.line,
)
```

## 参数

### 核心参数（与原版一致）

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `progress` | `Duration` | **必填** | 媒体已播放时间 |
| `total` | `Duration` | **必填** | 媒体总时长 |
| `buffered` | `Duration?` | `null` | 缓冲内容时长 |
| `onSeek` | `ValueChanged<Duration>?` | `null` | 用户拖动完成后的回调 |
| `onDragStart` | `ThumbDragStartCallback?` | `null` | 拖动开始时的回调 |
| `onDragUpdate` | `ThumbDragUpdateCallback?` | `null` | 拖动过程中的持续回调 |
| `onDragEnd` | `VoidCallback?` | `null` | 拖动结束时的回调 |
| `barHeight` | `double` | `5.0` | 进度条的垂直粗细 |
| `baseBarColor` | `Color?` | 主题主色 24% | 未播放部分的颜色 |
| `progressBarColor` | `Color?` | 主题主色 | 已播放部分的颜色 |
| `bufferedBarColor` | `Color?` | 主题主色 24% | 缓冲部分的颜色 |
| `barCapShape` | `BarCapShape` | `round` | 进度条端点形状 |
| `thumbRadius` | `double` | `10.0` | 滑块圆形半径 |
| `thumbColor` | `Color?` | 主题主色 | 滑块颜色 |
| `thumbGlowColor` | `Color?` | thumbColor 31% | 拖拽光晕颜色 |
| `thumbGlowRadius` | `double` | `30.0` | 拖拽光晕半径 |
| `thumbCanPaintOutsideBar` | `bool` | `true` | 滑块是否可超出进度条边界 |
| `timeLabelLocation` | `TimeLabelLocation?` | `below` | 时间标签位置 |
| `timeLabelType` | `TimeLabelType?` | `totalTime` | 右侧标签显示内容 |
| `timeLabelTextStyle` | `TextStyle?` | `bodyLarge` | 标签文字样式 |
| `timeLabelPadding` | `double` | `0.0` | 标签与进度条间距 |

### 1.2.0 新增

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `thumbShape` | `ThumbShape` | `circle` | 滑块视觉形状 |
| `lineThumbWidth` | `double` | `4.0` | line 形状滑块的宽度 |
| `lineThumbHeight` | `double` | `14.0` | line 形状滑块的高度 |
| `lineThumbBorderRadius` | `double` | `2.0` | line 形状滑块的圆角半径 |
| `barBorderRadius` | `double?` | `null` | 轨道圆角半径，覆盖 `barCapShape` |
| `thumbBarGap` | `double` | `0.0` | 进度条端点与滑块间距 |
| `thumbGap` | `double` | `0.0` | 滑块周围间隙，使进度条分段 |
| `sineWaveConfig` | `SineWaveConfig?` | `null` | 正弦波浪动画配置 |

### `SineWaveConfig`

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `amplitude` | `double` | `3.0` | 正弦波峰值幅度（逻辑像素） |
| `cycleCount` | `double` | `2.0` | 可见进度宽度上的完整周期数 |
| `speed` | `double` | `1.0` | 动画速度倍率 |
| `waveColor` | `Color?` | `null` | 波浪颜色覆盖；为 `null` 时使用 `progressBarColor` |
| `waveCount` | `int` | `1` | 叠加波浪层数，产生更丰富的波纹效果 |
| `clampToBarBounds` | `bool` | `false` | 是否将波浪裁剪到进度条边界内 |

## 环境要求

- Dart SDK `>=3.0.0 <4.0.0`
- Flutter `>=3.10.0`

## 许可证

MIT
