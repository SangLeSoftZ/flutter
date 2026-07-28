import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'bai1_biometric_service.dart';

// BAI 2 — Man hinh test sinh trac hoc
// Tuan 4 Ngay 1 Sang
//
// Hien thi:
//   - Thiet bi co ho tro khong (isDeviceSupported + canCheckBiometrics)
//   - Danh sach loai sinh trac hoc ho tro
//   - Nut "Xac thuc thu" -> hien hop thoai he thong
//   - Ket qua: thanh cong / cac loai loi cu the

class Bai2BiometricDemoScreen extends StatefulWidget {
  const Bai2BiometricDemoScreen({super.key});

  @override
  State<Bai2BiometricDemoScreen> createState() =>
      _Bai2BiometricDemoScreenState();
}

class _Bai2BiometricDemoScreenState extends State<Bai2BiometricDemoScreen> {
  final BiometricService _service = BiometricService();

  bool? _hoTro;
  List<BiometricType> _danhSachLoai = [];
  KetQuaXacThuc? _ketQua;
  bool _dangKiemTra = false;
  bool _dangXacThuc = false;

  @override
  void initState() {
    super.initState();
    _kiemTraHoTro();
  }

  Future<void> _kiemTraHoTro() async {
    setState(() => _dangKiemTra = true);
    final hoTro = await _service.thietBiCoHoTro();
    final danhSach = await _service.layDanhSachLoaiHoTro();
    setState(() {
      _hoTro = hoTro;
      _danhSachLoai = danhSach;
      _dangKiemTra = false;
    });
  }

  Future<void> _xacThuc() async {
    setState(() {
      _dangXacThuc = true;
      _ketQua = null;
    });
    final ketQua = await _service.xacThucSinhTracHoc();
    setState(() {
      _ketQua = ketQua;
      _dangXacThuc = false;
    });
  }

