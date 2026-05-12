import 'package:flutter/material.dart';
import 'package:process_bar_with_sine/process_bar_with_sine.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '正弦波浪进度条示例',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  Duration _progress = Duration.zero;
  final Duration _total = const Duration(minutes: 5, seconds: 0);
  bool _isPlaying = false;

  // 演示用的配置
  ThumbShape _thumbShape = ThumbShape.circle;
  bool _sineWaveEnabled = true;
  double _thumbGap = 0.0;
  double _thumbBarGap = 0.0;
  double _barBorderRadius = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('正弦波浪进度条'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 进度条
            ProgressBar(
              progress: _progress,
              total: _total,
              thumbShape: _thumbShape,
              thumbGap: _thumbGap,
              thumbBarGap: _thumbBarGap,
              barBorderRadius: _barBorderRadius > 0 ? _barBorderRadius : null,
              sineWaveConfig: _sineWaveEnabled
                  ? const SineWaveConfig(
                      amplitude: 4.0,
                      cycleCount: 9.0,
                      speed: 1.5,
                    )
                  : null,
              onSeek: (duration) {
                setState(() {
                  _progress = duration;
                });
              },
              timeLabelLocation: TimeLabelLocation.below,
            ),
            const SizedBox(height: 32),

            // 播放/暂停按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    setState(() {
                      _isPlaying = !_isPlaying;
                    });
                    if (_isPlaying) {
                      _startPlayback();
                    }
                  },
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _progress = Duration.zero;
                      _isPlaying = false;
                    });
                  },
                  child: const Text('重置'),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 配置控件
            const Text('滑块形状', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ThumbShape.values.map((shape) {
                final isSelected = _thumbShape == shape;
                return ChoiceChip(
                  label: Text(shape.name),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _thumbShape = shape;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // 波浪开关
            SwitchListTile(
              title: const Text('正弦波浪动画'),
              value: _sineWaveEnabled,
              onChanged: (v) {
                setState(() {
                  _sineWaveEnabled = v;
                });
              },
            ),
            const SizedBox(height: 8),

            // 滑块分段间隙
            Row(
              children: [
                const Text('分段间隙'),
                Expanded(
                  child: Slider(
                    value: _thumbGap,
                    min: 0,
                    max: 30,
                    divisions: 30,
                    label: _thumbGap.toStringAsFixed(0),
                    onChanged: (v) {
                      setState(() {
                        _thumbGap = v;
                      });
                    },
                  ),
                ),
                Text(_thumbGap.toStringAsFixed(0)),
              ],
            ),
            const SizedBox(height: 8),

            // 端点间隙滑块
            Row(
              children: [
                const Text('滑块间隙'),
                Expanded(
                  child: Slider(
                    value: _thumbBarGap,
                    min: 0,
                    max: 20,
                    divisions: 20,
                    label: _thumbBarGap.toStringAsFixed(0),
                    onChanged: (v) {
                      setState(() {
                        _thumbBarGap = v;
                      });
                    },
                  ),
                ),
                Text(_thumbBarGap.toStringAsFixed(0)),
              ],
            ),
            const SizedBox(height: 8),

            // 圆角滑块
            Row(
              children: [
                const Text('进度条圆角'),
                Expanded(
                  child: Slider(
                    value: _barBorderRadius,
                    min: 0,
                    max: 20,
                    divisions: 20,
                    label: _barBorderRadius.toStringAsFixed(0),
                    onChanged: (v) {
                      setState(() {
                        _barBorderRadius = v;
                      });
                    },
                  ),
                ),
                Text(_barBorderRadius.toStringAsFixed(0)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _startPlayback() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!_isPlaying || !mounted) return false;
      setState(() {
        if (_progress < _total) {
          _progress += const Duration(milliseconds: 100);
        } else {
          _isPlaying = false;
        }
      });
      return _isPlaying && _progress < _total && mounted;
    });
  }
}
