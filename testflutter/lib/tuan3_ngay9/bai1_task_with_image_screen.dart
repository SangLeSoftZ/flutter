import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../bai4_api/api_client.dart';
import '../bai4_api/task_model.dart';

// BAI 1 — Tuan 3 Ngay 9: them image_picker vao man hinh tao/sua Task
// Dua tren TaskScreen tu bai4_api, them chuc nang:
//   - Nut "Dinh kem anh" mo gallery
//   - Thumbnail preview anh da chon
//   - Nut xoa anh
//   - imageQuality: 80, maxWidth: 1280 (nen anh truoc khi upload)
//
// LUU Y: hien tai chi chon anh local, chua upload len server
// (Bai 3 Chieu se them Dio multipart upload)

class Bai1TaskWithImageScreen extends StatefulWidget {
  const Bai1TaskWithImageScreen({super.key});

  @override
  State<Bai1TaskWithImageScreen> createState() =>
      _Bai1TaskWithImageScreenState();
}

class _Bai1TaskWithImageScreenState extends State<Bai1TaskWithImageScreen> {
  final ApiClient _api = ApiClient();
  final TextEditingController _tieuDeCtrl = TextEditingController();
  final TextEditingController _moTaCtrl = TextEditingController();

  // image_picker
  final ImagePicker _picker = ImagePicker();
  File? _anhDinhKem; // null = chua chon anh

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _layDanhSach();
  }

  @override
  void dispose() {
    _tieuDeCtrl.dispose();
    _moTaCtrl.dispose();
    super.dispose();
  }

  // Mo gallery chon anh
  Future<void> _chonAnh() async {
    final XFile? anh = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,  // nen anh giam dung luong, mat bien kha nang hien thi
      maxWidth: 1280,    // gioi han chieu rong — du net cho man hinh Full HD
    );
    if (anh != null) {
      setState(() => _anhDinhKem = File(anh.path));
    }
  }

  void _xoaAnh() => setState(() => _anhDinhKem = null);

  // GET /api/tasks
  Future<void> _layDanhSach() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final tasks = await _api.layDanhSachTask();
      setState(() => _tasks = tasks);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // POST /api/tasks
  Future<void> _taoTask() async {
    final tieuDe = _tieuDeCtrl.text.trim();
    if (tieuDe.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tiêu đề không được để trống!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final taskMoi = await _api.taoTask(
        tieuDe,
        moTa: _moTaCtrl.text.trim(),
      );
      // Luu trang thai truoc khi reset
      final coAnh = _anhDinhKem != null;
      _tieuDeCtrl.clear();
      _moTaCtrl.clear();
      setState(() => _anhDinhKem = null);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            coAnh
                ? 'Đã tạo task #${taskMoi.id} kèm ảnh (chưa upload server)'
                : 'Đã tạo task #${taskMoi.id}: ${taskMoi.tieuDe}',
          ),
          backgroundColor: Colors.green,
        ),
      );
      await _layDanhSach();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('T3N9 Bai 1 — Task + Anh'),
        backgroundColor: Colors.deepPurple.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: _isLoading ? null : _layDanhSach,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Form tao Task ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.deepPurple.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tieu de
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tieuDeCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Tiêu đề task...',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          isDense: true,
                        ),
                        onSubmitted: (_) => _taoTask(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.deepPurple.shade700),
                      onPressed: _isLoading ? null : _taoTask,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tạo'),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Mo ta (optional)
                TextField(
                  controller: _moTaCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Mô tả (optional)...',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                  maxLines: 2,
                ),

                const SizedBox(height: 8),

                // Hang dinh kem anh
                Row(
                  children: [
                    // Nut chon anh tu gallery
                    OutlinedButton.icon(
                      onPressed: _chonAnh,
                      icon: const Icon(Icons.photo_library, size: 16),
                      label: Text(
                        _anhDinhKem != null ? 'Đổi ảnh' : 'Đính kèm ảnh',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        foregroundColor: Colors.deepPurple,
                        side: BorderSide(color: Colors.deepPurple.shade300),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Preview thumbnail + nut xoa
                    if (_anhDinhKem != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          _anhDinhKem!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: _xoaAnh,
                        icon: const Icon(Icons.close, size: 16),
                        color: Colors.red.shade400,
                        constraints: const BoxConstraints(
                            minWidth: 28, minHeight: 28),
                        padding: EdgeInsets.zero,
                        tooltip: 'Xóa ảnh',
                      ),
                    ] else
                      Text(
                        'Chưa có ảnh (tùy chọn)',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ── Thong bao loi ──────────────────────────────────────
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_errorMessage!,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 13)),
                  ),
                ],
              ),
            ),

          const Divider(height: 1),

          // ── Danh sach Task ─────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                    ? const Center(
                        child: Text(
                          'Chưa có task nào.\nNhấn "Tạo" để thêm!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) =>
                            _TaskCard(task: _tasks[index]),
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Card hien thi 1 task ─────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final Task task;
  const _TaskCard({required this.task});

  Color get _statusColor {
    switch (task.trangThai) {
      case 'HOAN_THANH':
        return Colors.green;
      case 'DANG_LAM':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (task.trangThai) {
      case 'HOAN_THANH':
        return 'Hoàn thành';
      case 'DANG_LAM':
        return 'Đang làm';
      default:
        return 'Chưa xong';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor.withValues(alpha: 0.15),
          child: Text(
            '#${task.id}',
            style: TextStyle(
              color: _statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(task.tieuDe,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: task.moTa.isNotEmpty ? Text(task.moTa) : null,
        trailing: Chip(
          label:
              Text(_statusLabel, style: const TextStyle(fontSize: 11)),
          backgroundColor: _statusColor.withValues(alpha: 0.1),
          side: BorderSide(color: _statusColor.withValues(alpha: 0.4)),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
