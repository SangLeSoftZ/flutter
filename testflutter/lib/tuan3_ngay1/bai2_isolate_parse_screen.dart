import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 2 — Isolates: parse JSON lớn với compute()
// Tuần 3 Ngày 1 (Sáng)
//
// Ứng dụng thực tế: parse danh sách 1000 Task từ JSON
// Nếu parse trực tiếp → UI đơ trong lúc parse
// Dùng compute() → parse trên isolate riêng, UI vẫn mượt
// ══════════════════════════════════════════════════════════════════

// ── Model đơn giản cho bài này ────────────────────────────────────
class TaskItem {
  final int id;
  final String tieuDe;
  final String moTa;
  final bool hoanThanh;

  const TaskItem({
    required this.id,
    required this.tieuDe,
    required this.moTa,
    required this.hoanThanh,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) => TaskItem(
        id: json['id'] as int,
        tieuDe: json['tieuDe'] as String,
        moTa: json['moTa'] as String,
        hoanThanh: json['hoanThanh'] as bool,
      );
}

// ── Hàm parse JSON — PHẢI là top-level ────────────────────────────
// Không thể là method của class vì Isolate không truy cập được `this`
List<TaskItem> parseJsonList(String jsonString) {
  final List<dynamic> data = jsonDecode(jsonString) as List<dynamic>;
  // Giả lập xử lý nặng: mỗi item tính thêm vài phép tính
  // Để thấy rõ sự khác biệt giữa luồng chính và isolate
  return data.map((item) {
    final map = item as Map<String, dynamic>;
    // Tính toán nhẹ cho mỗi item để tạo tải CPU
    var dummy = 0;
    for (var i = 0; i < 1000; i++) {
      dummy += i;
    }
    dummy.toString(); // tránh compiler optimize away
    return TaskItem.fromJson(map);
  }).toList();
}

// ── Tạo JSON giả lập (1000 task) ─────────────────────────────────
String taoChuoiJsonLon(int soLuong) {
  final list = List.generate(soLuong, (i) => {
    'id': i + 1,
    'tieuDe': 'Task số ${i + 1}',
    'moTa': 'Mô tả chi tiết cho task số ${i + 1} trong danh sách dài',
    'hoanThanh': i % 3 == 0,
  });
  return jsonEncode(list);
}

class IsolateParseScreen extends StatefulWidget {
  const IsolateParseScreen({super.key});

  @override
  State<IsolateParseScreen> createState() => _IsolateParseScreenState();
}

class _IsolateParseScreenState extends State<IsolateParseScreen> {
  static const int _soLuongTask = 50000; // 50k items — đủ nặng để thấy UI đơ
  List<TaskItem> _tasks = [];
  bool _dangParse = false;
  String _thoiGian = '';
  String _phuongPhap = '';
  int _counter = 0;

  // ── Parse trực tiếp trên luồng chính ─────────────────────────
  void _parseTrucTiep() {
    setState(() { _dangParse = true; _thoiGian = ''; _tasks = []; });

    final jsonString = taoChuoiJsonLon(_soLuongTask);
    final stopwatch = Stopwatch()..start();

    // Parse ngay trên main isolate → UI đơ
    final result = parseJsonList(jsonString);
    stopwatch.stop();

    setState(() {
      _tasks = result;
      _dangParse = false;
      _phuongPhap = '⚠️ Luồng chính';
      _thoiGian = '${stopwatch.elapsedMilliseconds}ms (UI bị đơ)';
    });
  }

  // ── Parse bằng compute() trên isolate riêng ───────────────────
  Future<void> _parseVoiCompute() async {
    setState(() { _dangParse = true; _thoiGian = ''; _tasks = []; });

    final jsonString = taoChuoiJsonLon(_soLuongTask);
    final stopwatch = Stopwatch()..start();

    // compute() gửi jsonString sang isolate mới, chạy parseJsonList
    // Luồng chính rảnh → thử nhấn Counter trong lúc này
    final result = await compute(parseJsonList, jsonString);
    stopwatch.stop();

    setState(() {
      _tasks = result;
      _dangParse = false;
      _phuongPhap = '✅ compute()';
      _thoiGian = '${stopwatch.elapsedMilliseconds}ms (UI mượt)';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 3 Ngày 1 — Isolates Bài 2'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Chú thích
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.indigo.shade200),
                  ),
                  child: Text(
                    '📌 Bài 2: Parse $_soLuongTask tasks từ JSON\n'
                    'Trong lúc parse → nhấn Counter để test UI\n'
                    'parseJsonList() phải là top-level vì Isolate không truy cập được this',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),

                // Counter test
                Row(
                  children: [
                    Text('Counter: $_counter  ',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      onPressed: () => setState(() => _counter++),
                      child: const Text('Tăng'),
                    ),
                    const Spacer(),
                    if (_thoiGian.isNotEmpty) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_phuongPhap,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
                          Text(_thoiGian,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // Nút hành động
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        onPressed: _dangParse ? null : _parseTrucTiep,
                        icon: const Icon(Icons.warning_amber, size: 16),
                        label: const Text('Luồng chính'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.indigo),
                        onPressed: _dangParse ? null : _parseVoiCompute,
                        icon: _dangParse
                            ? const SizedBox(
                                width: 14, height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.rocket_launch, size: 16),
                        label: const Text('compute()'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Danh sách kết quả
          Expanded(
            child: _dangParse
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                    ? const Center(
                        child: Text('Nhấn nút để parse JSON',
                            style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: task.hoanThanh
                                  ? Colors.green.shade100
                                  : Colors.grey.shade200,
                              child: Icon(
                                task.hoanThanh
                                    ? Icons.check
                                    : Icons.circle_outlined,
                                size: 14,
                                color: task.hoanThanh
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                            ),
                            title: Text(task.tieuDe,
                                style: const TextStyle(fontSize: 13)),
                            subtitle: Text(task.moTa,
                                style: const TextStyle(fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '${_tasks.length} tasks đã parse',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
