import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 1 — get_it nâng cao: vòng đời và registerFactoryParam
// Tuần 3 Ngày 6 (Sáng)
//
// Rà soát injection_container.dart:
//   LoginUseCase dùng registerFactory — đúng vì UseCase không có state
//   http.Client dùng registerLazySingleton — đúng, dùng chung toàn app
//   AuthRepository dùng registerLazySingleton — đúng, không có state
//
// Demo thêm: registerFactoryParam — factory với tham số
// ══════════════════════════════════════════════════════════════════

final _demoGetIt = GetIt.asNewInstance();

// ── Model giả lập cho demo ────────────────────────────────────────
class TaskDetailService {
  final int taskId;
  final String tenService;
  TaskDetailService(this.taskId)
      : tenService = 'TaskDetailService#$taskId-${DateTime.now().millisecondsSinceEpoch % 1000}';
}

class AppLogger {
  final String _name = 'AppLogger-${DateTime.now().millisecondsSinceEpoch % 1000}';
  String get name => _name;
  void log(String msg) {
    // ignore: avoid_print
    print('[$_name] $msg');
  }
}

// ── Setup demo ────────────────────────────────────────────────────
void _setupDemo() {
  if (_demoGetIt.isRegistered<AppLogger>()) return;

  // Singleton: chỉ tạo 1 lần, dùng mãi
  _demoGetIt.registerLazySingleton<AppLogger>(() => AppLogger());

  // Factory: tạo mới mỗi lần → mỗi lần gọi có taskId khác nhau
  // registerFactoryParam: factory nhận tham số
  _demoGetIt.registerFactoryParam<TaskDetailService, int, void>(
    (taskId, _) => TaskDetailService(taskId),
  );
}

class GetItLifecycleScreen extends StatefulWidget {
  const GetItLifecycleScreen({super.key});

  @override
  State<GetItLifecycleScreen> createState() => _GetItLifecycleScreenState();
}

class _GetItLifecycleScreenState extends State<GetItLifecycleScreen> {
  final List<String> _logs = [];
  int _taskIdCounter = 1;

  @override
  void initState() {
    super.initState();
    _setupDemo();
    _log('GetIt demo khởi tạo xong');
  }

  void _log(String msg) => setState(() => _logs.insert(0, msg));

  void _testSingleton() {
    final a = _demoGetIt<AppLogger>();
    final b = _demoGetIt<AppLogger>();
    final same = a.name == b.name;
    _log('Singleton: a=${a.name.split('-').last} b=${b.name.split('-').last} → ${same ? "CÙNG instance ✅" : "KHÁC instance ❌"}');
  }

  void _testFactory() {
    final id = _taskIdCounter++;
    // registerFactoryParam — truyền taskId lúc lấy ra
    final s = _demoGetIt<TaskDetailService>(param1: id);
    _log('FactoryParam(taskId=$id): ${s.tenService}');
    _log('→ Mỗi lần gọi = instance mới với taskId riêng');
  }

  void _testFactoryKhacNhau() {
    final s1 = _demoGetIt<TaskDetailService>(param1: 10);
    final s2 = _demoGetIt<TaskDetailService>(param1: 20);
    _log('Factory(10): ${s1.tenService}');
    _log('Factory(20): ${s2.tenService}');
    _log('→ 2 instance khác nhau, taskId khác nhau');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 3 Ngày 6 — get_it Bài 1'),
        backgroundColor: Colors.brown.shade700,
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
                color: Colors.brown.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.brown.shade200),
              ),
              child: const Text(
                '📌 get_it vòng đời:\n'
                'Singleton: tạo 1 lần, dùng mãi → cùng instance\n'
                'Factory: tạo mới mỗi lần → khác instance\n'
                'FactoryParam: factory + tham số lúc lấy ra',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            // Rà soát injection_container
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('✅ Rà soát injection_container.dart:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text(
                      'http.Client → LazySingleton ✅ (dùng chung)\n'
                      'AuthRemoteDataSource → LazySingleton ✅ (không state)\n'
                      'AuthRepository → LazySingleton ✅ (không state)\n'
                      'LoginUseCase → Factory ✅ (stateless, nhẹ, tạo mới OK)\n'
                      '\nKhông có chỗ nào sai vòng đời cần sửa.',
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.brown.shade700),
                  onPressed: _testSingleton,
                  child: const Text('Test Singleton'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.indigo),
                  onPressed: _testFactory,
                  child: const Text('Test FactoryParam'),
                ),
                OutlinedButton(
                  onPressed: _testFactoryKhacNhau,
                  child: const Text('2 Factory khác nhau'),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => _logs.clear()),
                  child: const Text('Xóa log'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            Expanded(
              child: _logs.isEmpty
                  ? const Center(child: Text('Nhấn nút để test', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(_logs[i],
                            style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: _logs[i].contains('✅')
                                    ? Colors.green.shade700
                                    : _logs[i].contains('❌')
                                        ? Colors.red
                                        : Colors.grey.shade700)),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
