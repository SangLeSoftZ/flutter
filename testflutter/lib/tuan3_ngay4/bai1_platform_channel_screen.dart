import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 1 — Platform Channel: gọi code native từ Flutter
// Tuần 3 Ngày 4 (Sáng)
//
// Khi nào dùng Platform Channel?
//   - Tính năng đặc thù OS chưa có package nào hỗ trợ
//   - Luôn tìm package pub.dev TRƯỚC, channel là giải pháp cuối
//
// Cơ chế:
//   Dart gọi invokeMethod('tên') → native nhận → trả kết quả
//   Tên kênh PHẢI khớp chính xác giữa Dart và Kotlin/Swift
//
// Bài 2: gọi method không tồn tại → quan sát PlatformException
// ══════════════════════════════════════════════════════════════════

// ── Service tách riêng — không đặt MethodChannel trong Widget ────
class BatteryService {
  // Tên kênh phải khớp chính xác với Kotlin (như hẹn tần số radio)
  static const _channel = MethodChannel('com.example.testflutter/battery');

  // Bài 1: gọi method có tồn tại bên native
  Future<int> layMucPin() async {
    final int mucPin = await _channel.invokeMethod('getBatteryLevel');
    return mucPin;
  }

  // Bài 2: gọi method KHÔNG tồn tại → PlatformException(not_implemented)
  Future<String> goiMethodKhongTonTai() async {
    final String ketQua = await _channel.invokeMethod('methodKhongCoThatSu');
    return ketQua;
  }

  // Gọi method trả về String (demo thêm)
  Future<String> layThongTinThietBi() async {
    final String info = await _channel.invokeMethod('getDeviceInfo');
    return info;
  }
}

// ── Màn hình demo ─────────────────────────────────────────────────
class PlatformChannelScreen extends StatefulWidget {
  const PlatformChannelScreen({super.key});

  @override
  State<PlatformChannelScreen> createState() => _PlatformChannelScreenState();
}

class _PlatformChannelScreenState extends State<PlatformChannelScreen> {
  final _service = BatteryService();
  String _ketQua = 'Chưa gọi';
  String _loai = '';
  bool _dangGoi = false;
  final List<_LogEntry> _logs = [];

  Future<void> _goiMethod(String loai) async {
    setState(() {
      _dangGoi = true;
      _loai = loai;
      _ketQua = 'Đang gọi native...';
    });

    try {
      String ketQua;
      switch (loai) {
        case 'battery':
          final pin = await _service.layMucPin();
          ketQua = 'Mức pin: $pin%';
          break;
        case 'device':
          ketQua = await _service.layThongTinThietBi();
          break;
        case 'error':
          // Bài 2: cố tình gọi sai method
          ketQua = await _service.goiMethodKhongTonTai();
          break;
        default:
          ketQua = 'Unknown';
      }
      setState(() {
        _ketQua = ketQua;
        _logs.insert(0, _LogEntry(method: loai, result: ketQua, isError: false));
      });
    } on PlatformException catch (e) {
      // PlatformException có 3 trường quan trọng:
      //   e.code    → mã lỗi (VD: "not_implemented", "UNAVAILABLE")
      //   e.message → mô tả lỗi từ native
      //   e.details → thông tin bổ sung (có thể null)
      final msg = 'PlatformException\ncode: ${e.code}\nmessage: ${e.message}';
      setState(() {
        _ketQua = msg;
        _logs.insert(0, _LogEntry(method: loai, result: msg, isError: true));
      });
    } catch (e) {
      setState(() {
        _ketQua = 'Lỗi không xác định: $e';
        _logs.insert(0, _LogEntry(method: loai, result: e.toString(), isError: true));
      });
    } finally {
      setState(() => _dangGoi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 3 Ngày 4 — Platform Channel'),
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chú thích
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.brown.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📌 Platform Channel — Dart ↔ Native',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(
                    'Kênh: com.example.testflutter/battery\n'
                    'Tên kênh PHẢI khớp với Kotlin/Swift\n'
                    'Bài 2: gọi method sai → PlatformException',
                    style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Kết quả hiện tại
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _loai == 'error'
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _loai == 'error'
                        ? Colors.red.shade200
                        : Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kết quả:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _loai == 'error'
                              ? Colors.red.shade700
                              : Colors.green.shade700)),
                  const SizedBox(height: 4),
                  Text(_ketQua,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Nút gọi
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Bài 1: gọi method có tồn tại
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.brown.shade700),
                  onPressed: _dangGoi ? null : () => _goiMethod('battery'),
                  icon: const Icon(Icons.battery_std),
                  label: const Text('Mức pin (Bài 1)'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.blueGrey),
                  onPressed: _dangGoi ? null : () => _goiMethod('device'),
                  icon: const Icon(Icons.phone_android),
                  label: const Text('Thiết bị'),
                ),
                // Bài 2: cố tình gọi sai → PlatformException
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red)),
                  onPressed: _dangGoi ? null : () => _goiMethod('error'),
                  icon: const Icon(Icons.error_outline),
                  label: const Text('Method sai (Bài 2)'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const Text('Log:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),

            Expanded(
              child: _logs.isEmpty
                  ? const Center(
                      child: Text('Nhấn nút để gọi native code',
                          style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (_, i) {
                        final log = _logs[i];
                        return Card(
                          color: log.isError
                              ? Colors.red.shade50
                              : Colors.green.shade50,
                          margin: const EdgeInsets.only(bottom: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      log.isError
                                          ? Icons.error_outline
                                          : Icons.check_circle_outline,
                                      size: 16,
                                      color: log.isError
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(log.method,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12)),
                                  ],
                                ),
                                Text(log.result,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontFamily: 'monospace')),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Giải thích PlatformException
            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📚 PlatformException có 3 trường:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    const Text(
                      'e.code    → "not_implemented" khi method không có\n'
                      'e.message → mô tả từ native\n'
                      'e.details → thông tin bổ sung (nullable)',
                      style:
                          TextStyle(fontSize: 11, fontFamily: 'monospace'),
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
}

class _LogEntry {
  final String method;
  final String result;
  final bool isError;
  _LogEntry({required this.method, required this.result, required this.isError});
}
