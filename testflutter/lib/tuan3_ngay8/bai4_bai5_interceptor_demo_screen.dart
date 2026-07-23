import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../login/data/datasources/auth_local_datasource.dart';
import 'bai3_auth_interceptor.dart';

// BAI 4+5 — Demo AuthInterceptor
// Bai 4: goi API sau khi access token het han -> interceptor tu refresh -> thanh cong
// Bai 5: 3 API song song khi token het han -> /refresh chi goi 1 lan
//
// LUONG TEST BAI 4:
//   1. Dang nhap truoc (de co token trong storage)
//   2. Nhan "Gia lap het han" -> xoa access_token, giu refresh_token
//   3. Nhan "Bai 4: Goi API" -> khong co access token -> server tra 401
//   4. Interceptor nhan 401 -> goi /api/auth/refresh bang refresh_token
//   5. Luu access_token moi -> gui lai request goc -> thanh cong
//
// LUONG TEST BAI 5:
//   1. Nhan "Gia lap het han"
//   2. Nhan "Bai 5: 3 API song song"
//   3. Ca 3 request deu nhan 401, nhung /refresh chi goi 1 lan

class InterceptorDemoScreen extends StatefulWidget {
  const InterceptorDemoScreen({super.key});
  @override
  State<InterceptorDemoScreen> createState() => _InterceptorDemoScreenState();
}

