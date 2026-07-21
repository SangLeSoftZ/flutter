import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bai5_droppable_login_bloc.dart';

// BÀI 5 — droppable(): tránh submit trùng
class DroppableLoginScreen extends StatefulWidget {
  const DroppableLoginScreen({super.key});
  @override
  State<DroppableLoginScreen> createState() => _DroppableLoginScreenState();
}

class _DroppableLoginScreenState extends State<DroppableLoginScreen> {
  final _userCtrl = TextEditingController(text: 'admin');
  final _passCtrl = TextEditingController(text: '123456');
  int _soLanBam = 0;
  final List<String> _logs = [];

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginTransformerBloc(),
      child: BlocConsumer<LoginTransformerBloc, LoginTransformerState>(
        listener: (context, state) {
          if (state is LoginTransformerLoading) {
            setState(() => _logs.insert(0, 'Lần bấm $_soLanBam → request được tạo: #${state.lanBam}'));
          } else if (state is LoginTransformerSuccess) {
            setState(() => _logs.insert(0, 'Hoàn thành request #${state.soRequestThucSu} — user: ${state.username}'));
          } else if (state is LoginTransformerError) {
            setState(() => _logs.insert(0, 'Lỗi: ${state.message}'));
          }
        },
        builder: (context, state) {
          final isLoading = state is LoginTransformerLoading;
          return Scaffold(
            appBar: AppBar(
              title: const Text('Tuần 3 Ngày 4 — droppable() Bài 5'),
              backgroundColor: Colors.deepOrange.shade700,
              foregroundColor: Colors.white,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.deepOrange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.deepOrange.shade200)),
                    child: const Text(
                      'droppable(): đang xử lý → BỎ QUA Event mới\n'
                      'Bấm Login liên tục nhiều lần → chỉ request đầu tiên được xử lý\n'
                      'Quan sát: "Số lần bấm" vs "Số request thực sự"',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: _userCtrl, decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder())),
                  const SizedBox(height: 8),
                  TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _chip('Lần bấm', '$_soLanBam', Colors.orange),
                      const SizedBox(width: 8),
                      _chip('Request thực sự',
                        state is LoginTransformerSuccess ? '${state.soRequestThucSu}' : (state is LoginTransformerLoading ? '${state.lanBam}' : '0'),
                        Colors.green),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: Colors.deepOrange.shade700, padding: const EdgeInsets.symmetric(vertical: 14)),
                          onPressed: () {
                            setState(() => _soLanBam++);
                            context.read<LoginTransformerBloc>().add(NhanDangNhap(_userCtrl.text, _passCtrl.text));
                          },
                          icon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.login),
                          label: Text(isLoading ? 'Đang xử lý... (bấm thêm để test droppable)' : 'Đăng nhập — bấm liên tục nhiều lần!'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () { setState(() { _soLanBam = 0; _logs.clear(); }); context.read<LoginTransformerBloc>().add(DangXuat()); },
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Reset',
                      ),
                    ],
                  ),
                  if (state is LoginTransformerSuccess) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)),
                      child: Text('Đăng nhập thành công: ${state.username}\nBấm ${_soLanBam} lần nhưng chỉ ${state.soRequestThucSu} request được xử lý ✅', style: TextStyle(color: Colors.green.shade700)),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Text('Log:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (_, i) => Text(_logs[i], style: TextStyle(fontSize: 11, color: _logs[i].startsWith('Lỗi') ? Colors.red : Colors.grey.shade700)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _chip(String label, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.4))),
    child: Column(children: [Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)), Text(label, style: TextStyle(fontSize: 10, color: color))]),
  );
}
