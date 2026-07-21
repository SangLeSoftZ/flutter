import 'package:flutter/material.dart';
import '../login/injection_container.dart';
import '../login/domain/usecases/login_usecase.dart';
import '../login/data/datasources/auth_local_datasource.dart';
import '../tuan2_ngay2_guard/auth_state.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 2 — AnimatedOpacity trên Login Screen
// Tuần 2 Ngày 3 (Sáng): Implicit Animation
//
// PHÂN BIỆT với login_screen_guard.dart (Tuần 2 Ngày 2):
//   Ngày 2: error message hiện/ẩn đột ngột (if _errorMessage != null)
//   Ngày 3: error message fade mượt qua AnimatedOpacity
//
// Lưu ý quan trọng về AnimatedOpacity:
//   opacity: 0  → vô hình nhưng VẪN CHIẾM CHỖ trong layout
//   opacity: 1  → hiển thị bình thường
//   Muốn không chiếm chỗ → dùng Visibility hoặc if()
// ══════════════════════════════════════════════════════════════════

class LoginAnimationScreen extends StatefulWidget {
  const LoginAnimationScreen({super.key});

  @override
  State<LoginAnimationScreen> createState() => _LoginAnimationScreenState();
}

class _LoginAnimationScreenState extends State<LoginAnimationScreen> {
  final _userCtrl = TextEditingController(text: 'admin');
  final _passCtrl = TextEditingController(text: '123456');
  final _authLocal = AuthLocalDataSource();

  bool _isLoading = false;
  bool _obscurePass = true;
  String? _errorMessage;
  // bool điều khiển opacity — true = hiện, false = ẩn mượt
  bool _hienLoi = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      // Ẩn lỗi cũ trước khi gọi API
      _hienLoi = false;
      _errorMessage = null;
    });

    final loginUseCase = getIt<LoginUseCase>();
    final (user, failure) = await loginUseCase(
      LoginParams(
          username: _userCtrl.text.trim(), password: _passCtrl.text),
    );

    if (!mounted) return;

    if (failure != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = _mapError(failure.message);
        // Bật opacity → AnimatedOpacity fade-in lỗi mượt 400ms
        _hienLoi = true;
      });
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
    authState.capNhat(true);
  }

  String _mapError(String raw) {
    if (raw.contains('401') || raw.contains('Sai')) return '❌ Sai username hoặc mật khẩu';
    if (raw.contains('Connection refused')) return '📵 Không kết nối được server';
    return '❌ $raw';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 2 Ngày 3 — AnimatedOpacity'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Chú thích
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepOrange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepOrange.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📌 AnimatedOpacity — Error Message',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Nhập sai mật khẩu → lỗi fade-in mượt 400ms'),
                  Text('opacity: 0→1 thay vì if() hiện/ẩn đột ngột',
                      style: TextStyle(color: Colors.deepOrange, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),

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
            TextField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePass
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () =>
                      setState(() => _obscurePass = !_obscurePass),
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: 12),

            // ── AnimatedOpacity cho error message ─────────────
            // KHÁC với if(_errorMessage != null): không "giật"
            // Widget vẫn chiếm chỗ khi opacity=0 — đây là đặc điểm
            // của AnimatedOpacity cần nhớ
            AnimatedOpacity(
              opacity: _hienLoi ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeIn,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage ?? '',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading ? null : _login,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.login),
                label: Text(
                  _isLoading ? 'Đang đăng nhập...' : 'Đăng nhập',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 24),
            // So sánh if() vs AnimatedOpacity
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📚 if() vs AnimatedOpacity',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const Divider(),
                    _compareRow('if()', 'Hiện/ẩn đột ngột\nKhông chiếm chỗ khi ẩn', Colors.red),
                    const SizedBox(height: 8),
                    _compareRow('AnimatedOpacity', 'Fade mượt 400ms\nVẪN chiếm chỗ khi opacity=0', Colors.green),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compareRow(String name, String desc, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color),
          ),
          child: Text(name,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(desc, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}
