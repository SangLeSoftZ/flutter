import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../login/data/datasources/auth_local_datasource.dart';

// QUICK LOGIN — dang nhap nhanh de test interceptor
// Khong can doi main.dart ve AuthStartup, login truc tiep trong nay

class QuickLoginScreen extends StatefulWidget {
  const QuickLoginScreen({super.key});
  @override
  State<QuickLoginScreen> createState() => _QuickLoginScreenState();
}

class _QuickLoginScreenState extends State<QuickLoginScreen> {
  final _usernameCtrl = TextEditingController(text: 'admin');
  final _passwordCtrl = TextEditingController(text: '123456');
  final _authLocal = AuthLocalDataSource();
  bool _loading = false;
  String? _errorMsg;
  bool _isLoggedIn = false;
  String? _currentUser;

  @override
  void initState() {
    super.initState();
    _kiemTra();
  }

  Future<void> _kiemTra() async {
    final ok = await _authLocal.isLoggedIn();
    if (ok) {
      final info = await _authLocal.getAuthInfo();
      setState(() {
        _isLoggedIn = true;
        _currentUser = info['username'];
      });
    }
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    try {
      final dio = Dio();
      final response = await dio.post(
        'http://10.0.2.2:8080/api/auth/login',
        data: {
          'username': _usernameCtrl.text.trim(),
          'password': _passwordCtrl.text.trim(),
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      // Luu token vao storage (dung token lam ca access + refresh)
      final token = response.data['token'] as String;
      await _authLocal.saveAuthInfo(
        token: token,
        refreshToken: token, // tam thoi dung chung 1 token
        username: response.data['username'] as String,
        role: response.data['role'] as String,
        userId: response.data['id'].toString(),
      );

      if (mounted) {
        setState(() {
          _isLoggedIn = true;
          _currentUser = response.data['username'] as String;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Dang nhap thanh cong! Quay lai Interceptor Demo de test'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      setState(() {
        _errorMsg = e.response?.statusCode == 401
            ? 'Sai username hoac password'
            : 'Loi server: ${e.message}';
      });
    } catch (e) {
      setState(() => _errorMsg = 'Loi: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await _authLocal.clearAuthInfo();
    setState(() {
      _isLoggedIn = false;
      _currentUser = null;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da dang xuat')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Login'),
        backgroundColor: Colors.deepPurple.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isLoggedIn ? Icons.check_circle : Icons.login,
                  size: 80,
                  color: _isLoggedIn ? Colors.green : Colors.deepPurple,
                ),
                const SizedBox(height: 24),
                if (_isLoggedIn) ...[
                  Text(
                    'Da dang nhap',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Username: $_currentUser',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Dang xuat'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Quay lai Menu'),
                  ),
                ] else ...[
                  const Text(
                    'Dang nhap nhanh',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mac dinh: admin / 123456',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  if (_errorMsg != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMsg!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _loading ? null : _login,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade700,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Dang nhap'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }
}
