import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../login/data/datasources/auth_local_datasource.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 1+2 — flutter_secure_storage: lưu token đúng chuẩn bảo mật
// Tuần 3 Ngày 8 / Tuần 4 Ngày 2 (Sáng)
//
// AuthLocalDataSource HIỆN TẠI đã dùng SecureStorage — không cần migrate
// File này demo trực tiếp cách hoạt động của SecureStorage
//
// Tại sao SecureStorage an toàn hơn SharedPreferences/Hive?
//   SharedPreferences: lưu file plain text → root/jailbreak đọc được
//   SecureStorage:     dùng Android Keystore / iOS Keychain
//                      khóa mã hóa KHÔNG rời khỏi phần cứng bảo mật
//
// API đều là Future vì đọc/ghi qua Platform Channel tới OS
// ══════════════════════════════════════════════════════════════════

// ── SecureTokenStorage riêng cho demo Bài 1 ──────────────────────
class SecureTokenStorage {
  final _storage = const FlutterSecureStorage(
    // BẮT BUỘC bật riêng trên Android — dùng androidx.security
    // Khóa được Android Keystore quản lý, không bao giờ rời phần cứng
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _khoaAccessToken = 'demo_access_token';
  static const _khoaRefreshToken = 'demo_refresh_token';

  Future<void> luuTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _khoaAccessToken, value: accessToken);
    await _storage.write(key: _khoaRefreshToken, value: refreshToken);
  }

  Future<String?> layAccessToken() => _storage.read(key: _khoaAccessToken);
  Future<String?> layRefreshToken() => _storage.read(key: _khoaRefreshToken);

  Future<void> xoaTokens() async {
    await _storage.delete(key: _khoaAccessToken);
    await _storage.delete(key: _khoaRefreshToken);
  }

  Future<Map<String, String?>> layTatCa() async {
    return {
      'access_token': await layAccessToken(),
      'refresh_token': await layRefreshToken(),
    };
  }
}

class SecureStorageScreen extends StatefulWidget {
  const SecureStorageScreen({super.key});

  @override
  State<SecureStorageScreen> createState() => _SecureStorageScreenState();
}

class _SecureStorageScreenState extends State<SecureStorageScreen> {
  final _demo = SecureTokenStorage();
  final _authLocal = AuthLocalDataSource();

  final _accessCtrl = TextEditingController(text: 'eyJhbGciOiJIUzI1NiJ9.demo_access');
  final _refreshCtrl = TextEditingController(text: 'refresh_token_demo_12345');

  String? _accessToken;
  String? _refreshToken;
  bool _daLuu = false;
  String? _authToken; // token thật từ login
  bool _isLoggedIn = false;
  final List<String> _logs = [];

  @override
  void initState() {
    super.initState();
    _docTrangThaiHienTai();
  }

  @override
  void dispose() {
    _accessCtrl.dispose();
    _refreshCtrl.dispose();
    super.dispose();
  }

  void _log(String msg) => setState(() => _logs.insert(0, '${DateTime.now().toString().substring(11, 19)} $msg'));

  Future<void> _docTrangThaiHienTai() async {
    final tokens = await _demo.layTatCa();
    final loggedIn = await _authLocal.isLoggedIn();
    final token = await _authLocal.getToken();
    setState(() {
      _accessToken = tokens['access_token'];
      _refreshToken = tokens['refresh_token'];
      _isLoggedIn = loggedIn;
      _authToken = token;
      _daLuu = _accessToken != null;
    });
    _log('Đọc trạng thái: isLoggedIn=$loggedIn, demoToken=${_accessToken != null ? "có" : "không"}');
  }

  Future<void> _luuTokens() async {
    await _demo.luuTokens(
      accessToken: _accessCtrl.text.trim(),
      refreshToken: _refreshCtrl.text.trim(),
    );
    await _docTrangThaiHienTai();
    _log('✅ Đã lưu vào SecureStorage (Keystore/Keychain)');
    _log('   access: ${_accessCtrl.text.substring(0, 20)}...');
  }

  Future<void> _docTokens() async {
    final access = await _demo.layAccessToken();
    final refresh = await _demo.layRefreshToken();
    setState(() {
      _accessToken = access;
      _refreshToken = refresh;
    });
    _log('📖 Đọc từ SecureStorage:');
    _log('   access: ${access?.substring(0, 20) ?? "null"}...');
    _log('   refresh: ${refresh?.substring(0, 15) ?? "null"}...');
  }

  Future<void> _xoaTokens() async {
    await _demo.xoaTokens();
    await _docTrangThaiHienTai();
    _log('🗑 Đã xóa khỏi SecureStorage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('T3N8 — SecureStorage Bài 1+2'),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _docTrangThaiHienTai),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lý thuyết
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('📌 flutter_secure_storage vs SharedPreferences',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(
                    'SharedPreferences: plain text file → root đọc được\n'
                    'SecureStorage: Android Keystore / iOS Keychain\n'
                    '→ Khóa KHÔNG rời phần cứng bảo mật\n'
                    'API đều Future vì đi qua Platform Channel',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Trạng thái login thật
            Card(
              color: _isLoggedIn ? Colors.green.shade50 : Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Icon(
                      _isLoggedIn ? Icons.lock : Icons.lock_open,
                      color: _isLoggedIn ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AuthLocalDataSource (token thật): ${_isLoggedIn ? "ĐÃ ĐĂNG NHẬP" : "CHƯA ĐĂNG NHẬP"}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isLoggedIn ? Colors.green.shade700 : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          if (_authToken != null)
                            Text(
                              'Token: ${_authToken!.substring(0, _authToken!.length.clamp(0, 30))}...',
                              style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Demo SecureStorage riêng
            const Text('Demo SecureTokenStorage (Bài 1):',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _accessCtrl,
              decoration: const InputDecoration(
                labelText: 'Access Token (demo)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _refreshCtrl,
              decoration: const InputDecoration(
                labelText: 'Refresh Token (demo)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 10),

            // Nút thao tác
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.teal.shade700),
                  onPressed: _luuTokens,
                  icon: const Icon(Icons.save, size: 16),
                  label: const Text('Lưu vào SecureStorage'),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: _docTokens,
                  icon: const Icon(Icons.read_more, size: 16),
                  label: const Text('Đọc lại'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: _daLuu ? _xoaTokens : null,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Xóa'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Hiển thị giá trị đang lưu
            if (_accessToken != null || _refreshToken != null)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✅ Đang lưu trong SecureStorage:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('access_token: ${_accessToken ?? "null"}',
                          style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                      Text('refresh_token: ${_refreshToken ?? "null"}',
                          style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 12),
            const Divider(),
            const Text('Log:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            ..._logs.map((log) => Text(
                  log,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: log.contains('✅') ? Colors.green.shade700 : Colors.grey.shade600,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
