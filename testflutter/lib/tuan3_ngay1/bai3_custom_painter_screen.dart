import 'dart:math' as math;
import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 3 — CustomPainter: vòng tròn tiến độ Task
// Tuần 3 Ngày 1 (Chiều)
//
// CustomPainter giải quyết gì:
//   Widget có sẵn không đủ → cần vẽ hoàn toàn tùy biến
//   Toàn quyền kiểm soát Canvas: đường, hình, màu, góc
//
// Các thành phần:
//   Canvas  = khung vải để vẽ lên
//   Paint   = cây cọ (màu, độ dày, kiểu vẽ)
//   shouldRepaint() = tối ưu hiệu năng (chỉ vẽ lại khi cần)
// ══════════════════════════════════════════════════════════════════

// ── CustomPainter: vẽ vòng tròn tiến độ ─────────────────────────
class VongTronTienDoPainter extends CustomPainter {
  final double phanTram;    // 0.0 → 1.0
  final Color mauNen;
  final Color mauTienDo;
  final double doDay;

  VongTronTienDoPainter({
    required this.phanTram,
    this.mauNen = const Color(0xFFE0E0E0),
    this.mauTienDo = Colors.blue,
    this.doDay = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - doDay / 2;

    // ── Vẽ vòng nền (màu xám) ─────────────────────────────────
    final paintNen = Paint()
      ..color = mauNen
      ..style = PaintingStyle.stroke  // chỉ viền, không tô đầy
      ..strokeWidth = doDay;
    canvas.drawCircle(center, radius, paintNen);

    // ── Vẽ cung tiến độ (màu chính) ───────────────────────────
    final paintTienDo = Paint()
      ..color = mauTienDo
      ..style = PaintingStyle.stroke
      ..strokeWidth = doDay
      ..strokeCap = StrokeCap.round;  // đầu cung bo tròn

    // startAngle = -pi/2 = đỉnh trên (12 giờ)
    // sweepAngle = 2*pi * phanTram (ví dụ: 0.75 → 270 độ)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,           // bắt đầu từ đỉnh trên
      2 * math.pi * phanTram, // quét theo chiều kim đồng hồ
      false,                   // false = không nối tâm
      paintTienDo,
    );

    // ── Vẽ text % ở giữa ──────────────────────────────────────
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(phanTram * 100).round()}%',
        style: TextStyle(
          fontSize: size.width * 0.22,
          fontWeight: FontWeight.bold,
          color: mauTienDo,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  // ✅ Chỉ vẽ lại khi phanTram thực sự thay đổi
  // Nếu return true luôn → vẽ lại mỗi frame dù không đổi (xem Bài 4)
  bool shouldRepaint(VongTronTienDoPainter oldDelegate) {
    return oldDelegate.phanTram != phanTram;
  }
}

// ── Màn hình demo ─────────────────────────────────────────────────
class CustomPainterScreen extends StatefulWidget {
  const CustomPainterScreen({super.key});

  @override
  State<CustomPainterScreen> createState() => _CustomPainterScreenState();
}

class _CustomPainterScreenState extends State<CustomPainterScreen>
    with SingleTickerProviderStateMixin {
  // Dữ liệu task giả lập
  final List<Map<String, dynamic>> _tasks = [
    {'ten': 'Học Flutter', 'hoanThanh': 7, 'tong': 10},
    {'ten': 'Spring Boot', 'hoanThanh': 3, 'tong': 8},
    {'ten': 'Clean Code', 'hoanThanh': 5, 'tong': 5},
  ];

  // AnimationController cho animation khi load
  late AnimationController _controller;
  late Animation<double> _animation;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _phanTram {
    final task = _tasks[_selectedIndex];
    return (task['hoanThanh'] as int) / (task['tong'] as int);
  }

  Color get _mauTienDo {
    if (_phanTram >= 1.0) return Colors.green;
    if (_phanTram >= 0.5) return Colors.blue;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 3 Ngày 1 — CustomPainter Bài 3'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Chú thích
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📌 CustomPainter — vòng tròn tiến độ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(
                    'Canvas = khung vải  |  Paint = cây cọ\n'
                    'shouldRepaint() → chỉ vẽ lại khi phanTram đổi',
                    style: TextStyle(fontSize: 12, color: Colors.teal),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Vòng tròn tiến độ chính với animation
            AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                return CustomPaint(
                  size: const Size(180, 180),
                  painter: VongTronTienDoPainter(
                    phanTram: _phanTram * _animation.value,
                    mauTienDo: _mauTienDo,
                    doDay: 14,
                  ),
                );
              },
            ),

            const SizedBox(height: 8),
            Text(
              _tasks[_selectedIndex]['ten'] as String,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${_tasks[_selectedIndex]['hoanThanh']}/${_tasks[_selectedIndex]['tong']} tasks hoàn thành',
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // Chọn task category
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_tasks.length, (index) {
                final task = _tasks[index];
                final pt = (task['hoanThanh'] as int) / (task['tong'] as int);
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedIndex = index);
                    _controller.forward(from: 0);
                  },
                  child: Column(
                    children: [
                      // Vòng tròn nhỏ cho mỗi category
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (_, __) => CustomPaint(
                          size: const Size(70, 70),
                          painter: VongTronTienDoPainter(
                            phanTram: index == _selectedIndex
                                ? pt * _animation.value
                                : pt,
                            mauTienDo: index == _selectedIndex
                                ? _mauTienDo
                                : Colors.grey,
                            doDay: 7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(task['ten'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: index == _selectedIndex
                                ? FontWeight.bold
                                : FontWeight.normal,
                          )),
                    ],
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // Giải thích drawArc
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📚 drawArc() — tham số',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Divider(),
                    _paramRow('rect', 'Hình chữ nhật bao quanh cung'),
                    _paramRow('startAngle', '-π/2 = đỉnh 12 giờ'),
                    _paramRow('sweepAngle', '2π × % = góc quét'),
                    _paramRow('useCenter', 'false = không nối tâm'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paramRow(String param, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Text(param,
                style: const TextStyle(
                    fontFamily: 'monospace', fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Text(desc, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
