import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 1 — AnimatedContainer
// Tuần 2 Ngày 3 (Sáng): Implicit Animation
// ══════════════════════════════════════════════════════════════════

class AnimatedBoxScreen extends StatefulWidget {
  const AnimatedBoxScreen({super.key});

  @override
  State<AnimatedBoxScreen> createState() => _AnimatedBoxScreenState();
}

class _AnimatedBoxScreenState extends State<AnimatedBoxScreen> {
  bool _phongTo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 2 Ngày 3 — AnimatedContainer'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📌 AnimatedContainer — Implicit Animation',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('Nhấn vào hộp để animate'),
                    Text('duration: 300ms  |  curve: easeInOut',
                        style: TextStyle(color: Colors.purple, fontSize: 12)),
                    SizedBox(height: 4),
                    Text(
                      'Cách hoạt động: setState() → build() chạy lại\n'
                      '→ AnimatedContainer tự tạo Tween ngầm\n'
                      '→ Animate từ giá trị cũ → mới trong 300ms\n'
                      '→ Không cần AnimationController!',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: () => setState(() => _phongTo = !_phongTo),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: _phongTo ? 200 : 100,
                height: _phongTo ? 200 : 100,
                decoration: BoxDecoration(
                  color: _phongTo ? Colors.blue : Colors.red,
                  borderRadius: BorderRadius.circular(_phongTo ? 40 : 8),
                ),
                child: Center(
                  child: Text(
                    _phongTo ? 'Thu lại' : 'Phóng to',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📚 Curve là gì?',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const Divider(),
                      _curveRow('easeInOut', 'Chậm→Nhanh→Chậm  ✅ Tự nhiên nhất', Colors.green),
                      _curveRow('easeIn', 'Chậm→Nhanh  — dùng khi exit', Colors.orange),
                      _curveRow('easeOut', 'Nhanh→Chậm  — dùng khi enter', Colors.blue),
                      _curveRow('linear', 'Đều đều  ❌ Cảm giác máy móc', Colors.red),
                      _curveRow('bounceOut', 'Nảy cuối  — vui, playful', Colors.purple),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _curveRow(String name, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 90,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Text(name,
                style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(desc, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
