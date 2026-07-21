import 'package:flutter/foundation.dart';

// ══════════════════════════════════════════════════════════════════
// AUTH STATE — Tuần 2 Ngày 2 (Chiều): Route Guard
//
// Tại sao cần class này thay vì đọc thẳng SecureStorage?
//   - go_router redirect() là ĐỒNG BỘ (synchronous)
//   - SecureStorage.read() là BẤT ĐỒNG BỘ (async/Future)
//   - Không thể await trong redirect() → cần 1 biến bool trong RAM
//
// Giải pháp:
//   - Đọc token 1 lần lúc khởi động app → lưu vào _daDangNhap
//   - Từ đó về sau redirect() đọc _daDangNhap đồng bộ
//   - Khi login/logout → gọi capNhat() → notifyListeners()
//   - go_router nghe qua refreshListenable → tự chạy lại redirect()
// ══════════════════════════════════════════════════════════════════

class AuthState extends ChangeNotifier {
  bool _daDangNhap = false;

  bool get daDangNhap => _daDangNhap;

  // Gọi khi đọc token từ SecureStorage xong (lúc khởi động)
  void khoiTao(bool daCoToken) {
    _daDangNhap = daCoToken;
    // Không notifyListeners() ở đây — GoRouter chưa init xong
  }

  // Gọi sau login thành công hoặc logout
  // notifyListeners() → go_router tự chạy lại redirect()
  void capNhat(bool giaTri) {
    _daDangNhap = giaTri;
    notifyListeners();
  }
}

// Singleton — dùng chung toàn app
final authState = AuthState();
