import 'package:flutter/material.dart';
import '../bai4_api/task_model.dart';
import '../bai4_api/api_client.dart';

// BAI 2 - Mixin: chia se hanh vi khong can ke thua
// Tuan 3 Ngay 3 (Sang)
// extends = "LA MOT" (is-a) — chi 1 class cha
// with    = "CO KHA NANG" (can-do) — nhieu mixin cung luc

mixin LoggerMixin {
  String get _tenClass => runtimeType.toString();
  void logInfo(String msg) {
    final t = DateTime.now().toString().substring(11, 19);
    // ignore: avoid_print
    print('[$t] INFO [$_tenClass] $msg');
  }
  void logLoi(String msg) {
    final t = DateTime.now().toString().substring(11, 19);
    // ignore: avoid_print
    print('[$t] ERROR [$_tenClass] $msg');
  }
}

mixin ValidatorMixin {
  String? validateTieuDe(String? value) {
    if (value == null || value.trim().isEmpty) return 'Tieu de khong duoc trong';
    if (value.trim().length < 3) return 'Tieu de phai it nhat 3 ky tu';
    return null;
  }
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email khong duoc trong';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Email khong hop le';
    return null;
  }
}

// TaskRepository: with LoggerMixin
class TaskRepository with LoggerMixin {
  final ApiClient _api;
  TaskRepository(this._api);
  Future<List<Task>> layTatCa() async {
    logInfo('Bat dau lay danh sach task...');
    try {
      final tasks = await _api.layDanhSachTask();
      logInfo('Lay thanh cong ${tasks.length} tasks');
      return tasks;
    } catch (e) {
      logLoi('Loi khi lay task: $e');
      rethrow;
    }
  }
}

// LoginFormHelper: with ValidatorMixin, LoggerMixin - 2 mixin cung luc!
class LoginFormHelper with ValidatorMixin, LoggerMixin {
  bool validate(String email, String password) {
    final emailErr = validateEmail(email);
    final passErr = password.length < 6 ? 'Mat khau < 6 ky tu' : null;
    if (emailErr != null || passErr != null) {
      logLoi('Validation that bai: email=$emailErr, pass=$passErr');
      return false;
    }
    logInfo('Validation thanh cong cho $email');
    return true;
  }
}

class MixinScreen extends StatefulWidget {
  const MixinScreen({super.key});
  @override
  State<MixinScreen> createState() => _MixinScreenState();
}

// State cung dung duoc Mixin!
class _MixinScreenState extends State<MixinScreen> with LoggerMixin {
  final _loginHelper = LoginFormHelper();
  final _emailCtrl = TextEditingController(text: 'test@gmail.com');
  final _passCtrl = TextEditingController(text: '123456');
  final List<String> _logs = [];
  String? _emailError;
  String? _passError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _validate() {
    final emailErr = _loginHelper.validateEmail(_emailCtrl.text);
    final passErr = _passCtrl.text.length < 6 ? 'Mat khau < 6 ky tu' : null;
    setState(() {
      _emailError = emailErr;
      _passError = passErr;
      if (emailErr == null && passErr == null) {
        _logs.insert(0, 'Validation OK — ${_emailCtrl.text}');
        logInfo('Validate thanh cong tu MixinScreen');
      } else {
        _logs.insert(0, 'Loi: email=$emailErr, pass=$passErr');
        logLoi('Validate that bai tu MixinScreen');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuan 3 Ngay 3 - Mixin Bai 2'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Text(
                'Mixin: tron hanh vi vao nhieu class\n'
                'with LoggerMixin -> log voi timestamp\n'
                'with ValidatorMixin -> validate input\n'
                'Khac extends: dung nhieu mixin cung luc',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(labelText: 'Email', errorText: _emailError, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passCtrl,
              decoration: InputDecoration(labelText: 'Password', errorText: _passError, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700),
                onPressed: _validate,
                child: const Text('Validate (ValidatorMixin + LoggerMixin)'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _logs.isEmpty
                  ? const Center(child: Text('Nhan Validate de thay log\n(kiem tra terminal)', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(_logs[i], style: TextStyle(fontSize: 12, color: _logs[i].startsWith('Loi') ? Colors.red : Colors.green.shade700)),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
