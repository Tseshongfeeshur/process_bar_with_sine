# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 语言偏好

所有对话、代码注释、文档和说明一律使用简体中文。

## 项目概述

一个增强版 Flutter 进度条组件，参照 `example.dart` 的参数列表设计，额外支持：
- 可自定义滑块形状（圆形、方形、菱形、三角形、自定义绘制）
- 可自定义进度条圆角半径
- 已走部分的正弦波浪线动画（类似 Material Design 3 / Android 媒体通知风格）
- 进度条与滑块之间的可配置间隙

## 构建和验证命令

```bash
# 静态分析
flutter analyze

# 运行示例应用
cd example && flutter run
```

## 架构

```
lib/
  progress_bar.dart                  # 统一导出文件
  src/
    progress_bar_enums.dart          # BarCapShape, TimeLabelLocation, TimeLabelType, ThumbShape
    thumb_drag_details.dart          # ThumbDragDetails 模型 + 回调 typedef
    sine_wave_config.dart            # SineWaveConfig + ThumbShapePainter 抽象类
    time_format.dart                 # Duration → String 格式化工具
    progress_bar_painter.dart        # ProgressBarPainter (CustomPainter)，所有绘制逻辑
    progress_bar_widget.dart         # ProgressBar (StatefulWidget) + _ProgressBarState
```

### 组件层次

`ProgressBar` 是 `StatefulWidget`（非 `LeafRenderObjectWidget`），因为正弦波动画需要 `AnimationController` + `TickerProviderStateMixin`。绘制使用 `CustomPaint` + `CustomPainter`，动画通过 `CustomPainter(repaint:)` 驱动。

### 关键设计

- **绘制流水线**：底色条 → 缓冲条 → 进度条（可选正弦波浪 Path）→ 滑块光晕 → 滑块形状 → 时间标签
- **动画生命周期**：`sineWaveConfig` 非 null 时创建 `AnimationController` 并 `repeat()`；配置变化时在 `didUpdateWidget` 中重建
- **手势处理**：`_EagerHorizontalDragGestureRecognizer` 立即接受指针以在滑动竞争中获胜（与原始 example.dart 相同策略）
- **文本缓存**：时间标签的 `TextPainter` 仅在字符串长度可能变化时（分钟/小时数字位数改变）失效重建
- **向后兼容**：所有新参数有默认值（`sineWaveConfig = null`、`thumbShape = circle`、`thumbBarGap = 0`），仅使用原有参数时行为与原作一致
