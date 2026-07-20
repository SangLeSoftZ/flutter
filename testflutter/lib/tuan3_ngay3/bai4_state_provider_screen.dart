import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 4 — Riverpod: StateProvider<int> đơn giản
// Tuần 3 Ngày 3 (Chiều)
//
// So sánh với Cubit:
//   Cubit: class TaskCubit extends Cubit<int> + BlocProvider bọc widget
//   Riverpod: 1 dòng khai báo provider + ProviderScope bọc app 1 lần
//
// ref.watch() = context.watch() → đọc + rebuild khi đổi
// ref.read()  = context.read()  → chỉ đọc/gọi, không rebuild
//
// ĐIỂM KHÁC BIỆT CHÍNH vs Cubit:
//   Cubit: phải có BuildContext → chỉ dùng được trong widget tree
//   Riverpod: ref hoạt động cả ngoài widget tree (interceptor, test...)
// ══════════════════════════════════════════════════════════════════

// ── Provider khai báo ở top-level — không cần class, không cần Provider widget ──
// Tương đương: class DemCubit extends Cubit<int> { DemCubit() : super(0); }
final demTaskProvider = StateProvider<int>((ref) => 0);

// ── ConsumerWidget = StatelessWidget nhưng có thêm WidgetRef ref ──
class Bai4StateProviderScreen extends ConsumerWidget {
  const Bai4StateProviderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch() → đọc state + tự rebuild khi state đổi
    // Tương đương: context.watch<DemCubit>().state
    final soLuong = ref.watch(demTaskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 3 Ngày 3 — Riverpod Bài 4'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // So sánh Cubit vs Riverpod
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
                  Text('📌 StateProvider<int> — so sánh Cubit vs Riverpod',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('Cubit:    class DemCubit extends Cubit<int>',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11)),
                  Text('          BlocProvider bọc từng widget cần',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey)),
                  SizedBox(height: 4),
                  Text('Riverpod: final p = StateProvider<int>((ref) => 0)',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11)),
                  Text('          ProviderScope bọc 1 lần ở main()',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Hiển thị state
            Text(
              '$soLuong',
              style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700),
            ),
            const Text('Số Task', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),

            // Nút thao tác
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ref.read() → chỉ gọi action, không cần rebuild
                // Tương đương: context.read<DemCubit>().decrement()
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red.shade400),
                  onPressed: soLuong > 0
                      ? () => ref.read(demTaskProvider.notifier).state--
                      : null,
                  icon: const Icon(Icons.remove),
                  label: const Text('Bớt'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.teal.shade700),
                  onPressed: () => ref.read(demTaskProvider.notifier).state++,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => ref.read(demTaskProvider.notifier).state = 0,
                  child: const Text('Reset'),
                ),
              ],
            ),

            const SizedBox(height: 40),
            // Giải thích ref.watch vs ref.read
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📚 ref.watch vs ref.read',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Divider(),
                    _row('ref.watch(p)', 'Đọc + lắng nghe → rebuild khi đổi\n≈ context.watch<Cubit>()', Colors.blue),
                    const SizedBox(height: 6),
                    _row('ref.read(p)', 'Chỉ đọc 1 lần, không rebuild\n≈ context.read<Cubit>()', Colors.orange),
                    const SizedBox(height: 6),
                    _row('ref.read(p.notifier)', 'Truy cập notifier để gọi action\n≈ context.read<Cubit>().someMethod()', Colors.green),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String method, String desc, Color color) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color),
        ),
        child: Text(method,
            style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.bold)),
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(desc, style: const TextStyle(fontSize: 12))),
    ],
  );
}
