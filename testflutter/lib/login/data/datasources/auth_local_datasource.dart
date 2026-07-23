// ════════════════════════════════════════════════════════════════
// FILE: data/datasources/auth_local_datasource.dart
// LOẠI: LOCAL STORAGE — flutter_secure_storage
//
// PHÂN BIỆT với SharedPreferences:
//   SharedPreferences  → lưu plain text (ai có device đọc được)
//   SecureStorage      → mã hoá bằng Keystore (Android) / Keychain (iOS)
//                        phù hợp để lưu JWT token, password, secret key
//
// Tuan 3 Ngay 8: tach rieng access_token va refresh_token
//   access_token  → dung de goi API (ngan han, co the het han)
//   refresh_token → dung de lay access_token moi (dai han)
//   Khi gia lap het han: xoa access_token, giu refresh_token
// ════════════════════════════════════════════════════════════════

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Keys lưu trong SecureStorage
const String kTokenKey = 'auth_token'; // access token
const String kRefreshTokenKey = 'auth_refresh_token'; // refresh token (riêng)
const String kUsernameKey = 'auth_username';
const String kRoleKey = 'auth_role';
const String kUserIdKey = 'auth_user_id';

class AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  AuthLocalDataSource({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  // ── GHI token sau khi login thành công ────────────────────────
  // refreshToken optional: neu Spring Boot chua tra refreshToken rieng,
  // tu dong dung token lam ca 2 (backward compatible)
  Future<void> saveAuthInfo({
    required String token,
    required String username,
    required String role,
    required String userId,
    String? refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: kTokenKey, value: token),
      // Luu refresh token: neu co rieng thi dung rieng, khong thi dung chinh token
      _storage.write(key: kRefreshTokenKey, value: refreshToken ?? token),
      _storage.write(key: kUsernameKey, value: username),
      _storage.write(key: kRoleKey, value: role),
      _storage.write(key: kUserIdKey, value: userId),
    ]);
  }

  // ── ĐỌC access token (dùng để gắn vào Authorization header) ──
  Future<String?> getToken() => _storage.read(key: kTokenKey);

  // ── ĐỌC refresh token (dùng khi access token hết hạn) ────────
  Future<String?> getRefreshToken() => _storage.read(key: kRefreshTokenKey);

  // ── GHI chỉ access token mới (sau khi refresh thành công) ─────
  Future<void> saveAccessToken(String accessToken) =>
      _storage.write(key: kTokenKey, value: accessToken);

  // ── XÓA CHỈ access token — giữ refresh token (để test 401) ───
  Future<void> deleteAccessTokenOnly() => _storage.delete(key: kTokenKey);

  // ── ĐỌC toàn bộ thông tin user đã lưu ────────────────────────
  Future<Map<String, String?>> getAuthInfo() async {
    final results = await Future.wait([
      _storage.read(key: kTokenKey),
      _storage.read(key: kUsernameKey),
      _storage.read(key: kRoleKey),
      _storage.read(key: kUserIdKey),
    ]);
    return {
      'token': results[0],
      'username': results[1],
      'role': results[2],
      'userId': results[3],
    };
  }

  // ── KIỂM TRA đã đăng nhập chưa (dựa vào refresh token còn không)
  // Dùng refresh token vì access token có thể đã hết hạn
  Future<bool> isLoggedIn() async {
    final refreshToken = await getRefreshToken();
    return refreshToken != null && refreshToken.isNotEmpty;
  }

  // ── XÓA tất cả token khi logout ──────────────────────────────
  Future<void> clearAuthInfo() async {
    await Future.wait([
      _storage.delete(key: kTokenKey),
      _storage.delete(key: kRefreshTokenKey),
      _storage.delete(key: kUsernameKey),
      _storage.delete(key: kRoleKey),
      _storage.delete(key: kUserIdKey),
    ]);
  }
}
