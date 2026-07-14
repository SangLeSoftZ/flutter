import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Dùng lại toàn bộ layer data từ bài login clean architecture
import '../login/injection_container.dart';
import '../login/domain/usecases/login_usecase.dart';
import '../login/data/datasources/auth_local_datasource.dart';

// ══════════════════════════════════════════════════════════════════
// MÀN HÌNH LOGIN — tuan2_ngay2
//
// Kết nối vào database/API thật từ bài login:
//   - LoginUseCase    → validate + gọi API Spring Boot
//   - AuthLocalDataSource → lưu token vào SecureStorage sau login
//
// Điều hướng vẫn dùng go_router:
//   - Thành công → context.go('/home')  ← xóa /login khỏi stack
//   - Thất bại   → hiển thị lỗi
//
// Tài khoản mẫu (từ database Spring Boot):
//   admin / 123456
//   user1 / 123456
//   manager / 123456
// ══════════════════════════════════════════════════════════════════

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController(text: 'admin');
  final _passCtrl = TextEditingController(text: '123456');
  final _authLocal = AuthLocalDataSource(); // lưu token sau login

  bool _isLoading = false;
  bool _obscurePass = true;
  String? _errorMessage;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Lấy LoginUseCase từ GetIt (đã đăng ký trong setupLocator())
    final loginUseCase = getIt<LoginUseCase>();
    final (user, failure) = await loginUseCase(
      LoginParams(
        username: _userCtrl.text.trim(),
        password: _passCtrl.text,
      ),
    );

    if (!mounted) return;

    if (failure != null) {
      // Hiển thị lỗi rõ ràng — từ ValidationFailure hoặc NetworkFailure
      setState(() {
        _isLoading = false;
        _errorMessage = _mapError(failure.message);
      });
      return;
    }

    // Lưu token vào SecureStorage (giống bài login cũ)
    await _authLocal.saveAuthInfo(
      token: user!.token,
      username: user.username,
      role: user.role,
      userId: user.id,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    // ✅ DÙNG go_router — xóa /login khỏi stack, không back về được
    context.go('/home');
  }

  String _mapError(String raw) {
    if (raw.contains('Sai username') || raw.contains('401')) {
      return '❌ Sai username hoặc mật khẩu';
    }
    if (raw.contains('khóa') || raw.contains('403')) {
      return '🔒 Tài khoản bị khóa. Liên hệ admin.';
    }
    if (raw.contains('timeout') || raw.contains('Timeout')) {
      return '⏱ Server phản hồi quá chậm — thử lại sau';
    }
    if (raw.contains('SocketException') || raw.contains('Connection refused')) {
      return '📵 Không kết nối được server\nKiểm tra Spring Boot có đang chạy không?';
    }
    return '❌ $raw';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 Login — go_router + database'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ── Chú thích route ───────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📌 Route: /login',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Dùng LoginUseCase + AuthLocalDataSource từ bài login'),
                  Text('Thành công → context.go("/home") — xóa stack',
                      style: TextStyle(color: Colors.deepPurple)),
                  SizedBox(height: 4),
                  Text('Tài khoản: admin / user1 / manager  |  Pass: 123456',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Username ──────────────────────────────────────────
            TextField(
              controller: _userCtrl,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: const Icon(Icons.person_outlined),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),

            // ── Password ──────────────────────────────────────────
            TextField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscurePass ? Icons.visibility_off : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscurePass = !_obscurePass),
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _login(),
            ),

            const SizedBox(height: 8),

            // ── Thông báo lỗi ─────────────────────────────────────
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                ),
              ),

            const SizedBox(height: 16),

            // ── Nút đăng nhập ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _login,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.login),
                label: Text(
                  _isLoading ? 'Đang đăng nhập...' : 'Đăng nhập',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
