import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../bai4_api/api_client.dart';
import '../bai4_api/task_model.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 2 — ShellRoute cơ bản: Bottom Nav với 2 tab
// Tuần 3 Ngày 5 (Chiều)
//
// Vấn đề ShellRoute giải quyết:
//   IndexedStack thủ công → mất state khi chuyển tab
//   Navigator.push toàn màn → mất Bottom Nav Bar
//   ShellRoute → mỗi tab có stack riêng, Bottom Nav không rebuild
//
// ShellRoute vs StatefulShellRoute:
//   ShellRoute: 1 navigator stack dùng chung → route con bị rebuild khi quay lại
//   StatefulShellRoute: mỗi branch có stack riêng → giữ state (xem Bài 3)
// ══════════════════════════════════════════════════════════════════

// ── GoRouter dùng ShellRoute ──────────────────────────────────────
final shellRouter = GoRouter(
  initialLocation: '/shell/tasks',
  routes: [
    ShellRoute(
      // builder nhận "child" = nội dung route con đang active
      // ScaffoldWithBottomNav là KHUNG NGOÀI — không rebuild khi đổi tab
      builder: (context, state, child) =>
          _ScaffoldWithBottomNav(child: child),
      routes: [
        GoRoute(
          path: '/shell/tasks',
          builder: (context, state) => const _TaskListTab(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => _TaskDetailTab(
                taskId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/shell/profile',
          builder: (context, state) => const _ProfileTab(),
        ),
      ],
    ),
  ],
);

// ── Scaffold dùng chung — không rebuild khi đổi tab ──────────────
class _ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;
  const _ScaffoldWithBottomNav({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = location.startsWith('/shell/profile') ? 1 : 0;

    return Scaffold(
      body: child, // chỉ phần này thay đổi khi đổi tab
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          context.go(index == 0 ? '/shell/tasks' : '/shell/profile');
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.task_alt), label: 'Task'),
          NavigationDestination(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ── Tab Task ──────────────────────────────────────────────────────
class _TaskListTab extends StatefulWidget {
  const _TaskListTab();

  @override
  State<_TaskListTab> createState() => _TaskListTabState();
}

class _TaskListTabState extends State<_TaskListTab> {
  final _api = ApiClient();
  List<Task> _tasks = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final t = await _api.layDanhSachTask();
      setState(() => _tasks = t);
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks — ShellRoute'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.indigo.shade200),
            ),
            child: const Text(
              '📌 Bài 2: ShellRoute\n'
              'Nhấn vào task → vào chi tiết → chuyển tab Profile\n'
              '→ Quay lại Task: BỊ reset về danh sách (xem Bài 3 để fix)',
              style: TextStyle(fontSize: 11),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (context, i) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _tasks[i].trangThai ==
                                'HOAN_THANH'
                            ? Colors.green
                            : Colors.orange,
                        child: Text('${_tasks[i].id}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ),
                      title: Text(_tasks[i].tieuDe),
                      subtitle: Text(_tasks[i].trangThai),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          context.go('/shell/tasks/${_tasks[i].id}'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Tab Task Detail ───────────────────────────────────────────────
class _TaskDetailTab extends StatelessWidget {
  final String taskId;
  const _TaskDetailTab({required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task #$taskId'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Chi tiết Task #$taskId',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text(
              'Chuyển sang tab Profile\nrồi quay lại → sẽ về danh sách\n(hành vi của ShellRoute cơ bản)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab Profile ───────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile — ShellRoute'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 80, color: Colors.teal),
            SizedBox(height: 16),
            Text('Profile Tab', style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text(
              'Quay lại tab Task\n→ về danh sách (state bị reset)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Entry point màn hình ──────────────────────────────────────────
class ShellRouteScreen extends StatelessWidget {
  const ShellRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: shellRouter,
    );
  }
}
