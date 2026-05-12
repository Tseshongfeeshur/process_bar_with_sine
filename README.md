# ProcessBar with Sine

An enhanced Flutter progress bar widget with dynamic sine-wave animations. Designed as a drop-in replacement for the standard Flutter `Slider` in media playback scenarios, with deep customization for thumb shapes, track styling, and animated progress.

[中文文档](README_zh-CN.md)

## Features

- **Sine wave animation** -- animated sine wave fills the played portion of the progress bar (Material Design 3 / Android media notification style)
- **Customizable thumb shape** -- built-in `circle` and `line` (vertical rounded rectangle) shapes, with adjustable dimensions
- **Configurable track corners** -- `barBorderRadius` overrides the default cap-shape behavior for fully rounded corners
- **Adjustable thumb gaps** -- `thumbGap` splits the bar into two segments around the thumb; `thumbBarGap` controls the end-to-thumb spacing
- **Time labels** -- display elapsed / total / remaining time above, below, or beside the bar
- **Backward compatible** -- all new parameters have sensible defaults; using only the original parameters yields identical behavior

## Quick start

```yaml
dependencies:
  process_bar_with_sine: ^1.2.0
```

```dart
import 'package:process_bar_with_sine/process_bar_with_sine.dart';

ProgressBar(
  progress: const Duration(seconds: 30),
  total: const Duration(minutes: 2),
  onSeek: (position) { /* seek player */ },
  // Optional: enable sine wave animation
  sineWaveConfig: const SineWaveConfig(
    amplitude: 3.0,
    cycleCount: 2.0,
    speed: 1.0,
  ),
  // Optional: change thumb shape
  thumbShape: ThumbShape.line,
)
```

## Parameters

### Core (unchanged from original)

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `progress` | `Duration` | **required** | Elapsed playback time |
| `total` | `Duration` | **required** | Total media duration |
| `buffered` | `Duration?` | `null` | Buffered content duration |
| `onSeek` | `ValueChanged<Duration>?` | `null` | Called when the user finishes dragging |
| `onDragStart` | `ThumbDragStartCallback?` | `null` | Called when dragging begins |
| `onDragUpdate` | `ThumbDragUpdateCallback?` | `null` | Called repeatedly during dragging |
| `onDragEnd` | `VoidCallback?` | `null` | Called when dragging ends |
| `barHeight` | `double` | `5.0` | Vertical thickness of the bar |
| `baseBarColor` | `Color?` | theme primary 24% | Color of the unplayed portion |
| `progressBarColor` | `Color?` | theme primary | Color of the played portion |
| `bufferedBarColor` | `Color?` | theme primary 24% | Color of the buffered portion |
| `barCapShape` | `BarCapShape` | `round` | Shape of the bar ends |
| `thumbRadius` | `double` | `10.0` | Radius of the thumb (circle) |
| `thumbColor` | `Color?` | theme primary | Color of the thumb |
| `thumbGlowColor` | `Color?` | thumbColor 31% | Color of the drag glow |
| `thumbGlowRadius` | `double` | `30.0` | Radius of the drag glow |
| `thumbCanPaintOutsideBar` | `bool` | `true` | Whether the thumb can extend beyond bar bounds |
| `timeLabelLocation` | `TimeLabelLocation?` | `below` | Where to show time labels |
| `timeLabelType` | `TimeLabelType?` | `totalTime` | Right label shows total or remaining |
| `timeLabelTextStyle` | `TextStyle?` | `bodyLarge` | Text style for labels |
| `timeLabelPadding` | `double` | `0.0` | Extra space between labels and bar |

### New in 1.2.0

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `thumbShape` | `ThumbShape` | `circle` | Visual shape of the thumb |
| `lineThumbWidth` | `double` | `4.0` | Width of the line thumb |
| `lineThumbHeight` | `double` | `14.0` | Height of the line thumb |
| `lineThumbBorderRadius` | `double` | `2.0` | Corner radius of the line thumb |
| `barBorderRadius` | `double?` | `null` | Track corner radius; overrides `barCapShape` |
| `thumbBarGap` | `double` | `0.0` | Gap between bar ends and thumb |
| `thumbGap` | `double` | `0.0` | Gap around thumb, splitting the bar into two segments |
| `sineWaveConfig` | `SineWaveConfig?` | `null` | Sine wave animation configuration |

### `SineWaveConfig`

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `amplitude` | `double` | `3.0` | Peak vertical displacement (logical pixels) |
| `cycleCount` | `double` | `2.0` | Number of full sine cycles across the visible progress width |
| `speed` | `double` | `1.0` | Animation speed multiplier |
| `waveColor` | `Color?` | `null` | Wave color override; falls back to `progressBarColor` |
| `waveCount` | `int` | `1` | Number of stacked wave layers for richer visual effect |
| `clampToBarBounds` | `bool` | `false` | Whether to clip the wave to the bar rectangle |

## Requirements

- Dart SDK `>=3.0.0 <4.0.0`
- Flutter `>=3.10.0`

## License

MIT
