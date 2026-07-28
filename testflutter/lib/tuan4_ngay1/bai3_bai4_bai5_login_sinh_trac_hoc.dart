import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../login/data/datasources/auth_local_datasource.dart';
import 'bai1_biometric_service.dart';

// BAI 3+4+5 — Tuan 4 Ngay 1 Chieu
// Tich hop sinh trac hoc vao luong dang nhap
//
// BAI 3: Login thường -> hỏi bật sinh trắc học -> lưu cờ
// BAI 4: KiemTraDangNhapScreen -> 3 nhánh điều hướng
// BAI 5: Toàn bộ luồng end-to-end
//
// LUONG THIET KE:
//   LAN DAU: dang nhap email/mat khau -> luu token -> hoi bat sinh trac hoc
//   LAN SAU: kiem tra co + token -> hien man hinh van tay
//            xac thuc OK -> vao app (dung token san co, KHONG goi API dang nhap lai)
//            xac thuc that bai -> ve man hinh dang nhap thuong
//
// Vi sao sinh trac hoc KHONG the la cach dang nhap dau tien?
//   Vi no KHONG tu sinh ra token — chi "mo khoa" token da co san trong SecureStorage
//   Neu chua co token -> khong co gi de mo khoa -> vo nghia

// ════════════════════════════════════════════════════════════════
// BAI 4: KiemTraDangNhapScreen — man hinh splash kiem tra + dieu huong
// 3 nhanh:
//   1. Chua dang nhap (chua co token) -> LoginThuongScreen
//   2. Da dang nhap + da bat sinh trac hoc -> LoginSinhTracHocScreen
//   3. Da dang nhap + chua bat sinh trac hoc -> HomeScreen (vao thang)
// ════════════════════════════════════════════════════════════════
class Bai4KiemTraDangNhapScreen extends StatefulWidget {
  const Bai4KiemTraDangNhapScreen({super.key});

  @override
  State<Bai4KiemTraDangNhapScreen> createState() =>
      _Bai4KiemTraDangNhapScreenState();
}

