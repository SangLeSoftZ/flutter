import 'package:flutter/material.dart';
import '../bai4_api/task_model.dart';
import '../login/data/models/user_model.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 1 — Generics: viết 1 lần, dùng cho mọi kiểu dữ liệu
// Tuần 3 Ngày 3 (Sáng)
//
// Vấn đề: phải viết TaskApiResponse, UserApiResponse riêng → trùng lặp
// Giải pháp: ApiResponse<T> — T là "biến kiểu dữ liệu"
//   ApiResponse<Task>       → T = Task
//   ApiResponse<UserModel>  → T = UserModel
//   ApiResponse<List<Task>> → T = List<Task>
// ══════════════════════════════════════════════════════════════════

// ── Bài 1: ApiResponse<T> — wrapper chung cho mọi API response ────
class ApiResponse<T> {
  final bool thanhCong;
  final T? duLieu;
  final String? loi;
  final int? statusCode;

  // Named constructors rõ ràng hơn positional
  const ApiResponse.ok(this.duLieu)
      : thanhCong = true,
        loi = null,
        statusCode = 200;

  const ApiResponse.loi(this.loi, {this.statusCode})
      : thanhCong = false,
        duLieu = null;

  // Factory từ try/catch — dùng trong ApiClient thực tế
  static ApiResponse<T> from<T>(T Function() goi) {
    try {
      return ApiResponse.ok(goi());
    } catch (e) {
      return ApiResponse.loi(e.toString());
    }
  }

  @override
  String toString() => thanhCong
      ? 'ApiResponse.ok(${duLieu.runtimeType})'
      : 'ApiResponse.loi($loi)';
}

// ── Generics với ràng buộc extends ────────────────────────────────
// Chỉ cho phép T là Comparable — đảm bảo có thể so sánh
T timLonNhat<T extends Comparable<T>>(List<T> ds) {
  assert(ds.isNotEmpty, 'Danh sách không được rỗng');
  var lonNhat = ds.first;
  for (final item in ds) {
    if (item.compareTo(lonNhat) > 0) lonNhat = item;
  }
  return lonNhat;
}

// ── Màn hình demo ─────────────────────────────────────────────────
class GenericsScreen extends StatelessWidget {
  const GenericsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo ApiResponse<T> với các kiểu khác nhau
    final phanHoiTask = ApiResponse<Task>.ok(
      const Task(id: 1, tieuDe: 'Học Generics', moTa: 'Viết ApiResponse<T>', trangThai: 'DANG_LAM'),
    );

    final phanHoiLoi = ApiResponse<Task>.loi('Token hết hạn', statusCode: 401);

    final phanHoiDanhSach = ApiResponse<List<Task>>.ok([
      const Task(id: 1, tieuDe: 'Task 1', moTa: '', trangThai: 'HOAN_THANH'),
      const Task(id: 2, tieuDe: 'Task 2', moTa: '', trangThai: 'DANG_LAM'),
    ]);

    // timLonNhat<T extends Comparable>
    final soLonNhat = timLonNhat([3, 7, 2, 9, 1]);
    final chuoiLonNhat = timLonNhat(['apple', 'zebra', 'mango']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 3 Ngày 3 — Generics Bài 1'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section('📌 Vấn đề không có Generics',
              'Phải viết TaskApiResponse, UserApiResponse riêng\n→ code trùng lặp, khó bảo trì'),

            _section('✅ Giải pháp: ApiResponse<T>',
              'Viết 1 lần, dùng cho mọi kiểu\nT được "điền vào" lúc gọi'),

            const SizedBox(height: 12),
            _codeCard('ApiResponse<Task>.ok(...)', phanHoiTask.toString(),
                phanHoiTask.thanhCong),
            _codeCard('ApiResponse<Task>.loi(...)', phanHoiLoi.toString(),
                phanHoiLoi.thanhCong),
            _codeCard('ApiResponse<List<Task>>.ok(...)',
                '${phanHoiDanhSach.duLieu?.length} tasks\n${phanHoiDanhSach}',
                phanHoiDanhSach.thanhCong),

            const SizedBox(height: 16),
            _section('📌 Generics với ràng buộc <T extends Comparable>',
              'Chỉ nhận kiểu có thể so sánh được'),
            _codeCard('timLonNhat([3,7,2,9,1])  // Dart tự infer <int>', 'Kết quả: $soLonNhat', true),
            _codeCard('timLonNhat(["apple","zebra"])  // infer <String>', 'Kết quả: $chuoiLonNhat', true),

            const SizedBox(height: 16),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📚 Generics đã dùng từ đầu khóa:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text(
                      'List<Task>  •  Map<String, dynamic>\n'
                      'Future<Task>  •  Stream<String>\n'
                      'BlocBuilder<TaskCubit, TaskState>\n'
                      '→ Tất cả đều là Generics!',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String desc) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    ),
  );

  Widget _codeCard(String code, String result, bool ok) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ok ? Icons.check_circle : Icons.error,
              color: ok ? Colors.green : Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code,
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                Text(result,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
