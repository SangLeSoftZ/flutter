import 'package:flutter/material.dart';
import '../bai4_api/api_client.dart';
import '../bai4_api/task_model.dart';
import 'hero_task_detail_screen.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 3 — Hero Animation: Màn hình Danh sách
// Tuần 2 Ngày 3 (Chiều)
//
// PHÂN BIỆT với home_screen.dart (Tuần 2 Ngày 2):
//   Ngày 2: CircleAvatar bình thường, chuyển màn đột ngột
//   Ngày 3: CircleAvatar bọc trong Hero → "bay" sang màn Chi tiết
//
// QUY TẮC tag:
//   ✅ tag: 'task-icon-${task.id}'  → duy nhất cho từng item
//   ❌ tag: 'task-icon'             → dùng chung → lỗi Multiple heroes
// ══════════════════════════════════════════════════════════════════

class HeroTaskListScreen extends StatefulWidget {
  const HeroTaskListScreen({super.key});

  @override
  State<HeroTaskListScreen> createState() => _HeroTaskListScreenState();
}

class _HeroTaskListScreenState extends State<HeroTaskListScreen> {
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
    setState(() { _isLoading = true; _error = null; });
    try {
      final tasks = await _api.layDanhSachTask();
      setState(() => _tasks = tasks);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'HOAN_THANH': return Colors.green;
      case 'DANG_LAM': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 2 Ngày 3 — Hero Animation'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          // Chú thích
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📌 Hero Animation — Bài 3',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Nhấn vào task → avatar "bay" sang màn Chi tiết'),
                Text(
                  'tag: "task-icon-\${task.id}" — duy nhất mỗi item',
                  style: TextStyle(color: Colors.teal, fontSize: 12,
                      fontFamily: 'monospace'),
                ),
              ],
            ),
          ),

          // Danh sách
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
                            Text(_error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Thử lại'),
                              onPressed: _loadTasks,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          final color = _statusColor(task.trangThai);
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: ListTile(
                              leading: Hero(
                                // ✅ tag duy nhất theo id — bắt buộc
                                // Nếu dùng tag cố định 'task-icon' cho tất cả
                                // → lỗi "Multiple heroes that share the same tag"
                                tag: 'task-icon-${task.id}',
                                //tag: 'task-icon',  // sai — dùng chung
                                child: CircleAvatar(
                                  backgroundColor: color.withOpacity(0.2),
                                  child: Text(
                                    '#${task.id}',
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(task.tieuDe,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                              subtitle: task.moTa.isNotEmpty
                                  ? Text(task.moTa,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis)
                                  : null,
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                // Dùng Navigator.push thay vì go_router
                                // vì Hero hoạt động tốt nhất với push
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        HeroTaskDetailScreen(task: task),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
