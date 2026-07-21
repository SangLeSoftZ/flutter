import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../bai4_api/api_client.dart';
import '../bai4_api/task_model.dart';
import '../login/data/datasources/auth_local_datasource.dart';
import 'auth_state.dart';

// ══════════════════════════════════════════════════════════════════
// HOME SCREEN GUARD — Tuần 2 Ngày 2 (Chiều)
//
// KHÁC với tuan2_ngay2/home_screen.dart (buổi sáng):
//   Logout: authState.capNhat(false) → go_router tự redirect về /login
//   Màn hình này CHỈ hiện được khi đã đăng nhập (route guard bảo vệ)
// ══════════════════════════════════════════════════════════════════

class HomeScreenGuard extends StatefulWidget {
  const HomeScreenGuard({super.key});

  @override
  State<HomeScreenGuard> createState() => _HomeScreenGuardState();
}

class _HomeScreenGuardState extends State<HomeScreenGuard> {
  final ApiClient _api = ApiClient();
  final AuthLocalDataSource _authLocal = AuthLocalDataSource();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final info = await _authLocal.getAuthInfo();
      _username = info['username'] ?? 'User';
      final tasks = await _api.layDanhSachTask();
      setState(() => _tasks = tasks);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _authLocal.clearAuthInfo();
    // ✅ KHÁC BIỆT CHÍNH: authState.capNhat(false) → go_router tự redirect
    authState.capNhat(false);
    // Không cần context.go('/login') — router tự xử lý
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'HOAN_THANH': return Colors.green;
      case 'DANG_LAM': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'HOAN_THANH': return 'Hoàn thành';
      case 'DANG_LAM': return 'Đang làm';
      default: return 'Chưa làm';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🏠 Home — $_username'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _loadData),
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📌 Route Guard — /home', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Màn này CHỈ hiện khi đã đăng nhập'),
                  Text('Logout → authState.capNhat(false) → tự về /login',
                      style: TextStyle(color: Colors.teal)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Danh sách Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 12),
                              Text(_error!, textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red)),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: const Text('Thử lại'),
                                onPressed: _loadData,
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
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: color.withOpacity(0.15),
                                  child: Text('#${task.id}',
                                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                                title: Text(task.tieuDe,
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: task.moTa.isNotEmpty ? Text(task.moTa) : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Chip(
                                      label: Text(_statusLabel(task.trangThai),
                                          style: const TextStyle(fontSize: 11)),
                                      backgroundColor: color.withOpacity(0.1),
                                      side: BorderSide(color: color.withOpacity(0.4)),
                                      padding: EdgeInsets.zero,
                                    ),
                                    const Icon(Icons.chevron_right),
                                  ],
                                ),
                                onTap: () => context.push('/tasks/${task.id}', extra: task),
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
