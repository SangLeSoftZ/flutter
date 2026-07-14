import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../login/injection_container.dart';
import '../login/domain/usecases/login_usecase.dart';
import '../login/data/datasources/auth_local_datasource.dart';
import 'auth_state.dart';

// ══════════════════════════════════════════════════════════════════
// LOGIN SCREEN GUARD — Tuần 2 Ngày 2 (Chiều)
//
// KHÁC với tuan2_ngay2/login_screen.dart (buổi sáng):
//   Buổi sáng: context.go('/home') trực tiếp
//   Buổi chiều: authState.capNhat(true) → go_router tự redirect
//     Không cần gọi context.go() nữa — router tự xử lý
// ══════════════════════════════════════════════════════════════════

class LoginScreenGuard extends StatefulWidget {
  const LoginScreenGuard({super.key});

  @override
  State<LoginScreenGuard> createState() => _LoginScreenGuardState();
}

class _LoginScreenGuardState extends State<LoginScreenGuard> {
  final _userCtrl = TextEditingController(text: 'admin');
  final _passCtrl = TextEditingController(text: '123456');
  final _authLocal = AuthLocalDataSource();

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
    setState(() { _isLoading = true; _errorMessage = null; });

    final loginUseCase = getIt<LoginUseCase>();
    final (user, failure) = await loginUseCase(
      LoginParams(username: _userCtrl.text.trim(), password: _passCtrl.text),
    );

    if (!mounted) return;

    if (failure != null) {
      setState(() { _isLoading = false; _errorMessage = _mapError(failure.message); });
      return;
    }

    await _authLocal.saveAuthInfo(
      token: user!.token,
      username: user.username,
      role: user.role,
      userId: user.id,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    // ✅ KHÁC BIỆT CHÍNH: gọi authState thay vì context.go()
    // go_router nghe authState → tự redirect về /home
    authState.capNhat(true);
  }

  String _mapError(String raw) {
    if (raw.contains('Sai username') || raw.contains('401')) return '❌ Sai username hoặc mật khẩu';
    if (raw.contains('Connection refused')) return '📵 Không kết nối được server';
    return '❌ $raw';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 Login — Route Guard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📌 Route Guard — /login', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Sau login → authState.capNhat(true)'),
                  Text('→ go_router tự redirect về /home', style: TextStyle(color: Colors.indigo)),
                  SizedBox(height: 4),
                  Text('Không cần gọi context.go() — router tự xử lý!',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _userCtrl,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: const Icon(Icons.person_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePass ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 8),
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
                child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700)),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _login,
                icon: _isLoading
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.lock_open),
                label: Text(_isLoading ? 'Đang đăng nhập...' : 'Đăng nhập',
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
