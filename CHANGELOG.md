## 1.2.1

- **修复**：手势识别器缺少 `onCancel` 绑定，导致某些拖拽终止方式（如手指无水平位移即抬起）使内部拖拽状态永久锁死为 `true`，播放进度无法再驱动滑块移动

## 1.2.0

- **重构**：将 `LeafRenderObjectWidget` 重写为 `StatefulWidget` + `CustomPainter` 架构
- **新增**：`ThumbShape` 枚举，支持 `circle`（圆形）和 `line`（纵向圆角矩形）两种滑块形状
- **新增**：`lineThumbWidth`、`lineThumbHeight`、`lineThumbBorderRadius` 参数，精确控制 line 形状滑块的尺寸和圆角
- **新增**：`barBorderRadius` 参数，支持自定义进度条圆角半径，覆盖 `barCapShape` 的默认行为
- **新增**：`SineWaveConfig` 配置类与 `sineWaveConfig` 参数，为已走部分启用正弦波浪线动画
- **新增**：`thumbGap` 参数，使进度条在滑块处断开为左右两段，每段两端独立应用圆角
- **新增**：`thumbBarGap` 参数，控制进度条端点与滑块之间的视觉间隙
- **新增**：`SineWaveConfig` 实现值相等比较，避免父组件重建时误触发动画控制器重置
- **变更**：将 `withOpacity` 替换为 `withValues`，消除 Flutter 3.10+ 的废弃警告

## 1.1.1

- 更新 pubspec.yaml 版本号

## 1.1.0

- **新增**：`thumbWidget` 参数，允许传入自定义 Widget 作为滑块，替代内置绘制

## 1.0.1

- **修复**：播放时进度条频繁抖动的问题

## 1.0.0

- 首个正式版本，实现基础媒体进度条组件
- 支持拖拽滑块跳转、缓冲进度显示
- 支持时间标签（上方 / 下方 / 两侧 / 隐藏）
- 支持 `BarCapShape.round` / `BarCapShape.square` 端点样式
- 支持滑块光晕效果和无障碍语义
