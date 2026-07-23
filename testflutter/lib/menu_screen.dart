import 'package:flutter/material.dart';
import 'tuan3_ngay8/quick_login_screen.dart';
import 'tuan3_ngay8/bai1_secure_storage_screen.dart';
import 'tuan3_ngay8/bai4_bai5_interceptor_demo_screen.dart';
import 'tuan3_ngay7/bai4_bai5_bai6_bloc_selector_screen.dart';
import 'tuan3_ngay7/bai2_sealed_demo_screen.dart';
import 'tuan3_ngay7/bai3_records_screen.dart';
import 'tuan3_ngay6/bai1_getit_lifecycle_screen.dart';
import 'tuan3_ngay6/bai2_scope_screen.dart';

// MENU SCREEN — chon bai de vao, khong can doi main.dart
// Tuần 3 Ngày 8: them Quick Login + Interceptor Demo

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Learning — Menu'),
        backgroundColor: Colors.deepPurple.shade800,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: 'Tuần 3 Ngày 8 — Token + Interceptor',
            color: Colors.deepPurple.shade700,
            items: [
              _MenuItem(
                title: 'Quick Login',
                subtitle: 'Dang nhap nhanh de test interceptor',
                icon: Icons.login,
                screen: const QuickLoginScreen(),
              ),
              _MenuItem(
                title: 'Bài 4+5: AuthInterceptor Demo',
                subtitle: 'Auto refresh token khi 401',
                icon: Icons.sync,
                screen: const InterceptorDemoScreen(),
              ),
              _MenuItem(
                title: 'Bài 1: Secure Storage',
                subtitle: 'flutter_secure_storage demo',
                icon: Icons.lock,
                screen: const SecureStorageScreen(),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Tuần 3 Ngày 7 — Sealed + Records',
            color: Colors.indigo.shade700,
            items: [
              _MenuItem(
                title: 'Bài 4+5+6: BlocSelector',
                subtitle: 'Optimize rebuild voi selector',
                icon: Icons.widgets,
                screen: const BlocSelectorScreen(),
              ),
              _MenuItem(
                title: 'Bài 2: Sealed Class',
                subtitle: 'Pattern matching voi sealed',
                icon: Icons.code,
                screen: const SealedClassScreen(),
              ),
              _MenuItem(
                title: 'Bài 3: Records',
                subtitle: 'Tuple-like records',
                icon: Icons.data_array,
                screen: const RecordsScreen(),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Tuần 3 Ngày 6 — get_it nâng cao',
            color: Colors.blue.shade700,
            items: [
              _MenuItem(
                title: 'Bài 1: get_it Lifecycle',
                subtitle: 'Singleton + LazySingleton + Factory',
                icon: Icons.settings,
                screen: const GetItLifecycleScreen(),
              ),
              _MenuItem(
                title: 'Bài 2: Scope',
                subtitle: 'Scoped instances',
                icon: Icons.account_tree,
                screen: const ScopeScreen(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Color color,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        ...items.map((item) => _buildItem(context, item, color)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildItem(BuildContext context, _MenuItem item, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(item.icon, color: color),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(item.subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => item.screen),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget screen;

  _MenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.screen,
  });
}