  // Thong tin hien thi cho tung ket qua
  _ThongTinKetQua _layThongTinKetQua(KetQuaXacThuc ketQua) {
    switch (ketQua) {
      case KetQuaXacThuc.thanhCong:
        return _ThongTinKetQua(
          icon: Icons.check_circle,
          color: Colors.green,
          tieuDe: 'Xác thực thành công!',
          moTa: 'Danh tính xác nhận — token có thể được mở khóa',
        );
      case KetQuaXacThuc.thatBai:
        return _ThongTinKetQua(
          icon: Icons.cancel,
          color: Colors.orange,
          tieuDe: 'Xác thực thất bại hoặc đã hủy',
          moTa: 'Người dùng hủy hoặc vân tay không khớp',
        );
      case KetQuaXacThuc.chuaDangKy:
        // NotEnrolled: chua cai dat van tay trong he thong
        return _ThongTinKetQua(
          icon: Icons.fingerprint,
          color: Colors.blue,
          tieuDe: 'Chưa đăng ký sinh trắc học',
          moTa: 'Vào Cài đặt → Bảo mật → Vân tay để đăng ký trước',
        );
      case KetQuaXacThuc.tamKhoa:
        // LockedOut: sai qua nhieu lan
        return _ThongTinKetQua(
          icon: Icons.lock_clock,
          color: Colors.red,
          tieuDe: 'Tạm khóa do nhập sai nhiều lần',
          moTa: 'Chờ vài chục giây rồi thử lại',
        );
      case KetQuaXacThuc.khoaVinh:
        // PermanentlyLockedOut (chi Android)
        return _ThongTinKetQua(
          icon: Icons.lock,
          color: Colors.red.shade900,
          tieuDe: 'Khóa vĩnh viễn (Android)',
          moTa: 'Cần nhập mã PIN thiết bị trước khi dùng lại sinh trắc học',
        );
      case KetQuaXacThuc.khongHoTro:
        return _ThongTinKetQua(
          icon: Icons.no_encryption,
          color: Colors.grey,
          tieuDe: 'Thiết bị không hỗ trợ',
          moTa: 'Sinh trắc học tạm thời không khả dụng',
        );
      case KetQuaXacThuc.chuaPIN:
        // NotAvailable "Security credentials not available"
        return _ThongTinKetQua(
          icon: Icons.pin,
          color: Colors.purple,
          tieuDe: 'Chưa cài PIN màn hình khóa',
          moTa:
              'Android yêu cầu có PIN/Pattern trước khi dùng vân tay.\n'
              'Vào Settings → Security → Screen lock → PIN → nhập 1234',
        );
      case KetQuaXacThuc.loiKhac:
        return _ThongTinKetQua(
          icon: Icons.error_outline,
          color: Colors.red,
          tieuDe: 'Lỗi không xác định',
          moTa: 'Xem log terminal để biết chi tiết',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('T4N1 Bai 2 — Biometric Demo'),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _kiemTraHoTro,
            tooltip: 'Kiem tra lai',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mo ta
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: const Text(
                'Bai 2: Test sinh trac hoc\n'
                '• local_auth chi xac thuc CUC BO tren thiet bi\n'
                '• Ket qua chi la true/false, khong gui gi len server\n'
                '• Xem terminal: [Biometric] log chi tiet',
                style: TextStyle(fontSize: 12, color: Colors.indigo),
              ),
            ),

            const SizedBox(height: 16),

            // Trang thai ho tro
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trạng thái thiết bị',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_dangKiemTra)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      // isDeviceSupported + canCheckBiometrics
                      _buildTrangThaiRow(
                        icon:
                            _hoTro == true ? Icons.check_circle : Icons.cancel,
                        color: _hoTro == true ? Colors.green : Colors.red,
                        label:
                            _hoTro == true
                                ? 'Thiết bị HỖ TRỢ sinh trắc học'
                                : 'Thiết bị KHÔNG hỗ trợ hoặc chưa đăng ký',
                      ),
                      const SizedBox(height: 8),
                      // Danh sach loai ho tro
                      if (_danhSachLoai.isNotEmpty) ...[
                        const Text(
                          'Loại hỗ trợ:',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        ..._danhSachLoai.map(
                          (loai) => Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.fiber_manual_record,
                                  size: 8,
                                  color: Colors.indigo,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _service.tenLoaiSinhTracHoc(loai),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else
                        Text(
                          'Không tìm thấy sinh trắc học nào',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Nut xac thuc
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.indigo.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: (_hoTro == true && !_dangXacThuc) ? _xacThuc : null,
                icon:
                    _dangXacThuc
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(Icons.fingerprint, size: 20),
                label: Text(_dangXacThuc ? 'Đang xác thực...' : 'Xác thực thử'),
              ),
            ),

            const SizedBox(height: 16),

            // Ket qua xac thuc
            if (_ketQua != null) ...[
              Builder(
                builder: (context) {
                  final info = _layThongTinKetQua(_ketQua!);
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: info.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: info.color.withOpacity(0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(info.icon, color: info.color, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                info.tieuDe,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: info.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                info.moTa,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 24),

            // Ghi chu kien thuc
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: const Text(
                'Kien thuc:\n'
                '• isDeviceSupported(): phan cung co cam bien khong?\n'
                '• canCheckBiometrics: nguoi dung da dang ky chua?\n'
                '• biometricOnly: true = chi van tay, khong cho nhap PIN\n'
                '• stickyAuth: true = giu luong khi app bi an\n'
                '• NotEnrolled: chua cai dat van tay trong he thong\n'
                '• LockedOut: sai qua nhieu lan, cho vai chuc giay\n'
                '• FlutterFragmentActivity: bat buoc cho Android',
                style: TextStyle(fontSize: 11, color: Colors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrangThaiRow({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}

class _ThongTinKetQua {
  final IconData icon;
  final Color color;
  final String tieuDe;
  final String moTa;

  _ThongTinKetQua({
    required this.icon,
    required this.color,
    required this.tieuDe,
    required this.moTa,
  });
}
