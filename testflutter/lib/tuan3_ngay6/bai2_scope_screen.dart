import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 2 — get_it Scope: dữ liệu tạm theo luồng nhiều bước
// Tuần 3 Ngày 6 (Sáng)
//
// Luồng giả lập: Tạo Task 3 bước
//   Bước 1: Nhập tiêu đề
//   Bước 2: Chọn trạng thái
//   Bước 3: Xác nhận
//
// pushNewScope: tạo "lớp" đăng ký mới, sống trong luồng này
// popScope: dọn sạch khi thoát luồng
// Dữ liệu giữ nguyên xuyên suốt các bước nhờ LazySingleton trong scope
// ══════════════════════════════════════════════════════════════════

// ── Dữ liệu tạm cho luồng tạo Task ──────────────────────────────
class TaoTaskFormState {
  String tieuDe = '';
  String trangThai = 'CHUA_LAM';
  bool daXacNhan = false;

  @override
  String toString() => 'TaoTaskFormState(tieuDe="$tieuDe", trangThai=$trangThai)';
}

class ScopeScreen extends StatefulWidget {
  const ScopeScreen({super.key});

  @override
  State<ScopeScreen> createState() => _ScopeScreenState();
}

class _ScopeScreenState extends State<ScopeScreen> {
  final _getIt = GetIt.instance;
  bool _scopeActive = false;
  int _buocHienTai = 0;
  final List<String> _logs = [];
  final _tieuDeCtrl = TextEditingController();

  @override
  void dispose() {
    _tieuDeCtrl.dispose();
    // Đảm bảo scope được dọn khi widget bị huỷ
    if (_scopeActive) _getIt.popScope();
    super.dispose();
  }

  void _log(String msg) => setState(() => _logs.insert(0, msg));

  void _batDauLuong() {
    // pushNewScope: tạo "lớp" đăng ký mới trên đỉnh stack
    _getIt.pushNewScope(
      scopeName: 'tao-task-scope',
      init: (scope) {
        // Đăng ký TaoTaskFormState trong scope này
        // LazySingleton trong scope → tạo 1 lần, dùng xuyên suốt luồng
        scope.registerLazySingleton<TaoTaskFormState>(() => TaoTaskFormState());
      },
    );
    setState(() {
      _scopeActive = true;
      _buocHienTai = 1;
    });
    _log('✅ pushNewScope("tao-task-scope") — bắt đầu luồng');
  }

  void _buoc1LuuTieuDe() {
    final form = _getIt<TaoTaskFormState>();
    form.tieuDe = _tieuDeCtrl.text.trim().isEmpty
        ? 'Task mẫu ${DateTime.now().second}'
        : _tieuDeCtrl.text.trim();
    setState(() => _buocHienTai = 2);
    _log('Bước 1: tieuDe="${form.tieuDe}"');
    _log('→ Cùng instance xuyên suốt luồng: ${form.hashCode}');
  }

  void _buoc2ChonTrangThai(String tt) {
    final form = _getIt<TaoTaskFormState>();
    form.trangThai = tt;
    setState(() => _buocHienTai = 3);
    _log('Bước 2: trangThai=$tt');
    _log('→ Cùng instance: ${form.hashCode} — tieuDe vẫn="${form.tieuDe}"');
  }

  void _buoc3XacNhan() {
    final form = _getIt<TaoTaskFormState>();
    form.daXacNhan = true;
    _log('Bước 3 xác nhận: $form');
    _log('→ Cùng instance: ${form.hashCode}');
    // Hoàn tất → popScope dọn sạch
    _getIt.popScope();
    setState(() {
      _scopeActive = false;
      _buocHienTai = 0;
      _tieuDeCtrl.clear();
    });
    _log('✅ popScope() — scope đã bị huỷ, TaoTaskFormState bị dọn sạch');
  }

  void _huyLuong() {
    _getIt.popScope();
    setState(() {
      _scopeActive = false;
      _buocHienTai = 0;
      _tieuDeCtrl.clear();
    });
    _log('❌ Hủy luồng → popScope() — dữ liệu tạm bị xóa');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 3 Ngày 6 — Scope Bài 2'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: Text(
                '📌 Scope: dữ liệu tạm theo luồng\n'
                'pushNewScope → tạo scope mới\n'
                'TaoTaskFormState sống trong scope này\n'
                'popScope → dọn sạch khi xong/hủy\n\n'
                'Trạng thái: ${_scopeActive ? "🟢 Scope active (bước $_buocHienTai/3)" : "⚪ Chưa có scope"}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),

            if (!_scopeActive) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.deepPurple),
                  onPressed: _batDauLuong,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Bắt đầu luồng Tạo Task'),
                ),
              ),
            ] else ...[
              // Bước 1
              if (_buocHienTai == 1) ...[
                const Text('Bước 1/3: Nhập tiêu đề',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _tieuDeCtrl,
                  decoration: const InputDecoration(
                      hintText: 'Nhập tiêu đề task...', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: Colors.deepPurple),
                      onPressed: _buoc1LuuTieuDe,
                      child: const Text('Tiếp theo →'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: _huyLuong, child: const Text('Hủy')),
                ]),
              ],

              // Bước 2
              if (_buocHienTai == 2) ...[
                const Text('Bước 2/3: Chọn trạng thái',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(children: [
                  for (final tt in ['CHUA_LAM', 'DANG_LAM', 'HOAN_THANH'])
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: OutlinedButton(
                          onPressed: () => _buoc2ChonTrangThai(tt),
                          child: Text(tt.split('_').first,
                              style: const TextStyle(fontSize: 11)),
                        ),
                      ),
                    ),
                ]),
                const SizedBox(height: 4),
                OutlinedButton(onPressed: _huyLuong, child: const Text('Hủy luồng')),
              ],

              // Bước 3
              if (_buocHienTai == 3) ...[
                const Text('Bước 3/3: Xác nhận',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_scopeActive && _getIt.isRegistered<TaoTaskFormState>())
                  Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tiêu đề: ${_getIt<TaoTaskFormState>().tieuDe}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Trạng thái: ${_getIt<TaoTaskFormState>().trangThai}'),
                          Text('Instance: ${_getIt<TaoTaskFormState>().hashCode}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: _buoc3XacNhan,
                      icon: const Icon(Icons.check),
                      label: const Text('Xác nhận tạo Task'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: _huyLuong, child: const Text('Hủy')),
                ]),
              ],
            ],

            const SizedBox(height: 8),
            const Divider(),
            const Text('Log:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (_, i) => Text(_logs[i],
                    style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: _logs[i].startsWith('✅')
                            ? Colors.green.shade700
                            : _logs[i].startsWith('❌')
                                ? Colors.red
                                : Colors.grey.shade700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
