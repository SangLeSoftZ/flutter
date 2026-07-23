import 'package:flutter/material.dart';
import '../bai4_api/api_client.dart';
import '../bai4_api/task_model.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 3 — Records: trả nhiều giá trị không cần tạo class
// Tuần 3 Ngày 7 (Sáng)
//
// Record vs Class:
//   Class: cần khai báo trước, có tên rõ ràng, dùng rộng rãi
//   Record: không cần khai báo, gói tạm nhiều giá trị
//           phù hợp cho nhu cầu ngắn hạn, nội bộ 1 hàm/file
//
// Named field: (tongSoTask: int, soHoanThanh: int)
//   → truy cập qua tên: ketQua.tongSoTask
//   → không phải qua vị trí: ketQua.$1 (positional record)
// ══════════════════════════════════════════════════════════════════

// ── Hàm trả Record có named field ────────────────────────────────
// Không cần tạo class ThongKeResult chỉ để gói 3 giá trị này
({int tongSoTask, int soHoanThanh, int dangLam}) thongKeTask(
    List<Task> danhSach) {
  final hoanThanh =
      danhSach.where((t) => t.trangThai == 'HOAN_THANH').length;
  final dangLam =
      danhSach.where((t) => t.trangThai == 'DANG_LAM').length;
  // Trả Record — không cần new ThongKeResult(...)
  return (
    tongSoTask: danhSach.length,
    soHoanThanh: hoanThanh,
    dangLam: dangLam,
  );
}

// ── Hàm trả Record positional (không tên) ────────────────────────
// Ít rõ ràng hơn named, dùng khi field đơn giản và rõ nghĩa
(List<Task>, int) layTaskVaTongSoTrang(List<Task> allTasks, int trang) {
  const perPage = 2;
  final tongTrang = (allTasks.length / perPage).ceil();
  final start = (trang - 1) * perPage;
  final end = (start + perPage).clamp(0, allTasks.length);
  return (allTasks.sublist(start, end), tongTrang);
}

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final _api = ApiClient();
  List<Task> _allTasks = [];
  bool _loading = false;
  int _trang = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final tasks = await _api.layDanhSachTask();
      setState(() => _allTasks = tasks);
    } catch (_) {}
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Dùng Record destructuring — lấy cả 2 giá trị cùng lúc
    final (trangHienTai, tongTrang) =
        layTaskVaTongSoTrang(_allTasks, _trang);

    // Named record — truy cập qua tên field
    final thongKe = thongKeTask(_allTasks);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 3 Ngày 7 — Records Bài 3'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Chú thích
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.deepOrange.shade200),
                  ),
                  child: const Text(
                    '📌 Record: trả nhiều giá trị không cần class\n'
                    'thongKeTask() → ({tongSoTask, soHoanThanh, dangLam})\n'
                    'layTaskVaTongSoTrang() → (List<Task>, int)\n'
                    'Truy cập qua tên field: thongKe.tongSoTask',
                    style: TextStyle(fontSize: 11),
                  ),
                ),

                // Thống kê từ Named Record
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Named Record — thongKeTask():',
                              style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                            children: [
                              _statBox('Tổng', '${thongKe.tongSoTask}',
                                  Colors.blue),
                              _statBox(
                                  'Hoàn thành',
                                  '${thongKe.soHoanThanh}',
                                  Colors.green),
                              _statBox('Đang làm',
                                  '${thongKe.dangLam}', Colors.orange),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Code: final thongKe = thongKeTask(tasks);\n'
                            'print(thongKe.tongSoTask); // named field',
                            style: TextStyle(
                                fontSize: 11, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Phân trang từ Positional Record
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Text('Trang $_trang/$tongTrang',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        onPressed: _trang > 1
                            ? () => setState(() => _trang--)
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      IconButton(
                        onPressed: _trang < tongTrang
                            ? () => setState(() => _trang++)
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    itemCount: trangHienTai.length,
                    itemBuilder: (context, i) => ListTile(
                      leading: Icon(
                        trangHienTai[i].trangThai == 'HOAN_THANH'
                            ? Icons.check_circle
                            : Icons.pending,
                        color:
                            trangHienTai[i].trangThai == 'HOAN_THANH'
                                ? Colors.green
                                : Colors.orange,
                      ),
                      title: Text(trangHienTai[i].tieuDe),
                      subtitle: Text(trangHienTai[i].trangThai),
                    ),
                  ),
                ),

                // Code demo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  color: Colors.grey.shade100,
                  child: const Text(
                    '// Positional Record destructuring:\n'
                    'final (tasks, totalPages) = layTaskVaTongSoTrang(all, page);\n'
                    '// Named Record:\n'
                    'final ({int tongSoTask, ...}) stats = thongKeTask(tasks);',
                    style: TextStyle(
                        fontSize: 10, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  fontSize: 20,
                  color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}
