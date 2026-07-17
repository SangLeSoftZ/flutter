import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 1 — Isolates: UI đơ vs UI mượt
// Tuần 3 Ngày 1 (Sáng)
//
// PHÂN BIỆT async/await vs Isolate:
//   async/await → giải quyết CHỜ ĐỢI (mạng, file)
//                 luồng chính rảnh trong lúc chờ
//   Isolate     → giải quyết TÍNH TOÁN NẶNG (CPU liên tục)
//                 async/await KHÔNG giúp được gì với loại này
//
// compute() làm gì:
//   1. Tạo Isolate mới với bộ nhớ riêng
//   2. Gửi argument sang isolate đó (copy dữ liệu)
//   3. Chạy function hoàn toàn trên isolate riêng
//   4. Gửi kết quả trả về luồng chính
//   → Luồng chính hoàn toàn rảnh suốt quá trình
// ══════════════════════════════════════════════════════════════════

// ── Hàm tính toán nặng — PHẢI là top-level hoặc static ──────────
// Lý do: Isolate mới không có quyền truy cập bộ nhớ của isolate gốc
// → cần hàm "độc lập", không phụ thuộc `this` hay bất kỳ instance nào
int tinhTongNang(int soLuong) {
  int tong = 0;
  for (int i = 0; i < soLuong; i++) {
    tong += i;
  }
  return tong;
}

class IsolateDemoScreen extends StatefulWidget {
  const IsolateDemoScreen({super.key});

  @override
  State<IsolateDemoScreen> createState() => _IsolateDemoScreenState();
}

class _IsolateDemoScreenState extends State<IsolateDemoScreen> {
  static const int _soLuong = 500000000; // 500 triệu số — đủ để thấy UI đơ trên debug mode
  String _ketQua = 'Chưa tính';
  bool _dangTinh = false;
  int _counter = 0; // để test UI có đơ không

  // ── Bài 1a: Chạy TRỰC TIẾP trên luồng chính → UI đơ ──────────
  void _tinhTrucTiep() {
    setState(() { _dangTinh = true; _ketQua = 'Đang tính...'; });

    // Chạy thẳng trên main isolate → UI ĐÓNG BĂNG
    // Thử nhấn nút Counter lúc này → không phản hồi
    final ketQua = tinhTongNang(_soLuong);

    setState(() {
      _dangTinh = false;
      _ketQua = 'Kết quả (luồng chính): $ketQua\n⚠️ UI bị đơ lúc tính!';
    });
  }

  // ── Bài 1b: Dùng compute() → UI mượt ─────────────────────────
  Future<void> _tinhVoiCompute() async {
    setState(() { _dangTinh = true; _ketQua = 'Đang tính (isolate)...'; });

    // compute() chạy tinhTongNang trên Isolate riêng
    // Luồng chính hoàn toàn rảnh → UI vẫn mượt
    // Thử nhấn nút Counter lúc này → vẫn phản hồi bình thường
    final ketQua = await compute(tinhTongNang, _soLuong);

    setState(() {
      _dangTinh = false;
      _ketQua = 'Kết quả (isolate): $ketQua\n✅ UI vẫn mượt trong lúc tính!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 3 Ngày 1 — Isolates Bài 1'),
        backgroundColor: Colors.deepOrange,
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
                color: Colors.deepOrange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepOrange.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📌 Bài 1: UI đơ vs UI mượt',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Tính tổng 50 triệu số'),
                  Text(
                    'Trong lúc tính: nhấn nút Counter bên dưới\n'
                    '→ Luồng chính: Counter KHÔNG phản hồi (UI đơ)\n'
                    '→ compute(): Counter vẫn tăng được (UI mượt)',
                    style: TextStyle(fontSize: 12, color: Colors.deepOrange),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Counter để test UI có đơ không
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Test UI response:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Counter: $_counter',
                            style: const TextStyle(fontSize: 20)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => _counter++),
                      child: const Text('Tăng'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Kết quả
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(_ketQua,
                  style: const TextStyle(fontFamily: 'monospace')),
            ),
            const SizedBox(height: 24),

            // Nút hành động
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _dangTinh ? null : _tinhTrucTiep,
                    icon: const Icon(Icons.warning_amber),
                    label: const Text('Luồng chính\n(UI đơ)',
                        textAlign: TextAlign.center),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _dangTinh ? null : _tinhVoiCompute,
                    icon: _dangTinh
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_circle),
                    label: const Text('compute()\n(UI mượt)',
                        textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            // Giải thích
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📚 async/await vs Isolate',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Divider(),
                    _row('async/await', 'Giải quyết CHỜ ĐỢI\n(mạng, file I/O)', Colors.blue),
                    const SizedBox(height: 6),
                    _row('compute()', 'Giải quyết TÍNH TOÁN NẶNG\n(CPU liên tục)', Colors.green),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String desc, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color),
          ),
          child: Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(desc, style: const TextStyle(fontSize: 12))),
      ],
    );
  }
}
