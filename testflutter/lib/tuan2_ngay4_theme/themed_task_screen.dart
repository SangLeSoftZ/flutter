import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../tuan2_ngay1/theme_cubit.dart';
import '../bai4_api/api_client.dart';
import '../bai4_api/task_model.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 4 — Màn hình dùng Theme.of(context) thay vì hardcode màu
// Tuần 2 Ngày 4 (Chiều): Theming
//
// PHÂN BIỆT với các màn hình trước:
//   Trước: màu hardcode → Colors.green, Colors.orange, Colors.white
//   Bài 4: lấy từ Theme → Theme.of(context).colorScheme.primary
//
// Lỗi hay gặp khi mới làm Theming:
//   Text('Tiêu đề', style: TextStyle(color: Colors.black))
//   → chữ đen trên nền đen ở Dark Mode → không đọc được!
//   Đây là lý do KHÔNG hardcode màu
// ══════════════════════════════════════════════════════════════════

class ThemedTaskScreen extends StatefulWidget {
  const ThemedTaskScreen({super.key});

  @override
  State<ThemedTaskScreen> createState() => _ThemedTaskScreenState();
}

class _ThemedTaskScreenState extends State<ThemedTaskScreen> {
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

  @override
  Widget build(BuildContext context) {
    // Lấy theme hiện tại — tự động là light hoặc dark tùy ThemeCubit
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      // ✅ AppBar dùng màu từ theme — không hardcode
      appBar: AppBar(
        title: Text(
          'Tuần 2 Ngày 4 — Theming',
          // ✅ textTheme từ theme — tự đổi theo Light/Dark
          style: theme.textTheme.titleLarge,
        ),
        actions: [
          // Nút đổi theme — dùng ThemeCubit từ Ngày 1
          IconButton(
            icon: Icon(
              context.watch<ThemeCubit>().state
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => context.read<ThemeCubit>().toggle(),
            tooltip: 'Đổi Light/Dark',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
          ),
        ],
      ),
      // ✅ background từ theme
      backgroundColor: colors.surface,
      body: Column(
        children: [
          // Chú thích — dùng theme colors
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // ✅ màu từ theme — không Colors.blue.shade50
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📌 Bài 4 — Theme.of(context)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    // ✅ màu chữ từ theme
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Mọi màu lấy từ Theme — không hardcode\n'
                  'Nhấn ☀️/🌙 để đổi Light/Dark, quan sát toàn app đổi',
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // So sánh hardcode vs theme
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📚 Hardcode vs Theme',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                    const Divider(),
                    // ❌ Hardcode — lỗi ở Dark Mode
                    Row(
                      children: [
                        const Icon(Icons.close, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Colors.black → chữ đen trên nền đen ở Dark',
                            style: TextStyle(
                                fontSize: 12, color: colors.onSurface),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // ✅ Theme — luôn đúng
                    Row(
                      children: [
                        Icon(Icons.check, color: colors.primary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'colorScheme.onSurface → tự đổi theo Light/Dark',
                            style: TextStyle(
                                fontSize: 12, color: colors.onSurface),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Danh sách task
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: colors.primary))
                : _error != null
                    ? Center(
                        child: Text(_error!,
                            style: TextStyle(color: colors.error)))
                    : _tasks.isEmpty
                        ? Center(
                            child: Text('Chưa có task',
                                style: TextStyle(color: colors.outline)))
                        : ListView.builder(
                            itemCount: _tasks.length,
                            itemBuilder: (context, index) =>
                                _ThemedTaskCard(task: _tasks[index]),
                          ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Widget dùng Theme — Bài 4 ──────────────────────────────
class _ThemedTaskCard extends StatelessWidget {
  final Task task;

  const _ThemedTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // ✅ Màu status lấy từ colorScheme thay vì Colors.xxx cố định
    final Color statusColor;
    final String statusLabel;
    final IconData statusIcon;

    switch (task.trangThai) {
      case 'HOAN_THANH':
        // ✅ tertiary = màu accent của theme, không phải Colors.green cố định
        statusColor = colors.tertiary;
        statusLabel = 'Hoàn thành';
        statusIcon = Icons.check_circle;
        break;
      case 'DANG_LAM':
        // ✅ secondary = màu thứ 2 của theme
        statusColor = colors.secondary;
        statusLabel = 'Đang làm';
        statusIcon = Icons.pending;
        break;
      default:
        statusColor = colors.outline;
        statusLabel = 'Chưa làm';
        statusIcon = Icons.circle_outlined;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor, size: 32),
        title: Text(
          task.tieuDe,
          // ✅ style từ textTheme — không TextStyle(color: Colors.black)
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: task.moTa.isNotEmpty
            ? Text(
                task.moTa,
                // ✅ màu chữ từ theme
                style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant),
              )
            : null,
        trailing: Chip(
          label: Text(statusLabel,
              style: TextStyle(fontSize: 11, color: statusColor)),
          backgroundColor: statusColor.withOpacity(0.1),
          side: BorderSide(color: statusColor.withOpacity(0.4)),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
