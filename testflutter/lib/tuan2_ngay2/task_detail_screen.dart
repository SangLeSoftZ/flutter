import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../bai4_api/task_model.dart';

// ══════════════════════════════════════════════════════════════════
// MÀN HÌNH TASK DETAIL — hiển thị thông tin task thật từ database
//
// Nhận task object qua go_router extra (từ context.push extra:)
// Fallback dùng taskId nếu extra null
// ══════════════════════════════════════════════════════════════════

class TaskDetailScreen extends StatelessWidget {
  final String taskId;
  final Task? task; // nhận từ extra — có đầy đủ thông tin

  const TaskDetailScreen({
    super.key,
    required this.taskId,
    this.task,
  });

  Color get _statusColor {
    switch (task?.trangThai) {
      case 'HOAN_THANH': return Colors.green;
      case 'DANG_LAM':   return Colors.orange;
      default:           return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (task?.trangThai) {
      case 'HOAN_THANH': return '✅ Hoàn thành';
      case 'DANG_LAM':   return '🔄 Đang làm';
      default:           return '⏳ Chưa làm';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📋 Task #$taskId'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chú thích route
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📌 Route: /tasks/:id',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Đang xem: /tasks/$taskId'),
                  const Text('→ Nhấn back = context.pop() về /home',
                      style: TextStyle(color: Colors.orange)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Thông tin task thật từ database
            if (task != null) ...[
              Text(
                task!.tieuDe,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (task!.moTa.isNotEmpty) ...[
                const Text('Mô tả:',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(task!.moTa, style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  const Text('Trạng thái: ',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Chip(
                    label: Text(_statusLabel),
                    backgroundColor: _statusColor.withOpacity(0.1),
                    side: BorderSide(color: _statusColor.withOpacity(0.5)),
                  ),
                ],
              ),
            ] else ...[
              Text(
                'Task #$taskId',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Không có thông tin chi tiết',
                  style: TextStyle(color: Colors.grey)),
            ],

            const SizedBox(height: 32),
            const _GoVsPushCard(),
          ],
        ),
      ),
    );
  }
}

class _GoVsPushCard extends StatelessWidget {
  const _GoVsPushCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📚 go vs push — tóm tắt',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Divider(),
            _row('context.go()',
                'Xóa stack cũ\nDùng khi đổi khu vực\nVD: Login → Home',
                Colors.deepPurple),
            const SizedBox(height: 8),
            _row('context.push()',
                'Giữ stack cũ\nDùng khi đào sâu\nVD: Home → Task Detail',
                Colors.green),
            const SizedBox(height: 8),
            _row('context.pop()',
                'Quay lại màn trước\nChỉ dùng sau push()',
                Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _row(String method, String desc, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color),
          ),
          child: Text(method,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace')),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(desc, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}
