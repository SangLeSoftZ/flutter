import 'package:flutter/material.dart';
import '../bai4_api/task_model.dart';

// ══════════════════════════════════════════════════════════════════
// CUSTOM WIDGET: TaskCard — Tuần 2 Ngày 4 (Sáng)
//
// NGUYÊN TẮC "DUMB WIDGET":
//   ✅ Nhận dữ liệu qua constructor (task, onXoa, onTap)
//   ❌ KHÔNG tự gọi context.read<TaskCubit>() bên trong
//
// Lý do:
//   - Tái sử dụng ở bất kỳ màn hình nào (kể cả không có TaskCubit)
//   - Dễ test: chỉ cần truyền Task giả vào, không cần setup Cubit
//   - Sửa UI 1 chỗ → áp dụng mọi nơi (DRY principle)
//
// const constructor:
//   Khi tham số không đổi, Flutter bỏ qua rebuild → tăng hiệu năng
// ══════════════════════════════════════════════════════════════════

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onXoa;       // nullable — không phải màn hình nào cũng có nút xóa
  final VoidCallback? onTap;       // nullable — không phải màn hình nào cũng navigate
  final bool showDeleteButton;

  const TaskCard({
    super.key,
    required this.task,
    this.onXoa,
    this.onTap,
    this.showDeleteButton = true,
  });

  Color get _statusColor {
    switch (task.trangThai) {
      case 'HOAN_THANH': return Colors.green;
      case 'DANG_LAM':   return Colors.orange;
      default:           return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (task.trangThai) {
      case 'HOAN_THANH': return 'Hoàn thành';
      case 'DANG_LAM':   return 'Đang làm';
      default:           return 'Chưa làm';
    }
  }

  IconData get _statusIcon {
    switch (task.trangThai) {
      case 'HOAN_THANH': return Icons.check_circle;
      case 'DANG_LAM':   return Icons.pending;
      default:           return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          _statusIcon,
          color: _statusColor,
          size: 32,
        ),
        title: Text(
          task.tieuDe,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: task.moTa.isNotEmpty
            ? Text(task.moTa, maxLines: 2, overflow: TextOverflow.ellipsis)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(_statusLabel,
                  style: const TextStyle(fontSize: 11)),
              backgroundColor: _statusColor.withOpacity(0.1),
              side: BorderSide(color: _statusColor.withOpacity(0.4)),
              padding: EdgeInsets.zero,
            ),
            if (showDeleteButton && onXoa != null) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onXoa,
                tooltip: 'Xóa task',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
