import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../bai4_api/task_model.dart';
import '../bai4_api/api_client.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 5 — Riverpod: Notifier (tương đương Cubit phức tạp)
// Tuần 3 Ngày 3 (Chiều)
//
// So sánh trực tiếp TaskListNotifier vs TaskCubit:
//
//   TaskCubit:                    TaskListNotifier:
//   extends Cubit<List<Task>>     extends Notifier<List<Task>>
//   Cubit() : super([])           List<Task> build() => []
//   emit([...state, task])        state = [...state, task]
//   BlocProvider(create: ...)     NotifierProvider(TaskListNotifier.new)
//   context.watch<TaskCubit>()    ref.watch(taskListProvider)
//   context.read<TaskCubit>()     ref.read(taskListProvider.notifier)
// ══════════════════════════════════════════════════════════════════

// ── Notifier — tương đương TaskCubit ─────────────────────────────
class TaskListNotifier extends Notifier<List<Task>> {
  @override
  // build() = constructor + state ban đầu của Cubit
  // Cubit: TaskCubit() : super([]);
  List<Task> build() => [];

  void themTask(Task task) {
    // PHẢI tạo list mới — không sửa trực tiếp state cũ
    // Giống emit([...state, task]) trong Cubit
    state = [...state, task];
  }

  void xoaTask(int id) {
    state = state.where((t) => t.id != id).toList();
  }

  void toggleHoanThanh(Task task) {
    state = state.map((t) {
      if (t.id != task.id) return t;
      return Task(
        id: t.id,
        tieuDe: t.tieuDe,
        moTa: t.moTa,
        trangThai: t.trangThai == 'HOAN_THANH' ? 'DANG_LAM' : 'HOAN_THANH',
      );
    }).toList();
  }

  // Load từ API — giống hàm async trong Cubit
  Future<void> taiTuApi() async {
    try {
      final tasks = await ApiClient().layDanhSachTask();
      state = tasks; // gán trực tiếp, không cần emit()
    } catch (e) {
      // error handling
    }
  }
}

// Provider — khai báo 1 dòng ở top-level
// Tương đương: không cần viết gì thêm ở main() ngoài ProviderScope
final taskListProvider =
    NotifierProvider<TaskListNotifier, List<Task>>(TaskListNotifier.new);

// ── Màn hình demo ─────────────────────────────────────────────────
class Bai5NotifierScreen extends ConsumerWidget {
  const Bai5NotifierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 3 Ngày 3 — Riverpod Bài 5'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Load từ API',
            onPressed: () =>
                ref.read(taskListProvider.notifier).taiTuApi(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.deepPurple.shade200),
            ),
            child: const Text(
              '📌 Notifier vs Cubit — so sánh:\n'
              'build() => []          ≈  super([]) trong Cubit\n'
              'state = [...state, t]  ≈  emit([...state, t])\n'
              'ref.watch(provider)    ≈  context.watch<Cubit>()\n'
              'ref.read(p.notifier)   ≈  context.read<Cubit>()',
              style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
            ),
          ),

          // Task list
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        const Text('Chưa có task\nNhấn + để thêm hoặc ↓ để load API',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final hoanThanh = task.trangThai == 'HOAN_THANH';
                      return ListTile(
                        leading: Checkbox(
                          value: hoanThanh,
                          onChanged: (_) => ref
                              .read(taskListProvider.notifier)
                              .toggleHoanThanh(task),
                        ),
                        title: Text(
                          task.tieuDe,
                          style: TextStyle(
                            decoration: hoanThanh
                                ? TextDecoration.lineThrough
                                : null,
                            color: hoanThanh ? Colors.grey : null,
                          ),
                        ),
                        subtitle: task.moTa.isNotEmpty
                            ? Text(task.moTa,
                                style: const TextStyle(fontSize: 12))
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () => ref
                              .read(taskListProvider.notifier)
                              .xoaTask(task.id),
                        ),
                      );
                    },
                  ),
          ),

          // Bài 6: ghi chú so sánh
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📝 Bài 6 — 3 điểm khác biệt tự nhận thấy:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                SizedBox(height: 4),
                Text(
                  '1. Không cần BlocProvider bọc widget — ProviderScope 1 lần ở main()\n'
                  '2. state = [...] trực tiếp thay vì gọi emit() — dễ quên tạo list mới\n'
                  '3. ref không cần BuildContext — dùng được trong hàm async bên ngoài widget',
                  style: TextStyle(fontSize: 11, color: Colors.amber),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _showThemTask(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showThemTask(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm Task'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Tiêu đề task...'),
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                ref.read(taskListProvider.notifier).themTask(
                      Task(
                        id: DateTime.now().millisecondsSinceEpoch,
                        tieuDe: ctrl.text.trim(),
                        moTa: '',
                        trangThai: 'CHUA_LAM',
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }
}
