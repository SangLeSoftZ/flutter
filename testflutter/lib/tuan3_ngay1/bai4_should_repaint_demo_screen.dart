import 'dart:math' as math;
import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 4 — shouldRepaint(): tối ưu hiệu năng CustomPainter
// Tuần 3 Ngày 1 (Chiều)
//
// Dùng ValueNotifier để đếm paint() từ bên ngoài
// KHÔNG gọi setState từ trong paint() → tránh infinite loop
// ══════════════════════════════════════════════════════════════════

class _CirclePainter extends CustomPainter {
  final double phanTram;
  final Color color;
  final bool alwaysRepaint;
  final ValueNotifier<int> paintCounter; // đếm bằng ValueNotifier, không setState

  _CirclePainter({
    required this.phanTram,
    required this.color,
    required this.alwaysRepaint,
    required this.paintCounter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Tăng counter mà không trigger rebuild của parent widget
    paintCounter.value++;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = color.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * phanTram,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );

    final tp = TextPainter(
      text: TextSpan(
        text: '${(phanTram * 100).round()}%',
        style: TextStyle(
            fontSize: size.width * 0.2,
            fontWeight: FontWeight.bold,
            color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_CirclePainter old) {
    if (alwaysRepaint) return true;          // ❌ luôn vẽ lại
    return old.phanTram != phanTram;         // ✅ chỉ vẽ lại khi % đổi
  }
}

class ShouldRepaintDemoScreen extends StatefulWidget {
  const ShouldRepaintDemoScreen({super.key});

  @override
  State<ShouldRepaintDemoScreen> createState() => _ShouldRepaintDemoScreenState();
}

class _ShouldRepaintDemoScreenState extends State<ShouldRepaintDemoScreen> {
  double _phanTram = 0.6;
  int _rebuildCount = 0;

  // ValueNotifier: thay đổi giá trị mà KHÔNG trigger rebuild của parent
  // ValueListenableBuilder bên dưới chỉ rebuild đúng chỗ hiển thị số
  final _doCounter = ValueNotifier<int>(0);
  final _xanhCounter = ValueNotifier<int>(0);

  @override
  void dispose() {
    _doCounter.dispose();
    _xanhCounter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài 4 — shouldRepaint demo'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: const Text(
                '📌 Nhấn "Rebuild không đổi %" nhiều lần:\n'
                '  ❌ Đỏ: paint() vẫn được gọi (lãng phí)\n'
                '  ✅ Xanh: paint() KHÔNG được gọi thêm\n\n'
                'Kéo slider: cả 2 đều vẽ lại (phanTram đổi)',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Text('Tiến độ: '),
                Expanded(
                  child: Slider(
                    value: _phanTram,
                    onChanged: (val) => setState(() => _phanTram = val),
                  ),
                ),
                Text('${(_phanTram * 100).round()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),

            // 2 painter song song
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // ❌ Không tối ưu
                Column(
                  children: [
                    const Text('❌ shouldRepaint = true',
                        style: TextStyle(color: Colors.red, fontSize: 12)),
                    const SizedBox(height: 8),
                    CustomPaint(
                      size: const Size(130, 130),
                      painter: _CirclePainter(
                        phanTram: _phanTram,
                        color: Colors.red,
                        alwaysRepaint: true,
                        paintCounter: _doCounter,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // ValueListenableBuilder chỉ rebuild Text này, không rebuild toàn màn hình
                    ValueListenableBuilder<int>(
                      valueListenable: _doCounter,
                      builder: (_, val, __) => Text(
                        'paint() gọi: $val lần',
                        style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),

                // ✅ Tối ưu
                Column(
                  children: [
                    const Text('✅ shouldRepaint đúng',
                        style: TextStyle(color: Colors.green, fontSize: 12)),
                    const SizedBox(height: 8),
                    CustomPaint(
                      size: const Size(130, 130),
                      painter: _CirclePainter(
                        phanTram: _phanTram,
                        color: Colors.green,
                        alwaysRepaint: false,
                        paintCounter: _xanhCounter,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<int>(
                      valueListenable: _xanhCounter,
                      builder: (_, val, __) => Text(
                        'paint() gọi: $val lần',
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text('Số lần rebuild: $_rebuildCount',
                style: const TextStyle(fontSize: 14)),

            // Tổng kết
            const SizedBox(height: 8),
            ValueListenableBuilder<int>(
              valueListenable: _doCounter,
              builder: (_, doVal, __) => ValueListenableBuilder<int>(
                valueListenable: _xanhCounter,
                builder: (_, xanhVal, __) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Sau $_rebuildCount lần rebuild:\n'
                      '  Đỏ vẽ lại $doVal lần\n'
                      '  Xanh vẽ lại $xanhVal lần\n\n'
                      'Chênh lệch: ${doVal - xanhVal} lần vẽ thừa\n'
                      '→ App thật 60fps: tiết kiệm đáng kể CPU',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.deepPurple),
                icon: const Icon(Icons.refresh),
                label: const Text('Rebuild KHÔNG đổi % — nhấn nhiều lần'),
                onPressed: () => setState(() => _rebuildCount++),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
