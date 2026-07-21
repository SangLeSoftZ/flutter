import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 2 — Widget Test cho Login validation (không gọi API)
// Tuần 2 Ngày 6 (Sáng)
//
// Test 1 form nhập liệu đơn giản — validation trước khi gọi API
// Dùng widget độc lập (không phụ thuộc GetIt/LoginUseCase)
// để test thuần UI validation
//
// Chạy: flutter test test/tuan2_ngay6/bai2_login_validation_test.dart
// ══════════════════════════════════════════════════════════════════

// ── Widget đơn giản để test validation ───────────────────────────
// Tách riêng để không cần setup GetIt/LoginUseCase
class SimpleLoginForm extends StatefulWidget {
  const SimpleLoginForm({super.key});

  @override
  State<SimpleLoginForm> createState() => _SimpleLoginFormState();
}

class _SimpleLoginFormState extends State<SimpleLoginForm> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String? _errorMessage;

  void _validate() {
    setState(() {
      if (_usernameCtrl.text.trim().isEmpty) {
        _errorMessage = 'Username không được để trống';
      } else if (_passwordCtrl.text.length < 6) {
        _errorMessage = 'Mật khẩu phải ít nhất 6 ký tự';
      } else {
        _errorMessage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              key: const Key('username_field'), // ← Key để Finder tìm chính xác
              controller: _usernameCtrl,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('password_field'),
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                key: const Key('error_message'),
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              key: const Key('login_button'),
              onPressed: _validate,
              child: const Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────
void main() {
  Widget buildLoginForm() => const MaterialApp(home: SimpleLoginForm());

  group('Login validation — UI test', () {
    testWidgets('hiển thị lỗi khi username trống', (tester) async {
      await tester.pumpWidget(buildLoginForm());

      // Không nhập gì → bấm đăng nhập
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump(); // ← bắt buộc để rebuild UI

      expect(find.text('Username không được để trống'), findsOneWidget);
    });

    testWidgets('hiển thị lỗi khi mật khẩu dưới 6 ký tự', (tester) async {
      await tester.pumpWidget(buildLoginForm());

      // Nhập username nhưng password ngắn
      await tester.enterText(
          find.byKey(const Key('username_field')), 'admin');
      await tester.enterText(
          find.byKey(const Key('password_field')), '123'); // < 6 ký tự
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      expect(find.text('Mật khẩu phải ít nhất 6 ký tự'), findsOneWidget);
    });

    testWidgets('không hiển thị lỗi khi nhập hợp lệ', (tester) async {
      await tester.pumpWidget(buildLoginForm());

      await tester.enterText(
          find.byKey(const Key('username_field')), 'admin');
      await tester.enterText(
          find.byKey(const Key('password_field')), '123456'); // đủ 6 ký tự
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();

      // Không có lỗi
      expect(find.byKey(const Key('error_message')), findsNothing);
    });

    testWidgets('lỗi username biến mất sau khi nhập đúng', (tester) async {
      await tester.pumpWidget(buildLoginForm());

      // Lần 1: để trống → có lỗi
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();
      expect(find.text('Username không được để trống'), findsOneWidget);

      // Lần 2: nhập đủ → lỗi biến mất
      await tester.enterText(
          find.byKey(const Key('username_field')), 'admin');
      await tester.enterText(
          find.byKey(const Key('password_field')), '123456');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pump();
      expect(find.text('Username không được để trống'), findsNothing);
    });
  });
}
