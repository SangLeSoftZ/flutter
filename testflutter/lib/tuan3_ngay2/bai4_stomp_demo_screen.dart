import 'dart:convert';
import 'package:flutter/material.dart';
import 'bai4_stomp_service.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 4 — STOMP Demo Screen
// Tuần 3 Ngày 2 (Chiều)
//
// Screen này TEST StompService — cần Spring Boot chạy với
// WebSocket endpoint /ws (cấu hình ở phần Tối hôm nay)
//
// Khi Spring Boot chưa có WebSocket:
//   → Hiện "Lỗi kết nối" — bình thường, chờ phần Tối
//
// Khi Spring Boot đã có WebSocket:
//   → Kết nối thành công → subscribe /topic/tasks
//   → Tạo task mới từ Postman/app → thấy hiện real-time ở đây
// ══════════════════════════════════════════════════════════════════

class StompDemoScreen extends StatefulWidget {
  const StompDemoScreen({super.key});

  @override
  State<StompDemoScreen> createState() => _StompDemoScreenState();
}

class _StompDemoScreenState extends State<StompDemoScreen> {
  final _stompService = StompService();
  final List<String> _taskLogs = [];
  bool _daKetNoi = false;
  String _trangThai = 'Chưa kết nối';

  @override
  void dispose() {
    _stompService.ngatKetNoi();
    super.dispose();
  }

  void _ketNoi() {
    setState(() => _trangThai = 'Đang kết nối tới Spring Boot...');

    _stompService.ketNoi(
      onTask: (jsonBody) {
        // Được gọi mỗi khi server broadcast task mới
        if (mounted) {
          setState(() {
            _daKetNoi = true;
            _trangThai = 'Đã kết nối — đang lắng nghe /topic/tasks';
            try {
              final data = jsonDecode(jsonBody);
              _taskLogs.insert(0,
                  '🆕 Task mới: ${data['tieuDe'] ?? jsonBody}');
            } catch (_) {
              _taskLogs.insert(0, '📨 Nhận: $jsonBody');
            }
          });
        }
      },
    );

    // Giả lập thay đổi UI sau 1 giây (StompClient async)
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _stompService.daKetNoi) {
        setState(() {
          _daKetNoi = true;
          _trangThai = 'Đã kết nối — đang lắng nghe /topic/tasks';
        });
      } else if (mounted && !_daKetNoi) {
        setState(() => _trangThai =
            'Không thể kết nối\nKiểm tra Spring Boot đã có WebSocket chưa');
      }
    });
  }

  void _ngatKetNoi() {
    _stompService.ngatKetNoi();
    setState(() {
      _daKetNoi = false;
      _trangThai = 'Đã ngắt kết nối';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 3 Ngày 2 — STOMP Bài 4'),
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📌 STOMP Client — subscribe /topic/tasks',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  'Cần Spring Boot có WebSocket endpoint /ws\n'
                  'Tạo task mới → server broadcast → hiện real-time ở đây\n'
                  '(Phần Tối: cấu hình Spring Boot STOMP)',
                  style: TextStyle(fontSize: 12, color: Colors.deepPurple),
                ),
              ],
            ),
          ),

          // Trạng thái
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _daKetNoi ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: _daKetNoi
                      ? Colors.green.shade200
                      : Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  _daKetNoi ? Icons.cast_connected : Icons.cast,
                  color: _daKetNoi ? Colors.green : Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _trangThai,
                    style: TextStyle(
                        fontSize: 12,
                        color: _daKetNoi
                            ? Colors.green.shade700
                            : Colors.orange.shade700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Nút kết nối
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor:
                            _daKetNoi ? Colors.red : Colors.deepPurple),
                    onPressed: _daKetNoi ? _ngatKetNoi : _ketNoi,
                    icon: Icon(_daKetNoi ? Icons.stop : Icons.play_arrow),
                    label: Text(_daKetNoi ? 'Ngắt kết nối' : 'Kết nối Spring Boot'),
                  ),
                ),
                if (_daKetNoi) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => setState(() => _taskLogs.clear()),
                    icon: const Icon(Icons.clear_all),
                    tooltip: 'Xóa log',
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1),

          // So sánh STOMP vs WebSocket thuần
          if (!_daKetNoi && _taskLogs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📚 WebSocket thuần vs STOMP',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const Divider(),
                      _compareRow('WebSocket', 'Gửi/nhận byte tự do\nTự phân loại message thủ công', Colors.orange),
                      const SizedBox(height: 6),
                      _compareRow('STOMP', 'Có destination/topic\nSubscribe đúng kênh cần', Colors.green),
                    ],
                  ),
                ),
              ),
            ),

          // Log real-time
          Expanded(
            child: _taskLogs.isEmpty
                ? Center(
                    child: Text(
                      _daKetNoi
                          ? 'Đang lắng nghe /topic/tasks...\nTạo task mới để thấy real-time'
                          : 'Nhấn kết nối để bắt đầu',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _taskLogs.length,
                    itemBuilder: (context, index) => Card(
                      color: Colors.deepPurple.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(_taskLogs[index],
                            style: const TextStyle(fontSize: 13)),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _compareRow(String label, String desc, Color color) {
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
