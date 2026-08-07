import 'package:flutter/material.dart';
import 'api_client.dart';
import 'task_model.dart';

/// Màn hình demo gọi API: hiển thị danh sách Task và cho phép tạo Task mới.
class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final ApiClient _api = ApiClient();
  final TextEditingController _controller = TextEditingController();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _layDanhSach(); // Tự động load khi mở màn hình
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ─── Gọi GET /tasks ────────────────────────────────────────────────────────

  Future<void> _layDanhSach() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tasks = await _api.layDanhSachTask();
      setState(() => _tasks = tasks);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ─── Gọi POST /tasks ───────────────────────────────────────────────────────

  Future<void> _taoTask() async {
    final tieuDe = _controller.text.trim();
    if (tieuDe.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tiêu đề không được để trống!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final taskMoi = await _api.taoTask(tieuDe);
      _controller.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã tạo task #${taskMoi.id}: ${taskMoi.tieuDe}'),
          backgroundColor: Colors.green,
        ),
      );
      // Reload lại danh sách sau khi tạo
      await _layDanhSach();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ─── Build UI ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task API Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Nút refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại danh sách',
            onPressed: _isLoading ? null : _layDanhSach,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Ô nhập tiêu đề + nút tạo ──
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tiêu đề tác vụ mới...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _taoTask(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _taoTask,
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo'),
                ),
              ],
            ),
          ),

          // ── Thông báo lỗi ──
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          const Divider(height: 16),

          // ── Danh sách task ──
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _tasks.isEmpty
                    ? const Center(
                      child: Text(
                        'Chưa có tác vụ nào.\nNhấn "Tạo" để thêm mới!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return _TaskCard(task: task);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget card hiển thị 1 task ─────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final Task task;
  const _TaskCard({required this.task});

  Color get _statusColor {
    switch (task.trangThai) {
      case 'HOAN_THANH':
        return Colors.green;
      case 'DANG_LIEM':
        return Colors.orange;
      default: // CHUA_XONG
        return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (task.trangThai) {
      case 'HOAN_THANH':
        return 'Hoàn thành';
      case 'DANG_LIEM':
        return 'Đang làm';
      default:
        return 'Chưa xong';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor.withValues(alpha: 0.15),
          child: Text(
            '#${task.id}',
            style: TextStyle(
              color: _statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          task.tieuDe,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: task.moTa.isNotEmpty ? Text(task.moTa) : null,
        trailing: Chip(
          label: Text(_statusLabel, style: const TextStyle(fontSize: 11)),
          backgroundColor: _statusColor.withValues(alpha: 0.1),
          side: BorderSide(color: _statusColor.withValues(alpha: 0.4)),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
