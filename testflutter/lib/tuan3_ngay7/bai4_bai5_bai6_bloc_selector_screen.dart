import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bai4_api/api_client.dart';
import 'bai1_sealed_state.dart';
import 'bai2_sealed_demo_screen.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 4+5+6 — BlocSelector + buildWhen + listenWhen
// Tuần 3 Ngày 7 (Chiều)
//
// Dùng ValueNotifier để đếm độc lập — tránh setState gây cascade rebuild
// Mỗi counter chỉ tăng đúng khi builder của nó được gọi
// ══════════════════════════════════════════════════════════════════

class BlocSelectorScreen extends StatelessWidget {
  const BlocSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TaskSealedCubit(ApiClient()),
      child: const _BlocSelectorView(),
    );
  }
}

class _BlocSelectorView extends StatefulWidget {
  const _BlocSelectorView();

  @override
  State<_BlocSelectorView> createState() => _BlocSelectorViewState();
}

class _BlocSelectorViewState extends State<_BlocSelectorView> {
  // ValueNotifier: tăng giá trị mà KHÔNG trigger rebuild toàn widget
  // ValueListenableBuilder bên dưới chỉ rebuild đúng Text hiển thị số
  final _cntTho = ValueNotifier(0);
  final _cntSelector = ValueNotifier(0);
  final _cntBuildWhen = ValueNotifier(0);
  final _cntListener = ValueNotifier(0);

  @override
  void dispose() {
    _cntTho.dispose();
    _cntSelector.dispose();
    _cntBuildWhen.dispose();
    _cntListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskSealedCubit, TaskSealedState>(
      // BÀI 6: listenWhen — chỉ phản ứng khi state MỚI là Error
      listenWhen: (old, current) {
        _cntListener.value++;
        return current is TaskSealedError;
      },
      listener: (context, state) {
        if (state is TaskSealedError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${state.thongDiep}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // BÀI 5: BlocSelector — title CHỈ rebuild khi số lượng task đổi
          title: BlocSelector<TaskSealedCubit, TaskSealedState, int>(
            selector: (state) {
              _cntSelector.value++;
              return state is TaskSealedLoaded ? state.danhSach.length : 0;
            },
            builder: (context, soLuong) => Text('Tasks ($soLuong)'),
          ),
          backgroundColor: Colors.purple.shade700,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<TaskSealedCubit>().taiDanhSach(),
            ),
            IconButton(
              icon: const Icon(Icons.restart_alt),
              onPressed: () => context.read<TaskSealedCubit>().reset(),
              tooltip: 'Reset',
            ),
          ],
        ),
        body: Column(
          children: [
            // Bảng đếm số lần build — dùng ValueListenableBuilder
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 Số lần builder() được gọi:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  _CountRow(
                    label: '❌ BlocBuilder thô',
                    notifier: _cntTho,
                    color: Colors.red,
                  ),
                  _CountRow(
                    label: '✅ BlocSelector (Bài 5)',
                    notifier: _cntSelector,
                    color: Colors.green,
                  ),
                  _CountRow(
                    label: '✅ buildWhen (Bài 4)',
                    notifier: _cntBuildWhen,
                    color: Colors.blue,
                  ),
                  _CountRow(
                    label: '⚡ listenWhen calls (Bài 6)',
                    notifier: _cntListener,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Nhấn Refresh nhiều lần:\n'
                    '→ Thô: tăng nhiều hơn\n'
                    '→ buildWhen/Selector: tăng ÍT hơn khi state không đổi loại',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // 2 cột so sánh
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cột trái: BlocBuilder THÔ
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.red.shade50,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: const Text(
                            '❌ BlocBuilder thô',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: BlocBuilder<TaskSealedCubit, TaskSealedState>(
                            builder: (context, state) {
                              // addPostFrameCallback để tránh thay đổi state trong build()
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _cntTho.value++;
                              });
                              return _buildContent(state);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const VerticalDivider(width: 1),

                  // Cột phải: BlocBuilder + buildWhen
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.blue.shade50,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: const Text(
                            '✅ buildWhen',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: BlocBuilder<TaskSealedCubit, TaskSealedState>(
                            // BÀI 4: chỉ rebuild khi TYPE state đổi
                            // Nếu emit TaskLoaded 2 lần liên tiếp → KHÔNG rebuild lần 2
                            buildWhen: (old, current) {
                              return old.runtimeType != current.runtimeType;
                            },
                            builder: (context, state) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _cntBuildWhen.value++;
                              });
                              return _buildContent(state);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(TaskSealedState state) {
    return switch (state) {
      TaskSealedInitial() => const Center(
        child: Text(
          'Initial\n↓ Nhấn Refresh',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
      TaskSealedLoading() => const Center(child: CircularProgressIndicator()),
      TaskSealedLoaded(danhSach: final ds) => ListView.builder(
        itemCount: ds.length,
        itemBuilder:
            (_, i) => ListTile(
              dense: true,
              leading: Icon(
                ds[i].trangThai == 'HOAN_THANH'
                    ? Icons.check_circle
                    : Icons.pending,
                size: 18,
                color:
                    ds[i].trangThai == 'HOAN_THANH'
                        ? Colors.green
                        : Colors.orange,
              ),
              title: Text(ds[i].tieuDe, style: const TextStyle(fontSize: 12)),
            ),
      ),
      TaskSealedError(thongDiep: final td) => Center(
        child: Text(
          'Lỗi\n$td',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red, fontSize: 11),
        ),
      ),
    };
  }
}

// Widget hiển thị counter — chỉ rebuild đúng Text này khi value đổi
class _CountRow extends StatelessWidget {
  final String label;
  final ValueNotifier<int> notifier;
  final Color color;

  const _CountRow({
    required this.label,
    required this.notifier,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11))),
          ValueListenableBuilder<int>(
            valueListenable: notifier,
            builder:
                (_, val, __) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$val',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 12,
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
