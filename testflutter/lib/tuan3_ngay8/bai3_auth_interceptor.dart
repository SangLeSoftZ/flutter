import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../login/data/datasources/auth_local_datasource.dart';

// BAI 3 — AuthInterceptor: tu gan token + tu refresh khi 401
// Tuan 3 Ngay 8 Chieu
// QueuedInterceptor: xu ly tuan tu, tranh nhieu request cung refresh
// _dangRefresh: dam bao /refresh chi goi 1 lan du nhieu request 401
//
// LUONG CHUAN:
//   onRequest: doc access_token tu storage, gan vao header
//   onError(401): goi _lamMoiToken() -> dung refresh_token rieng
//               -> luu access_token moi -> gui lai request goc
//   _lamMoiToken: dung co _dangRefresh, chi refresh 1 lan cho nhieu request 401

class AuthInterceptor extends QueuedInterceptor {
  final Dio _dio;
  final AuthLocalDataSource _authLocal;
  bool _dangRefresh = false;
  static const String _refreshUrl = 'http://10.0.2.2:8080/api/auth/refresh';

  AuthInterceptor(this._dio, this._authLocal);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _authLocal.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      debugPrint(
        '[AuthInterceptor] Gan access token: ${token.length > 20 ? token.substring(0, 20) : token}...',
      );
    } else {
      debugPrint(
        '[AuthInterceptor] Khong co access token — request se nhan 401',
      );
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) return handler.next(err);
    debugPrint(
      '[AuthInterceptor] NHAN 401 tu ${err.requestOptions.path} — bat dau refresh...',
    );
    try {
      final tokenMoi = await _lamMoiToken();
      err.requestOptions.headers['Authorization'] = 'Bearer $tokenMoi';
      debugPrint(
        '[AuthInterceptor] Gui lai request: ${err.requestOptions.path}',
      );
      final response = await _dio.fetch(err.requestOptions);
      debugPrint('[AuthInterceptor] Gui lai THANH CONG');
      handler.resolve(response);
    } catch (e) {
      debugPrint(
        '[AuthInterceptor] Refresh THAT BAI: $e — xoa token, ve Login',
      );
      await _authLocal.clearAuthInfo();
      handler.next(err);
    }
  }

  Future<String> _lamMoiToken() async {
    // Neu da co request khac dang refresh -> cho ket qua do, khong goi them
    if (_dangRefresh) {
      debugPrint(
        '[AuthInterceptor] Dang co refresh khac chay — cho ket qua...',
      );
      while (_dangRefresh) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      final token = await _authLocal.getToken();
      if (token != null && token.isNotEmpty) return token;
      throw Exception('Refresh that bai o request khac');
    }

    _dangRefresh = true;
    debugPrint('[AuthInterceptor] BAT DAU goi /api/auth/refresh...');
    try {
      // Doc REFRESH TOKEN rieng (khac access token)
      final refreshToken = await _authLocal.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('Khong co refresh token');
      }

      // Dung Dio RIENG — khong gan AuthInterceptor, tranh vong lap
      final dioRieng = Dio();
      final info = await _authLocal.getAuthInfo();
      final response = await dioRieng.post(
        _refreshUrl,
        data: {'refreshToken': refreshToken},
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      // Spring Boot tra ve token moi
      final accessTokenMoi =
          response.data['accessToken'] as String? ??
          response.data['token'] as String?;
      if (accessTokenMoi == null)
        throw Exception('Response khong co accessToken');

      final refreshTokenMoi = response.data['refreshToken'] as String?;

      // Luu token moi vao storage
      await _authLocal.saveAuthInfo(
        token: accessTokenMoi,
        refreshToken: refreshTokenMoi, // null = giu nguyen refresh token cu
        username:
            response.data['username'] as String? ?? info['username'] ?? '',
        role: response.data['role'] as String? ?? info['role'] ?? '',
        userId: response.data['id']?.toString() ?? info['userId'] ?? '',
      );

      debugPrint('[AuthInterceptor] Refresh THANH CONG! Token moi da luu.');
      return accessTokenMoi;
    } finally {
      _dangRefresh = false;
    }
  }
}

Dio taoDioChinh(AuthLocalDataSource authLocal) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(AuthInterceptor(dio, authLocal));
  return dio;
}
