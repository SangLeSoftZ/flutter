import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../bai4_api/api_client.dart';
import '../../bai4_api/task_model.dart';

// ══════════════════════════════════════════════════════════════════
// MÀN HÌNH HOME — load task thật từ database qua ApiClient
//
// Dùng PUSH (không phải go) để vào Task Detail vì:
//   - Người dùng CẦN back lại danh sách
//   - push() giữ /home trong stack
// ══════════════════════════════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiClient _api = ApiClient();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final tasks = await _api.layDanhSachTask();
      setState(() => _tasks = tasks);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'HOAN_THANH': return Colors.green;
      case 'DANG_LAM':   return Colors.orange;
      default:           return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'HOAN_THANH': return 'Hoàn thành';
      case 'DANG_LAM':   return 'Đang làm';
      case 'CHUA_LAM':   return 'Chưa làm';
      default:           return status; // hiện giá trị gốc nếu không khớp
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏠 Home — Tasks từ database'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTasks,
            tooltip: 'Tải lại',
          ),
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chú thích
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📌 Route: /home',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Task load từ database qua ApiClient'),
                  Text('Nhấn task → context.push("/tasks/:id")',
                      style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Danh sách Task',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Nội dung chính
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                _error!.contains('Connection refused')
                                    ? '📵 Không kết nối được server\nKiểm tra Spring Boot đang chạy không?'
                                    : _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('Thử lại'),
                                onPressed: _loadTasks,
                              ),
                            ],
                          ),
                        )
                      : _tasks.isEmpty
                          ? const Center(
                              child: Text('Chưa có task nào trong database',
                                  style: TextStyle(color: Colors.grey)))
                          : ListView.builder(
                              itemCount: _tasks.length,
                              itemBuilder: (context, index) {
                                final task = _tasks[index];
                                final color = _statusColor(task.trangThai);
                                return Card(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: color.withOpacity(0.15),
                                      child: Text(
                                        '#${task.id}',
                                        style: TextStyle(
                                          color: color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    title: Text(task.tieuDe,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    subtitle: task.moTa.isNotEmpty
                                        ? Text(task.moTa)
                                        : null,
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Chip(
                                          label: Text(_statusLabel(task.trangThai),
                                              style: const TextStyle(fontSize: 11)),
                                          backgroundColor: color.withOpacity(0.1),
                                          side: BorderSide(
                                              color: color.withOpacity(0.4)),
                                          padding: EdgeInsets.zero,
                                        ),
                                        const Icon(Icons.chevron_right),
                                      ],
                                    ),
                                    onTap: () {
                                      // ✅ DÙNG push() — giữ /home trong stack
                                      // Truyền toàn bộ task object qua extra
                                      context.push(
                                        '/tasks/${task.id}',
                                        extra: task,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
