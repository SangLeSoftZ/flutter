import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bai4_api/api_client.dart';
import '../bai4_api/task_model.dart';
import 'bai1_sealed_state.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 1+2 — Demo Sealed Class + Pattern Matching
// Tuần 3 Ngày 7 (Sáng)
//
// switch (state) với sealed class:
//   - Không cần "default:" vì sealed đảm bảo đủ nhánh
//   - TaskLoaded(danhSach: final ds) = destructuring pattern
//     → vừa check type vừa lấy field trong 1 bước
//   - Thêm class con mới mà quên sửa switch → lỗi biên dịch ngay
// ══════════════════════════════════════════════════════════════════

// ── Cubit dùng Sealed State ───────────────────────────────────────
class TaskSealedCubit extends Cubit<TaskSealedState> {
  final ApiClient _api;
  TaskSealedCubit(this._api) : super(TaskSealedInitial());

  Future<void> taiDanhSach() async {
    emit(TaskSealedLoading());
    try {
      final ds = await _api.layDanhSachTask();
      emit(TaskSealedLoaded(ds));
    } catch (e) {
      emit(TaskSealedError(e.toString()));
    }
  }

  void reset() => emit(TaskSealedInitial());
}

// ── Màn hình demo ─────────────────────────────────────────────────
class SealedClassScreen extends StatelessWidget {
  const SealedClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TaskSealedCubit(ApiClient()),
      child: const _SealedView(),
    );
  }
}

class _SealedView extends StatelessWidget {
  const _SealedView();

  // ── Pattern matching với sealed class ────────────────────────
  // Không có "default:" — sealed đảm bảo đây là TẤT CẢ trường hợp
  // Thêm TaskSealedEmpty vào bai1_sealed_state.dart mà không thêm
  // nhánh ở đây → trình biên dịch báo lỗi NGAY
  Widget _buildTheoState(TaskSealedState state) {
    return switch (state) {
      TaskSealedInitial() => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.task_alt, size: 64, color: Colors.grey),
              const SizedBox(height: 8),
              const Text('Nhấn nút để tải task',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      TaskSealedLoading() => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 8),
              Text('Đang tải...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      // Destructuring: lấy danhSach ra biến ds trong 1 bước
      // Không cần: final ds = (state as TaskSealedLoaded).danhSach
      TaskSealedLoaded(danhSach: final ds) => ds.isEmpty
          ? const Center(child: Text('Không có task nào'))
          : ListView.builder(
              itemCount: ds.length,
              itemBuilder: (context, i) {
                final task = ds[i];
                return ListTile(
                  leading: Icon(
                    task.trangThai == 'HOAN_THANH'
                        ? Icons.check_circle
                        : Icons.pending,
                    color: task.trangThai == 'HOAN_THANH'
                        ? Colors.green
                        : Colors.orange,
                  ),
                  title: Text(task.tieuDe),
                  subtitle: Text(task.trangThai),
                );
              },
            ),
      // Destructuring: lấy thongDiep ra biến td
      TaskSealedError(thongDiep: final td) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 8),
              Text(td,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 3 Ngày 7 — Sealed Class Bài 1+2'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<TaskSealedCubit>().taiDanhSach(),
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: () => context.read<TaskSealedCubit>().reset(),
            tooltip: 'Reset về Initial',
          ),
        ],
      ),
      body: Column(
        children: [
          // Chú thích
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📌 Sealed Class + Pattern Matching',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  'switch (state) không cần default:\n'
                  'TaskLoaded(danhSach: final ds) = destructuring\n'
                  'Bài 2: bỏ comment TaskSealedEmpty trong bai1_sealed_state.dart\n'
                  '→ switch này sẽ báo lỗi biên dịch ngay',
                  style: TextStyle(fontSize: 11),
                ),
              ],
            ),
          ),

          // Trạng thái hiện tại
          BlocBuilder<TaskSealedCubit, TaskSealedState>(
            builder: (context, state) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Text('State hiện tại: ',
                      style: TextStyle(fontSize: 12)),
                  Text(
                    state.runtimeType.toString(),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: BlocBuilder<TaskSealedCubit, TaskSealedState>(
              builder: (context, state) => _buildTheoState(state),
            ),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<TaskSealedCubit, TaskSealedState>(
        builder: (context, state) => FloatingActionButton.extended(
          backgroundColor: Colors.teal.shade700,
          onPressed: state is TaskSealedLoading
              ? null
              : () => context.read<TaskSealedCubit>().taiDanhSach(),
          icon: const Icon(Icons.download),
          label: const Text('Tải Tasks'),
        ),
      ),
    );
  }
}
