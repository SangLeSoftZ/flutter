import 'dart:convert';
import 'package:http/http.dart' as http;
import 'task_model.dart';
import '../login/data/datasources/auth_local_datasource.dart';

/// ApiClient gọi Task API Spring Boot.
/// BUG FIX: Gắn Authorization: Bearer token vào mọi request
class ApiClient {
  static const String _baseUrl = 'http://10.0.2.2:8080/api';

  final http.Client _client;
  final AuthLocalDataSource _authLocal;

  ApiClient({http.Client? client, AuthLocalDataSource? authLocal})
    : _client = client ?? http.Client(),
      _authLocal = authLocal ?? AuthLocalDataSource();

  /// Tạo header đầy đủ — tự động lấy token từ SecureStorage
  Future<Map<String, String>> _buildHeaders({
    bool withContentType = false,
  }) async {
    final token = await _authLocal.getToken();
    return {
      'Accept': 'application/json',
      if (withContentType) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ── GET /baiA ─────────────────────────────────────────────────────────────

  Future<List<Task>> layDanhSachTask() async {
    final uri = Uri.parse('$_baseUrl/tasks');
    final headers = await _buildHeaders();
    try {
      final response = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;
        return json
            .map((e) => Task.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw Exception('Lỗi 401 — token hết hạn hoặc chưa đăng nhập');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('layDanhSachTask lỗi kết nối: $e');
    }
  }

  // ── POST /baiA ────────────────────────────────────────────────────────────

  Future<Task> taoTask(
    String tieuDe, {
    String moTa = '',
    String trangThai = 'CHUA_XONG',
  }) async {
    final uri = Uri.parse('$_baseUrl/tasks');
    final headers = await _buildHeaders(withContentType: true);
    final body = jsonEncode({
      'tieuDe': tieuDe,
      'moTa': moTa,
      'trangThai': trangThai,
    });

    try {
      final response = await _client
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Task.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else if (response.statusCode == 400) {
        // BUG FIX: hiện lỗi validation rõ ràng thay vì lỗi chung chung
        final err = jsonDecode(response.body);
        final msg =
            err['message'] ??
            err['errors']?.toString() ??
            'Dữ liệu không hợp lệ';
        throw Exception('Validation: $msg');
      } else if (response.statusCode == 401) {
        throw Exception('Lỗi 401 — token hết hạn hoặc chưa đăng nhập');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('taoTask lỗi kết nối: $e');
    }
  }

  // ── GET /tasks/search — Tuần 3 Ngày 2: Debounce ──────────────────────────
  // Tìm kiếm task theo từ khóa — client-side filter (không cần endpoint mới)

  // Bỏ dấu tiếng Việt — gõ "hoc" tìm được "Học", gõ "lam" tìm được "làm"
  String _boDau(String text) {
    const withDau  = 'àáảãạăắặẳẵằâấầẩẫậèéẻẽẹêếềểễệìíỉĩịòóỏõọôốồổỗộơớờởỡợùúủũụưứừửữựỳýỷỹỵđ'
                     'ÀÁẢÃẠĂẮẶẲẴẰÂẤẦẨẪẬÈÉẺẼẸÊẾỀỂỄỆÌÍỈĨỊÒÓỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢÙÚỦŨỤƯỨỪỬỮỰỲÝỶỸỴĐ';
    const khongDau = 'aaaaaaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiioooooooooooooooooouuuuuuuuuuuyyyyyd'
                     'aaaaaaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiioooooooooooooooooouuuuuuuuuuuyyyyyd';
    var result = text;
    for (var i = 0; i < withDau.length; i++) {
      result = result.replaceAll(withDau[i], khongDau[i]);
    }
    return result.toLowerCase();
  }

  Future<List<Task>> timKiemTask(String tuKhoa) async {
    final allTasks = await layDanhSachTask();
    if (tuKhoa.isEmpty) return allTasks;
    final keyword = _boDau(tuKhoa);
    return allTasks
        .where((t) =>
            _boDau(t.tieuDe).contains(keyword) ||
            _boDau(t.moTa).contains(keyword))
        .toList();
  }
}
