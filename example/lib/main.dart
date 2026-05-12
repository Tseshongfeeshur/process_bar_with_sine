import 'dart:async';

import 'package:flutter/material.dart';
import 'package:process_bar_with_sine/process_bar_with_sine.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProgressBar 增强功能演示',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  static const _totalDuration = Duration(seconds: 30);

  Timer? _timer;
  Duration _progress = Duration.zero;
  bool _isPlaying = false;

  ThumbShape _thumbShape = ThumbShape.circle;
  double _barBorderRadius = 0;
  double _thumbGap = 0;
  double _thumbBarGap = 0;
  bool _enableSineWave = false;
  double _amplitude = 3.0;
  double _cycleCount = 2.0;
  double _speed = 1.0;
  int _waveCount = 1;
  bool _clampToBarBounds = false;
  TimeLabelLocation _timeLabelLocation = TimeLabelLocation.below;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    if (_isPlaying) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        setState(() {
          _progress += const Duration(milliseconds: 200);
          if (_progress >= _totalDuration) {
            _progress = Duration.zero;
          }
        });
      });
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _seek(Duration position) {
    setState(() => _progress = position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('ProgressBar 增强功能演示'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // ---- 进度条展示区 ----
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  ProgressBar(
                    progress: _progress,
                    total: _totalDuration,
                    buffered: _isPlaying
                        ? _progress + const Duration(seconds: 8)
                        : null,
                    thumbShape: _thumbShape,
                    barBorderRadius:
                        _barBorderRadius > 0 ? _barBorderRadius : null,
                    thumbGap: _thumbGap,
                    thumbBarGap: _thumbBarGap,
                    sineWaveConfig:
                        _enableSineWave ? _buildSineConfig() : null,
                    timeLabelLocation: _timeLabelLocation,
                    onSeek: _seek,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow),
                        onPressed: _togglePlay,
                      ),
                      IconButton(
                        icon: const Icon(Icons.replay),
                        onPressed: () =>
                            setState(() => _progress = Duration.zero),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ---- 滑块形状 ----
          _buildSection('滑块形状 (thumbShape)'),
          SegmentedButton<ThumbShape>(
            segments: const [
              ButtonSegment(value: ThumbShape.circle, label: Text('circle')),
              ButtonSegment(value: ThumbShape.line, label: Text('line')),
            ],
            selected: {_thumbShape},
            onSelectionChanged: (v) => setState(() => _thumbShape = v.first),
          ),

          // ---- 时间标签位置 ----
          _buildSection('时间标签位置 (timeLabelLocation)'),
          SegmentedButton<TimeLabelLocation>(
            segments: const [
              ButtonSegment(
                  value: TimeLabelLocation.below, label: Text('below')),
              ButtonSegment(
                  value: TimeLabelLocation.above, label: Text('above')),
              ButtonSegment(
                  value: TimeLabelLocation.sides, label: Text('sides')),
              ButtonSegment(
                  value: TimeLabelLocation.none, label: Text('none')),
            ],
            selected: {_timeLabelLocation},
            onSelectionChanged: (v) =>
                setState(() => _timeLabelLocation = v.first),
          ),

          // ---- 圆角半径 ----
          _buildSection(
              '进度条圆角 (barBorderRadius): ${_barBorderRadius.toStringAsFixed(1)}'),
          Slider(
            value: _barBorderRadius,
            min: 0,
            max: 16,
            onChanged: (v) => setState(() => _barBorderRadius = v),
          ),

          // ---- 滑块间隙 ----
          _buildSection('滑块分段间隙 (thumbGap): ${_thumbGap.toStringAsFixed(1)}'),
          Slider(
            value: _thumbGap,
            min: 0,
            max: 16,
            onChanged: (v) => setState(() => _thumbGap = v),
          ),

          _buildSection(
              '滑块端点间隙 (thumbBarGap): ${_thumbBarGap.toStringAsFixed(1)}'),
          Slider(
            value: _thumbBarGap,
            min: -4,
            max: 12,
            onChanged: (v) => setState(() => _thumbBarGap = v),
          ),

          // ---- 正弦波浪 ----
          SwitchListTile(
            title: const Text('启用正弦波浪 (sineWaveConfig)'),
            value: _enableSineWave,
            onChanged: (v) => setState(() => _enableSineWave = v),
          ),

          if (_enableSineWave) ...[
            _buildSection('振幅 (amplitude): ${_amplitude.toStringAsFixed(1)}'),
            Slider(
              value: _amplitude,
              min: 1,
              max: 8,
              onChanged: (v) => setState(() => _amplitude = v),
            ),
            _buildSection('周期数 (cycleCount): ${_cycleCount.toStringAsFixed(1)}'),
            Slider(
              value: _cycleCount,
              min: 0.5,
              max: 6,
              onChanged: (v) => setState(() => _cycleCount = v),
            ),
            _buildSection('速度 (speed): ${_speed.toStringAsFixed(1)}'),
            Slider(
              value: _speed,
              min: 0.2,
              max: 3,
              onChanged: (v) => setState(() => _speed = v),
            ),
            _buildSection('叠加层数 (waveCount): $_waveCount'),
            Slider(
              value: _waveCount.toDouble(),
              min: 1,
              max: 4,
              divisions: 3,
              onChanged: (v) => setState(() => _waveCount = v.round()),
            ),
            SwitchListTile(
              title: const Text('裁剪到边界 (clampToBarBounds)'),
              value: _clampToBarBounds,
              onChanged: (v) => setState(() => _clampToBarBounds = v),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  SineWaveConfig _buildSineConfig() {
    return SineWaveConfig(
      amplitude: _amplitude,
      cycleCount: _cycleCount,
      speed: _speed,
      waveCount: _waveCount,
      clampToBarBounds: _clampToBarBounds,
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