class _Bai4KiemTraDangNhapScreenState
    extends State<Bai4KiemTraDangNhapScreen> {
  @override
  void initState() {
    super.initState();
    _kiemTraVaDieuHuong();
  }

  Future<void> _kiemTraVaDieuHuong() async {
    final storage = AuthLocalDataSource();

    // Chi kiem tra token CO TON TAI khong — KHONG giai ma JWT thu cong
    // Li do: AuthInterceptor (Tuan 3 Ngay 8) tu dong refresh khi het han
    // Kiem tra het han thu cong o day la trung lap logic
    final accessToken = await storage.getToken();
    final daBat = await storage.daBatSinhTracHoc();

    // Cho 1 chut de widget da build xong
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    if (accessToken == null || accessToken.isEmpty) {
      // Nhanh 1: Chua dang nhap -> ve man hinh dang nhap thuong
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Bai3LoginThuongScreen()),
      );
      return;
    }

    if (daBat) {
      // Nhanh 2: Da bat sinh trac hoc -> hien man hinh van tay
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Bai5LoginSinhTracHocScreen()),
      );
    } else {
      // Nhanh 3: Co token, chua bat sinh trac hoc -> vao thang HomeScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const _HomeGiaDinhScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Man hinh splash — hien spinner trong khi kiem tra
    return Scaffold(
      backgroundColor: Colors.indigo.shade800,
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Đang kiểm tra đăng nhập...',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// BAI 3: LoginThuongScreen — dang nhap bang username/password
// Sau khi dang nhap thanh cong -> hoi bat sinh trac hoc
// ════════════════════════════════════════════════════════════════
class Bai3LoginThuongScreen extends StatefulWidget {
  const Bai3LoginThuongScreen({super.key});

  @override
  State<Bai3LoginThuongScreen> createState() => _Bai3LoginThuongScreenState();
}

class _Bai3LoginThuongScreenState extends State<Bai3LoginThuongScreen> {
  final _usernameCtrl = TextEditingController(text: 'admin');
  final _passwordCtrl = TextEditingController(text: '123456');
  final _authLocal = AuthLocalDataSource();
  final _biometric = BiometricService();
  bool _loading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    try {
      final dio = Dio();
      final response = await dio.post(
        'http://10.0.2.2:8080/api/auth/login',
        data: {
          'username': _usernameCtrl.text.trim(),
          'password': _passwordCtrl.text.trim(),
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      // Luu token vao SecureStorage
      final token = response.data['token'] as String;
      await _authLocal.saveAuthInfo(
        token: token,
        refreshToken: token,
        username: response.data['username'] as String,
        role: response.data['role'] as String,
        userId: response.data['id'].toString(),
      );

      if (!mounted) return;

      // BAI 3: Sau khi dang nhap thanh cong -> hoi bat sinh trac hoc
      await _hoiBatSinhTracHoc();
    } on DioException catch (e) {
      setState(() {
        _errorMsg = e.response?.statusCode == 401
            ? 'Sai username hoặc mật khẩu'
            : 'Lỗi server: ${e.message}';
      });
    } catch (e) {
      setState(() => _errorMsg = 'Lỗi: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // BAI 3: Hoi nguoi dung co muon bat sinh trac hoc khong
  Future<void> _hoiBatSinhTracHoc() async {
    // Kiem tra thiet bi co ho tro sinh trac hoc truoc
    final hoTro = await _biometric.thietBiCoHoTro();

    if (!mounted) return;

    if (!hoTro) {
      // Thiet bi khong ho tro -> vao thang app, khong hoi
      _vaoApp();
      return;
    }

    // Thiet bi ho tro -> hien hop thoai hoi
    final dongY = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // bat buoc chon, khong cho bam vung ngoai
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.fingerprint, color: Colors.indigo),
            SizedBox(width: 8),
            Text('Đăng nhập nhanh hơn?'),
          ],
        ),
        content: const Text(
          'Bật đăng nhập bằng vân tay/Face ID cho lần sau?\n\n'
          'Bạn sẽ không cần nhập mật khẩu mỗi lần mở app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Không, cảm ơn'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: Colors.indigo.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.fingerprint, size: 16),
            label: const Text('Bật lên'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    // Luu co theo lua chon nguoi dung
    await _authLocal.datBatSinhTracHoc(dongY ?? false);

    _vaoApp();
  }

  void _vaoApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const _HomeGiaDinhScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('T4N1 Bai 3 — Đăng nhập thường'),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_open,
                    size: 72, color: Colors.indigo.shade700),
                const SizedBox(height: 24),
                const Text(
                  'Đăng nhập',
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Lần đầu bắt buộc nhập username/password',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  onSubmitted: (_) => _login(),
                ),
                if (_errorMsg != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red.shade600, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _errorMsg!,
                            style: TextStyle(
                                color: Colors.red.shade700, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: _loading ? null : _login,
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.indigo.shade700),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Đăng nhập',
                            style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// BAI 5: LoginSinhTracHocScreen — man hinh dang nhap bang van tay
// Hien khi: da co token + da bat sinh trac hoc
// Xac thuc OK -> vao app (dung token san co, KHONG goi API lai)
// That bai/huy -> ve LoginThuongScreen
// ════════════════════════════════════════════════════════════════
class Bai5LoginSinhTracHocScreen extends StatefulWidget {
  const Bai5LoginSinhTracHocScreen({super.key});

  @override
  State<Bai5LoginSinhTracHocScreen> createState() =>
      _Bai5LoginSinhTracHocScreenState();
}

class _Bai5LoginSinhTracHocScreenState
    extends State<Bai5LoginSinhTracHocScreen> {
  final _biometric = BiometricService();
  final _authLocal = AuthLocalDataSource();
  bool _dangXacThuc = false;
  String? _thongBaoLoi;

  @override
  void initState() {
    super.initState();
    // Tu dong mo hop thoai van tay khi vao man hinh
    _xacThucTuDong();
  }

  Future<void> _xacThucTuDong() async {
    // Cho 1 chut de man hinh build xong
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _xacThuc();
  }

  Future<void> _xacThuc() async {
    setState(() {
      _dangXacThuc = true;
      _thongBaoLoi = null;
    });

    final ketQua = await _biometric.xacThucSinhTracHoc();

    if (!mounted) return;
    setState(() => _dangXacThuc = false);

    if (ketQua == KetQuaXacThuc.thanhCong) {
      // Token DA CO SAN trong SecureStorage tu lan dang nhap thuong truoc do
      // KHONG can goi API dang nhap lai — sinh trac hoc chi "mo khoa" token san co
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const _HomeGiaDinhScreen()),
      );
    } else {
      // That bai -> hien thong bao loi tuong ung
      setState(() {
        _thongBaoLoi = _layThongBaoLoi(ketQua);
      });
    }
  }

  String _layThongBaoLoi(KetQuaXacThuc ketQua) {
    switch (ketQua) {
      case KetQuaXacThuc.thatBai:
        return 'Vân tay không khớp hoặc đã hủy';
      case KetQuaXacThuc.tamKhoa:
        return 'Tạm khóa do sai quá nhiều lần — chờ vài giây';
      case KetQuaXacThuc.chuaPIN:
        return 'Cần cài PIN màn hình khóa trước';
      default:
        return 'Xác thực thất bại';
    }
  }

  void _veDangNhapThuong() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const Bai3LoginThuongScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Icon van tay lon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 72,
                  icon: Icon(
                    Icons.fingerprint,
                    color: _dangXacThuc
                        ? Colors.white.withOpacity(0.5)
                        : Colors.white,
                  ),
                  onPressed: _dangXacThuc ? null : _xacThuc,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                _dangXacThuc
                    ? 'Đang xác thực...'
                    : 'Chạm để đăng nhập\nbằng vân tay/Face ID',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              // Thong bao loi
              if (_thongBaoLoi != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.red.withOpacity(0.5)),
                  ),
                  child: Text(
                    _thongBaoLoi!,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const Spacer(),

              // NUT LUON PHAI CO: loi thoat sang dang nhap thuong
              // UX bat buoc: van tay co the khong hoat dong (tay uot, thiet bi moi)
              // Neu khong co loi thoat -> nguoi dung bi ket hoan toan
              TextButton.icon(
                onPressed: _veDangNhapThuong,
                icon: const Icon(Icons.lock_outline,
                    color: Colors.white70, size: 16),
                label: const Text(
                  'Đăng nhập bằng mật khẩu thay thế',
                  style: TextStyle(color: Colors.white70),
                ),
              ),

              const SizedBox(height: 8),

              // Nut tat sinh trac hoc
              TextButton(
                onPressed: () async {
                  await _authLocal.datBatSinhTracHoc(false);
                  if (mounted) _veDangNhapThuong();
                },
                child: const Text(
                  'Tắt đăng nhập sinh trắc học',
                  style: TextStyle(
                      color: Colors.white38, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Home Screen gia dinh — man hinh "da vao app" de demo
// ════════════════════════════════════════════════════════════════
class _HomeGiaDinhScreen extends StatelessWidget {
  const _HomeGiaDinhScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('T4N1 — Đã vào app!'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              'Đăng nhập thành công!',
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Token đã có sẵn trong SecureStorage\nKhông cần gọi API đăng nhập lại',
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () async {
                final authLocal = AuthLocalDataSource();
                await authLocal.clearAuthInfo(); // xoa ca token + co sinh trac hoc
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => const Bai4KiemTraDangNhapScreen()),
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất (test lại từ đầu)'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('← Quay lại Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
