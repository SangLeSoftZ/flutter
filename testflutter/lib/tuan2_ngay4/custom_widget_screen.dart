import 'package:flutter/material.dart';
import '../bai4_api/api_client.dart';
import '../bai4_api/task_model.dart';
import 'task_card.dart';
import 'task_search_bar.dart';

// ══════════════════════════════════════════════════════════════════
// MÀN HÌNH DEMO — Tuần 2 Ngày 4 (Sáng): Custom Widget
//
// PHÂN BIỆT với các màn hình trước:
//   Trước: build() dài, mỗi item viết lại Card+Icon+Text
//   Ngày 4: dùng TaskCard + TaskSearchBar tái sử dụng
//
// Màn hình này CHỈ lo:
//   - Load data từ API
//   - Lọc danh sách theo từ khóa (có hỗ trợ bỏ dấu tiếng Việt)
//   - Xử lý logic xóa
//   UI chi tiết mỗi item → TaskCard lo
//   UI search bar → TaskSearchBar lo
// ══════════════════════════════════════════════════════════════════

class CustomWidgetScreen extends StatefulWidget {
  const CustomWidgetScreen({super.key});

  @override
  State<CustomWidgetScreen> createState() => _CustomWidgetScreenState();
}

class _CustomWidgetScreenState extends State<CustomWidgetScreen> {
  final ApiClient _api = ApiClient();
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = false;
  String? _error;
  String _tuKhoa = '';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Bỏ dấu tiếng Việt để search không phân biệt dấu
  // VD: "Học" → "hoc", "Tìm" → "tim", "JPA" → "jpa"
  String _boDau(String text) {
    const withDau  = 'àáảãạăắặẳẵằâấầẩẫậèéẻẽẹêếềểễệìíỉĩịòóỏõọôốồổỗộơớờởỡợùúủũụưứừửữựỳýỷỹỵđ'
                     'ÀÁẢÃẠĂẮẶẲẴẰÂẤẦẨẪẬÈÉẺẼẸÊẾỀỂỄỆÌÍỈĨỊÒÓỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢÙÚỦŨỤƯỨỪỬỮỰỲÝỶỸỴĐ';
    const khongDau = 'aaaaaaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiioooooooooooooooooouuuuuuuuuuuyyyyyd'
                     'aaaaaaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiioooooooooooooooooouuuuuuuuuuuyyyyyd';
    var result = text;
    for (var i = 0; i < withDau.length; i++) {
      result = result.replaceAll(withDau[i], khongDau[i]);
    }
    return result.toLowerCase();
  }

  Future<void> _loadTasks() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final tasks = await _api.layDanhSachTask();
      setState(() {
        _allTasks = tasks;
        _filteredTasks = tasks;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Logic lọc nằm ở màn hình cha — không nằm trong TaskSearchBar
  // Hỗ trợ: không phân biệt hoa/thường + không phân biệt dấu tiếng Việt
  // VD: gõ "hoc" → tìm được "Học Spring Boot"
  //     gõ "Hoc" → tìm được "Học Spring Boot"
  //     gõ "jwt" → tìm được "Làm bài tập JWT"
  void _onSearch(String tuKhoa) {
    setState(() {
      _tuKhoa = tuKhoa;
      _filteredTasks = tuKhoa.isEmpty
          ? _allTasks
          : _allTasks
              .where((t) =>
                  _boDau(t.tieuDe).contains(_boDau(tuKhoa)) ||
                  _boDau(t.moTa).contains(_boDau(tuKhoa)))
              .toList();
    });
  }

  void _onXoa(Task task) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Xóa task "${task.tieuDe}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _allTasks.removeWhere((t) => t.id == task.id);
                _filteredTasks.removeWhere((t) => t.id == task.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa "${task.tieuDe}"')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 2 Ngày 4 — Custom Widget'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.indigo.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📌 Custom Widget — DRY Principle',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('TaskCard + TaskSearchBar tái sử dụng'),
                Text(
                  'Search hỗ trợ bỏ dấu: gõ "hoc" → ra "Học Spring Boot"',
                  style: TextStyle(color: Colors.indigo, fontSize: 12),
                ),
              ],
            ),
          ),

          TaskSearchBar(
            onSearch: _onSearch,
            hintText: 'Tìm theo tiêu đề hoặc mô tả...',
          ),

          if (_tuKhoa.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text('Kết quả: ${_filteredTasks.length} task',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 48),
                            const SizedBox(height: 12),
                            Text(_error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Thử lại'),
                              onPressed: _loadTasks,
                            ),
                          ],
                        ),
                      )
                    : _filteredTasks.isEmpty
                        ? Center(
                            child: Text(
                              _tuKhoa.isEmpty
                                  ? 'Chưa có task nào'
                                  : 'Không tìm thấy "$_tuKhoa"',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredTasks.length,
                            itemBuilder: (context, index) => TaskCard(
                              task: _filteredTasks[index],
                              onXoa: () => _onXoa(_filteredTasks[index]),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Nhấn vào: ${_filteredTasks[index].tieuDe}'),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
