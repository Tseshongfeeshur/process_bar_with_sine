## 1.2.2

- **Fix**: The gesture recognizer was missing an `onCancel` binding, causing the internal drag state to be permanently locked to `true` when a drag was terminated abnormally, preventing playback progress from ever driving the thumb again.

## 1.2.1

- **Fix**: `_finishDrag` did not recalculate `_thumbValue` from `widget.progress` when the drag ended, causing the thumb to fail to immediately follow playback progress.
- **Fix**: `_proportionOfTotal` was missing 0–1 clamping, which could cause the thumb to exceed bar bounds when switching tracks if the previous progress exceeded the new total duration.

## 1.2.0

- **Refactor**: Rewrote from `LeafRenderObjectWidget` to a `StatefulWidget` + `CustomPainter` architecture.
- **Add**: `ThumbShape` enum with `circle` and `line` (vertical rounded rectangle) shapes.
- **Add**: `lineThumbWidth`, `lineThumbHeight`, `lineThumbBorderRadius` parameters for precise control over the line thumb's dimensions and corner radius.
- **Add**: `barBorderRadius` parameter for custom track corner radius, overriding the default `barCapShape` behavior.
- **Add**: `SineWaveConfig` class and `sineWaveConfig` parameter to enable a sine-wave animation on the played portion of the bar.
- **Add**: `thumbGap` parameter, which splits the bar into two segments around the thumb, with both ends independently applying corner radius.
- **Add**: `thumbBarGap` parameter to control the visual gap between bar ends and the thumb.
- **Add**: Value equality (`==` / `hashCode`) on `SineWaveConfig` to prevent spurious animation controller resets when the parent rebuilds.
- **Change**: Replaced `withOpacity` with `withValues` to resolve deprecation warnings on Flutter 3.10+.

## 1.1.1

- Update pubspec.yaml version.

## 1.1.0

- **Add**: `thumbWidget` parameter, allowing a custom widget to be used as the thumb in place of the built-in drawing.

## 1.0.1

- **Fix**: Frequent progress bar jitter during playback.

## 1.0.0

- Initial release, implementing a basic media progress bar widget.
- Support for drag-to-seek, buffered progress display.
- Support for time labels (above / below / sides / hidden).
- Support for `BarCapShape.round` and `BarCapShape.square` cap styles.
- Support for thumb glow effect and accessibility semantics.