class _InterceptorDemoScreenState extends State<InterceptorDemoScreen> {
  late final Dio _dio;
  final _authLocal = AuthLocalDataSource();
  bool _isLoggedIn = false;
  bool _accessTokenBiXoa = false; // track trang thai gia lap
  final List<String> _logs = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _dio = taoDioChinh(_authLocal);
    _kiemTra();
  }

  void _log(String msg, {LogLevel level = LogLevel.info}) {
    final t = DateTime.now().toString().substring(11, 19);
    setState(() => _logs.insert(0, '${level.prefix}$t $msg'));
  }

  Future<void> _kiemTra() async {
    final ok = await _authLocal.isLoggedIn();
    final accessToken = await _authLocal.getToken();
    setState(() {
      _isLoggedIn = ok;
      _accessTokenBiXoa = ok && (accessToken == null || accessToken.isEmpty);
    });
    if (!ok) {
      _log('Chua dang nhap — can login truoc', level: LogLevel.warn);
    } else if (_accessTokenBiXoa) {
      _log(
        'Da gia lap het han — access token da xoa, refresh token van con',
        level: LogLevel.warn,
      );
    } else {
      _log('Da dang nhap — co ca access + refresh token');
    }
  }

  Future<void> _goiApi() async {
    setState(() => _loading = true);
    _log('--- BAI 4: Goi GET /api/tasks ---');
    try {
      final r = await _dio.get('/api/tasks');
      _log(
        'THANH CONG: ${(r.data as List).length} tasks',
        level: LogLevel.success,
      );
      // sau khi thanh cong, cap nhat lai trang thai (token moi da duoc luu)
      await _kiemTra();
    } on DioException catch (e) {
      _log(
        'THAT BAI: ${e.response?.statusCode} ${e.message}',
        level: LogLevel.error,
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _goiSongSong() async {
    setState(() => _loading = true);
    _log('--- BAI 5: Goi 3 API SONG SONG ---');
    _log(
      'Xem terminal VS Code: [AuthInterceptor] chi xuat hien 1 lan "BAT DAU goi /api/auth/refresh"',
    );
    try {
      final results = await Future.wait([
        _dio.get('/api/tasks'),
        _dio.get('/api/tasks'),
        _dio.get('/api/tasks'),
      ]);
      for (int i = 0; i < results.length; i++) {
        _log(
          '  API ${i + 1}: ${(results[i].data as List).length} tasks',
          level: LogLevel.success,
        );
      }
      _log(
        'CA 3 THANH CONG! Kiem tra terminal: /refresh chi 1 lan',
        level: LogLevel.success,
      );
      await _kiemTra();
    } catch (e) {
      _log('THAT BAI: $e', level: LogLevel.error);
    } finally {
      setState(() => _loading = false);
    }
  }

  // GIA LAP HET HAN: xoa CHI access token, giu refresh token
  // -> khi goi API: khong co token -> server tra 401
  // -> interceptor dung refresh token de lay token moi
  Future<void> _giamLapHetHan() async {
    await _authLocal.deleteAccessTokenOnly();
    setState(() => _accessTokenBiXoa = true);
    _log('--- GIA LAP ACCESS TOKEN HET HAN ---', level: LogLevel.warn);
    _log('  Access token: DA XOA', level: LogLevel.warn);
    _log(
      '  Refresh token: VAN CON (interceptor se dung de refresh)',
      level: LogLevel.warn,
    );
    _log(
      '  -> Nhan "Bai 4" hoac "Bai 5" de test luong 401 -> refresh -> retry',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('T3N8 — AuthInterceptor Bai 4+5'),
        backgroundColor: Colors.deepPurple.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Kiem tra trang thai',
            onPressed: () {
              _kiemTra();
              setState(() => _logs.clear());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusBanner(),
          _buildButtons(),
          const SizedBox(height: 8),
          if (!_isLoggedIn) _buildLoginHint(),
          const Divider(height: 1),
          _buildLogList(),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    String statusText;
    Color statusColor;
    String subText;

    if (!_isLoggedIn) {
      statusText = 'Chua dang nhap';
      statusColor = Colors.orange;
      subText = 'Dang nhap truoc de co token';
    } else if (_accessTokenBiXoa) {
      statusText = 'ACCESS TOKEN DA XOA — san sang test 401';
      statusColor = Colors.orange.shade700;
      subText =
          'Refresh token van con. Nhan Bai 4 hoac Bai 5 de xem interceptor tu refresh.';
    } else {
      statusText = 'Da dang nhap — co ca 2 token';
      statusColor = Colors.green.shade700;
      subText =
          'Bai 4: Goi API -> 401 -> tu refresh -> gui lai\nBai 5: 3 API song song -> /refresh chi 1 lan';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            statusText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subText,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade700,
            ),
            onPressed: _loading ? null : _goiApi,
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Bai 4: Goi API'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: _loading ? null : _goiSongSong,
            icon: const Icon(Icons.call_split, size: 16),
            label: const Text('Bai 5: 3 API song song'),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange.shade700,
              side: BorderSide(color: Colors.orange.shade400),
            ),
            onPressed:
                (!_loading && _isLoggedIn && !_accessTokenBiXoa)
                    ? _giamLapHetHan
                    : null,
            icon: const Icon(Icons.timer_off, size: 16),
            label: const Text('Gia lap het han'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginHint() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: const Text(
        'Can dang nhap truoc:\n1. Doi main.dart ve AuthStartup\n2. Dang nhap admin/123456\n3. Quay lai man nay',
        style: TextStyle(fontSize: 11, color: Colors.orange),
      ),
    );
  }

  Widget _buildLogList() {
    return Expanded(
      child:
          _logs.isEmpty
              ? const Center(
                child: Text(
                  'Nhan nut de test',
                  style: TextStyle(color: Colors.grey),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _logs.length,
                itemBuilder: (_, i) {
                  final log = _logs[i];
                  Color color;
                  if (log.startsWith(LogLevel.error.prefix)) {
                    color = Colors.red.shade700;
                  } else if (log.startsWith(LogLevel.success.prefix)) {
                    color = Colors.green.shade700;
                  } else if (log.startsWith(LogLevel.warn.prefix)) {
                    color = Colors.orange.shade700;
                  } else {
                    color = Colors.grey.shade700;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      log,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: color,
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

enum LogLevel {
  info(''),
  success('✓ '),
  warn('⚠ '),
  error('✗ ');

  final String prefix;
  const LogLevel(this.prefix);
}
