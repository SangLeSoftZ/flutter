import 'package:flutter/material.dart';
import '../bai4_api/task_model.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 3 — Hero Animation: Màn hình Chi tiết
// Tuần 2 Ngày 3 (Chiều)
//
// Tag phải khớp TUYỆT ĐỐI với màn Danh sách:
//   'task-icon-${task.id}'
//
// Flutter tự tính toán:
//   - Vị trí bay: từ ListTile.leading → trung tâm màn hình
//   - Kích thước: từ 40px (small) → 100px (large)
//   - Hình dạng: CircleAvatar → CircleAvatar (giữ nguyên)
//   Bạn không cần code gì thêm — chỉ cần tag khớp
// ══════════════════════════════════════════════════════════════════

class HeroTaskDetailScreen extends StatelessWidget {
  final Task task;

  const HeroTaskDetailScreen({super.key, required this.task});

  Color get _statusColor {
    switch (task.trangThai) {
      case 'HOAN_THANH': return Colors.green;
      case 'DANG_LAM': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (task.trangThai) {
      case 'HOAN_THANH': return '✅ Hoàn thành';
      case 'DANG_LAM': return '🔄 Đang làm';
      default: return '⏳ Chưa làm';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task #${task.id}'),
        backgroundColor: _statusColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // ── Hero với tag khớp màn danh sách ──────────────
            Hero(
              tag: 'task-icon-${task.id}', // PHẢI khớp với màn Danh sách
              child: CircleAvatar(
                radius: 50, // lớn hơn ở danh sách → Flutter tự animate
                backgroundColor: _statusColor.withOpacity(0.2),
                child: Text(
                  '#${task.id}',
                  style: TextStyle(
                    color: _statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              task.tieuDe,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            if (task.moTa.isNotEmpty) ...[
              Text(
                task.moTa,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],

            Chip(
              label: Text(_statusLabel),
              backgroundColor: _statusColor.withOpacity(0.1),
              side: BorderSide(color: _statusColor.withOpacity(0.5)),
            ),

            const SizedBox(height: 32),

            // Chú thích Hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📌 Hero tag tại màn này:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    'tag: "task-icon-${task.id}"',
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.teal,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Flutter tự tính:\n'
                    '• Vị trí bay: ListTile.leading → giữa màn\n'
                    '• Kích thước: radius 20 → radius 50\n'
                    '• Không cần code thêm gì!',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Bài 4: thử sai tag
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⚠️ Bài 4 — Thử sai tag để thấy lỗi:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.red)),
                  SizedBox(height: 4),
                  Text(
                    '1. Đổi tag danh sách thành "task-icon" (cố định)\n'
                    '   → Lỗi: Multiple heroes share the same tag\n\n'
                    '2. Đổi tag chi tiết thành "task-icon-999" (sai id)\n'
                    '   → Không lỗi, nhưng Hero không animate\n'
                    '   → Rất khó debug nếu không để ý!',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
