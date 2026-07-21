import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 1A — SpringSimulation: thẻ vuốt nảy về vị trí gốc
// Tuần 3 Ngày 5 (Sáng)
//
// PHÂN BIỆT với Curves (Tuần 2 Ngày 3):
//   Curves.easeInOut: luôn chạy đúng duration cố định (VD 300ms)
//   SpringSimulation: tính động theo vận tốc thả tay
//     → vuốt nhanh = về nhanh hơn, có thể "vọt qua" rồi mới về
//     → vuốt chậm = về chậm, mượt
//
// 3 tham số SpringDescription:
//   mass:      khối lượng "vật" — lớn = chậm, "nặng"
//   stiffness: độ cứng lò xo — lớn = kéo về nhanh
//   damping:   độ giảm chấn — lớn = bớt nảy, dừng sớm
// ══════════════════════════════════════════════════════════════════

class SpringSimulationScreen extends StatefulWidget {
  const SpringSimulationScreen({super.key});

  @override
  State<SpringSimulationScreen> createState() => _SpringSimulationScreenState();
}

class _SpringSimulationScreenState extends State<SpringSimulationScreen>
    with SingleTickerProviderStateMixin {
  // AnimationController.unbounded: không giới hạn 0.0-1.0
  // vì vị trí X có thể là bất kỳ giá trị nào (pixel)
  late final AnimationController _controller;
  double _viTriX = 0;

  // Preset để demo khác biệt giữa các thông số
  int _selectedPreset = 1;
  final List<Map<String, dynamic>> _presets = [
    {'name': 'Lò xo mềm\n(nảy nhiều)', 'mass': 1.0, 'stiffness': 50.0, 'damping': 3.0, 'color': Colors.red},
    {'name': 'Cân bằng\n(tự nhiên)', 'mass': 1.0, 'stiffness': 200.0, 'damping': 15.0, 'color': Colors.blue},
    {'name': 'Lò xo cứng\n(về nhanh)', 'mass': 1.0, 'stiffness': 500.0, 'damping': 40.0, 'color': Colors.green},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        // Mỗi frame animation → cập nhật vị trí X
        setState(() => _viTriX = _controller.value);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _khiThaTay(DragEndDetails details) {
    final preset = _presets[_selectedPreset];
    final springDesc = SpringDescription(
      mass: preset['mass'] as double,
      stiffness: preset['stiffness'] as double,
      damping: preset['damping'] as double,
    );

    final simulation = SpringSimulation(
      springDesc,
      _viTriX,                                  // vị trí bắt đầu (đang ở đó khi thả tay)
      0,                                         // vị trí đích (về gốc = 0)
      details.velocity.pixelsPerSecond.dx,       // vận tốc thả tay — đây là điểm khác biệt vs Curves
    );

    // animateWith: chạy theo simulation vật lý, KHÔNG phải duration cố định
    _controller.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    final preset = _presets[_selectedPreset];
    final color = preset['color'] as Color;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 3 Ngày 5 — SpringSimulation Bài 1A'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Chú thích
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.deepPurple.shade200),
            ),
            child: const Text(
              '📌 SpringSimulation — vuốt thẻ rồi thả\n'
              'Thả nhanh → về nhanh (vọt qua rồi mới về)\n'
              'Thả chậm → về chậm, mượt\n'
              'Khác Curves: duration không cố định!',
              style: TextStyle(fontSize: 12),
            ),
          ),

          // Chọn preset
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: List.generate(_presets.length, (i) {
                final p = _presets[i];
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPreset = i;
                        _viTriX = 0;
                        _controller.stop();
                        _controller.value = 0;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _selectedPreset == i
                            ? (p['color'] as Color).withOpacity(0.15)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: _selectedPreset == i
                                ? p['color'] as Color
                                : Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Text(p['name'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: _selectedPreset == i
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _selectedPreset == i
                                      ? p['color'] as Color
                                      : Colors.grey)),
                          const SizedBox(height: 2),
                          Text(
                            's:${p['stiffness'].toInt()} d:${p['damping'].toInt()}',
                            style: const TextStyle(
                                fontSize: 9, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),
          const Text('Vuốt thẻ sang trái/phải rồi thả:',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),

          // Vùng vuốt
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Đường center
                Container(
                  width: 2,
                  color: Colors.grey.shade300,
                ),
                // Thẻ có thể vuốt
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    _controller.stop();
                    setState(() => _viTriX += details.delta.dx);
                  },
                  onHorizontalDragEnd: _khiThaTay,
                  child: Transform.translate(
                    offset: Offset(_viTriX, 0),
                    child: Container(
                      width: 200,
                      height: 100,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.drag_handle,
                              color: Colors.white, size: 28),
                          const SizedBox(height: 4),
                          Text(
                            'X: ${_viTriX.toStringAsFixed(1)}px',
                            style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Thông số hiện tại
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preset: ${preset['name']}'.replaceAll('\n', ' '),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'mass=${preset['mass']}  '
                      'stiffness=${preset['stiffness']}  '
                      'damping=${preset['damping']}',
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
