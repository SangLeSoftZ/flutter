import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bai4_api/api_client.dart';
import '../bai4_api/task_model.dart';
import 'bai1_debounce_search_cubit.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 1 — Màn hình tìm kiếm Task với Debounce
// Tuần 3 Ngày 2 (Sáng)
//
// Cách test debounce:
//   1. Gõ nhanh nhiều ký tự liên tiếp
//   2. Nhìn log terminal → chỉ thấy "API call #1" sau khi ngừng gõ
//   3. Không thấy log cho từng ký tự riêng lẻ
//   4. Số "Lần gọi API" trên màn hình tăng chậm hơn nhiều
//      so với số ký tự đã gõ
// ══════════════════════════════════════════════════════════════════

class DebounceSearchScreen extends StatelessWidget {
  const DebounceSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DebounceSearchCubit(ApiClient()),
      child: const _DebounceSearchView(),
    );
  }
}

class _DebounceSearchView extends StatefulWidget {
  const _DebounceSearchView();

  @override
  State<_DebounceSearchView> createState() => _DebounceSearchViewState();
}

class _DebounceSearchViewState extends State<_DebounceSearchView> {
  final _searchCtrl = TextEditingController();
  int _soKyTuDaGo = 0; // đếm ký tự để so sánh với số lần gọi API

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 3 Ngày 2 — Debounce Search'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
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
            child: const Text(
              '📌 Debounce 400ms\n'
              'Gõ nhanh liên tục → chỉ 1 lần gọi API sau khi ngừng\n'
              'So sánh: Số ký tự gõ vs Số lần gọi API thực sự',
              style: TextStyle(fontSize: 12),
            ),
          ),

          // Ô tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (value) {
                setState(() => _soKyTuDaGo++);
                context.read<DebounceSearchCubit>().onTuKhoaThayDoi(value);
              },
              decoration: InputDecoration(
                hintText: 'Gõ nhanh để thấy debounce...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _soKyTuDaGo = 0);
                          context
                              .read<DebounceSearchCubit>()
                              .onTuKhoaThayDoi('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Stats debounce
          BlocBuilder<DebounceSearchCubit, DebounceSearchState>(
            builder: (context, state) {
              final apiCount = state is DebounceSearchLoaded
                  ? state.soLanGoiApi
                  : 0;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    _StatChip(
                      label: 'Ký tự đã gõ',
                      value: '$_soKyTuDaGo',
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Lần gọi API',
                      value: '$apiCount',
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    if (_soKyTuDaGo > 0 && apiCount > 0)
                      _StatChip(
                        label: 'Tiết kiệm',
                        value: '${_soKyTuDaGo - apiCount} request',
                        color: Colors.blue,
                      ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 8),
          const Divider(height: 1),

          // Kết quả
          Expanded(
            child: BlocBuilder<DebounceSearchCubit, DebounceSearchState>(
              builder: (context, state) {
                if (state is DebounceSearchInitial) {
                  return const Center(
                    child: Text(
                      'Gõ từ khóa để tìm kiếm\n'
                      '(Spring Boot phải đang chạy)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                if (state is DebounceSearchLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Đang chờ debounce...',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                if (state is DebounceSearchError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                if (state is DebounceSearchLoaded) {
                  if (state.ketQua.isEmpty) {
                    return Center(
                      child: Text(
                        'Không tìm thấy "${state.tuKhoa}"',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          'Tìm "${state.tuKhoa}" — ${state.ketQua.length} kết quả (API call #${state.soLanGoiApi})',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.ketQua.length,
                          itemBuilder: (context, index) =>
                              _TaskTile(task: state.ketQua[index]),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ),

          // Bài 2 hint
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.amber.shade50,
            child: const Text(
              '💡 Bài 2: Đổi _debounceDuration = Duration(milliseconds: 0)\n'
              'trong bai1_debounce_search_cubit.dart → thấy API gọi dồn dập',
              style: TextStyle(fontSize: 11, color: Colors.orange),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16)),
          Text(label,
              style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final Task task;
  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final color = task.trangThai == 'HOAN_THANH'
        ? Colors.green
        : task.trangThai == 'DANG_LAM'
            ? Colors.orange
            : Colors.grey;
    return ListTile(
      leading: Icon(
        task.trangThai == 'HOAN_THANH'
            ? Icons.check_circle
            : Icons.pending_outlined,
        color: color,
      ),
      title: Text(task.tieuDe),
      subtitle: task.moTa.isNotEmpty ? Text(task.moTa) : null,
      trailing: Chip(
        label: Text(
          task.trangThai == 'HOAN_THANH'
              ? 'Hoàn thành'
              : task.trangThai == 'DANG_LAM'
                  ? 'Đang làm'
                  : 'Chưa làm',
          style: const TextStyle(fontSize: 11),
        ),
        backgroundColor: color.withOpacity(0.1),
        side: BorderSide(color: color.withOpacity(0.4)),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
