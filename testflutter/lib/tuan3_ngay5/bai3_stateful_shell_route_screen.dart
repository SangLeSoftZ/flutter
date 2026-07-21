import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../bai4_api/api_client.dart';
import '../bai4_api/task_model.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 3 — StatefulShellRoute.indexedStack: giữ state mỗi tab
// Tuần 3 Ngày 5 (Chiều)
//
// PHÂN BIỆT với Bài 2 (ShellRoute cơ bản):
//   ShellRoute: 1 navigator stack dùng chung
//     → quay lại tab → route con bị rebuild từ đầu
//   StatefulShellRoute.indexedStack: mỗi branch có stack riêng
//     → quay lại tab → vẫn ở đúng màn hình/vị trí cuộn cũ
//
// branches: mỗi branch = 1 tab với navigator stack độc lập
// navigationShell.goBranch(): chuyển tab, giữ state của tab cũ
// ══════════════════════════════════════════════════════════════════

// ── GoRouter dùng StatefulShellRoute ─────────────────────────────
final statefulShellRouter = GoRouter(
  initialLocation: '/stateful/tasks',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _StatefulScaffold(navigationShell: navigationShell),
      branches: [
        // Branch 1: Tab Task (có navigator stack riêng)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stateful/tasks',
              builder: (context, state) => const _StatefulTaskList(),
              routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => _StatefulTaskDetail(
                    taskId: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Branch 2: Tab Profile (navigator stack riêng, độc lập)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stateful/profile',
              builder: (context, state) => const _StatefulProfile(),
            ),
          ],
        ),
      ],
    ),
  ],
);

// ── Scaffold dùng StatefulNavigationShell ────────────────────────
class _StatefulScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const _StatefulScaffold({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // navigationShell thay cho child — mỗi branch là IndexedStack riêng
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          // bấm lại tab đang ở → về root của tab đó
          initialLocation: index == navigationShell.currentIndex,
        ),
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

// ── Tab Task (có scroll controller để test giữ vị trí cuộn) ──────
class _StatefulTaskList extends StatefulWidget {
  const _StatefulTaskList();

  @override
  State<_StatefulTaskList> createState() => _StatefulTaskListState();
}

class _StatefulTaskListState extends State<_StatefulTaskList> {
  final _api = ApiClient();
  List<Task> _tasks = [];
  bool _loading = false;
  // ScrollController để giữ vị trí cuộn khi quay lại tab
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final t = await _api.layDanhSachTask();
      // Nhân task lên 10x để danh sách đủ dài để cuộn
      setState(() => _tasks = List.generate(
          t.length * 10, (i) => t[i % t.length]));
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks — StatefulShellRoute'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.deepPurple.shade200),
            ),
            child: const Text(
              '📌 Bài 3: StatefulShellRoute\n'
              '1. Cuộn xuống giữa danh sách\n'
              '2. Nhấn vào 1 task → vào chi tiết\n'
              '3. Chuyển sang Profile → quay lại\n'
              '→ Vẫn ở đúng màn hình/vị trí cuộn cũ ✅',
              style: TextStyle(fontSize: 11),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _tasks.length,
                    itemBuilder: (context, i) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _tasks[i].trangThai ==
                                'HOAN_THANH'
                            ? Colors.green
                            : Colors.orange,
                        child: Text('${i + 1}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11)),
                      ),
                      title: Text('${_tasks[i].tieuDe} #${i + 1}'),
                      subtitle: Text(_tasks[i].trangThai),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go(
                          '/stateful/tasks/${_tasks[i].id}'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Task Detail ────────────────────────────────────────────────────
class _StatefulTaskDetail extends StatelessWidget {
  final String taskId;
  const _StatefulTaskDetail({required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task #$taskId'),
        backgroundColor: Colors.deepPurple,
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
              'Chuyển sang tab Profile rồi quay lại\n→ vẫn ở màn này (không về danh sách) ✅',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile ────────────────────────────────────────────────────────
class _StatefulProfile extends StatelessWidget {
  const _StatefulProfile();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile — StatefulShellRoute'),
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
              'Quay lại tab Task\n→ vẫn ở màn hình/vị trí cuộn cũ ✅\n(IndexedStack giữ state ngầm)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Entry point ────────────────────────────────────────────────────
class StatefulShellRouteScreen extends StatelessWidget {
  const StatefulShellRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: statefulShellRouter,
    );
  }
}
