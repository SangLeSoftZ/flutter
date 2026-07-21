import 'package:flutter/material.dart';
import '../bai4_api/task_model.dart';

// BAI 3 - Extension method: them ham vao class co san
// Tuan 3 Ngay 3 (Sang)
// Compiler chi la syntactic sugar:
//   task.trangThaiHienThi == TaskExtension(task).trangThaiHienThi

extension TaskExtension on Task {
  String get trangThaiHienThi {
    switch (trangThai) {
      case 'HOAN_THANH': return 'Hoan thanh';
      case 'DANG_LAM':   return 'Dang lam';
      default:           return 'Chua lam';
    }
  }
  Color get mauTrangThai {
    switch (trangThai) {
      case 'HOAN_THANH': return Colors.green;
      case 'DANG_LAM':   return Colors.orange;
      default:           return Colors.grey;
    }
  }
  IconData get iconTrangThai {
    switch (trangThai) {
      case 'HOAN_THANH': return Icons.check_circle;
      case 'DANG_LAM':   return Icons.pending;
      default:           return Icons.circle_outlined;
    }
  }
  bool get tieuDeDai => tieuDe.length > 20;
}

extension StringExtension on String {
  String get vietHoaChuCai => isEmpty ? this : this[0].toUpperCase() + substring(1);
  bool get laEmailHopLe => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  String rutGon(int max) => length <= max ? this : '${substring(0, max)}...';
  String get boDau {
    const w = 'aaaaaaaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    const d = 'aaaaaaaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd';
    // simplified version
    return toLowerCase()
      .replaceAll(RegExp('[àáảãạăắặẳẵằâấầẩẫậ]'), 'a')
      .replaceAll(RegExp('[èéẻẽẹêếềểễệ]'), 'e')
      .replaceAll(RegExp('[ìíỉĩị]'), 'i')
      .replaceAll(RegExp('[òóỏõọôốồổỗộơớờởỡợ]'), 'o')
      .replaceAll(RegExp('[ùúủũụưứừửữự]'), 'u')
      .replaceAll(RegExp('[ỳýỷỹỵ]'), 'y')
      .replaceAll(RegExp('[đ]'), 'd')
      .replaceAll(RegExp('[ÀÁẢÃẠĂẮẶẲẴẰÂẤẦẨẪẬ]'), 'a')
      .replaceAll(RegExp('[ÈÉẺẼẸÊẾỀỂỄỆ]'), 'e')
      .replaceAll(RegExp('[ÌÍỈĨỊ]'), 'i')
      .replaceAll(RegExp('[ÒÓỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢ]'), 'o')
      .replaceAll(RegExp('[ÙÚỦŨỤƯỨỪỬỮỰ]'), 'u')
      .replaceAll(RegExp('[ỲÝỶỸỴ]'), 'y')
      .replaceAll(RegExp('[Đ]'), 'd');
  }
}

extension DateTimeExtension on DateTime {
  String get dinhDangVN => '${day.toString().padLeft(2,'0')}/${month.toString().padLeft(2,'0')}/$year';
  String get thoiGianTuongDoi {
    final diff = DateTime.now().difference(this);
    if (diff.inDays > 0) return '${diff.inDays} ngay truoc';
    if (diff.inHours > 0) return '${diff.inHours} gio truoc';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phut truoc';
    return 'Vua xong';
  }
}

class ExtensionScreen extends StatelessWidget {
  const ExtensionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const tasks = [
      Task(id: 1, tieuDe: 'Hoc Extension method trong Dart', moTa: '', trangThai: 'HOAN_THANH'),
      Task(id: 2, tieuDe: 'Viet bai tap', moTa: '', trangThai: 'DANG_LAM'),
      Task(id: 3, tieuDe: 'On lai', moTa: '', trangThai: 'CHUA_LAM'),
    ];
    final now = DateTime.now();
    final tuanTruoc = now.subtract(const Duration(days: 7));
    final gioTruoc = now.subtract(const Duration(hours: 2));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuan 3 Ngay 3 - Extension Bai 3'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity, padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)),
              child: const Text('Extension: them ham vao class co san\ntask.trangThaiHienThi  — TaskExtension\n"abc".vietHoaChuCai    — StringExtension\nnow.dinhDangVN         — DateTimeExtension', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 12),
            const Text('TaskExtension:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ...tasks.map((t) => Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                leading: Icon(t.iconTrangThai, color: t.mauTrangThai),
                title: Text(t.tieuDe.rutGon(25)),
                subtitle: Text(t.trangThaiHienThi),
                trailing: t.tieuDeDai ? Chip(label: const Text('Dai'), backgroundColor: Colors.orange.shade100) : null,
              ),
            )),
            const SizedBox(height: 12),
            const Text('StringExtension:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            _row('"hoc flutter".vietHoaChuCai', 'hoc flutter'.vietHoaChuCai),
            _row('"test@gmail.com".laEmailHopLe', '${'test@gmail.com'.laEmailHopLe}'),
            _row('"abc".laEmailHopLe', '${'abc'.laEmailHopLe}'),
            _row('"Hoc Flutter".boDau', 'Hoc Flutter'.boDau),
            _row('"Chuoi rat dai nay day".rutGon(10)', 'Chuoi rat dai nay day'.rutGon(10)),
            const SizedBox(height: 12),
            const Text('DateTimeExtension:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            _row('DateTime.now().dinhDangVN', now.dinhDangVN),
            _row('tuanTruoc.thoiGianTuongDoi', tuanTruoc.thoiGianTuongDoi),
            _row('gioTruoc.thoiGianTuongDoi', gioTruoc.thoiGianTuongDoi),
          ],
        ),
      ),
    );
  }

  Widget _row(String code, String result) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(children: [
      Expanded(flex: 3, child: Text(code, style: const TextStyle(fontFamily: 'monospace', fontSize: 11))),
      const Text(' → '),
      Expanded(flex: 2, child: Text(result, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
    ]),
  );
}
