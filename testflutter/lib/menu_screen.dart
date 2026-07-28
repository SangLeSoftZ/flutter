import 'package:flutter/material.dart';
import 'tuan4_ngay1/bai1_biometric_service.dart';
import 'tuan4_ngay1/bai2_biometric_demo_screen.dart';
import 'tuan4_ngay1/bai3_bai4_bai5_login_sinh_trac_hoc.dart';
import 'tuan3_ngay9/bai1_task_with_image_screen.dart';
import 'tuan3_ngay9/bai1_image_picker_screen.dart';
import 'tuan3_ngay9/bai2_file_picker_screen.dart';
import 'tuan3_ngay9/bai4_bai5_upload_screen.dart';
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
            title: 'Tuần 4 Ngày 1 — Sinh trắc học',
            color: Colors.indigo.shade700,
            items: [
              _MenuItem(
                title: 'Bài 2: Biometric Demo',
                subtitle: 'Test vân tay/Face ID, kiem tra ho tro, xu ly loi',
                icon: Icons.fingerprint,
                screen: const Bai2BiometricDemoScreen(),
              ),
              _MenuItem(
                title: 'Bài 3+4+5: Luồng Login Sinh trắc học',
                subtitle:
                    'Login -> hoi bat van tay -> kiem tra -> dang nhap nhanh',
                icon: Icons.login,
                screen: const Bai4KiemTraDangNhapScreen(),
              ),
            ],
          ),
          _buildSection(
            context,
            title: 'Tuần 3 Ngày 9 — File Upload',
            color: Colors.deepOrange.shade700,
            items: [
              _MenuItem(
                title: 'Bài 1: Task + Đính kèm ảnh',
                subtitle: 'Tao/sua Task voi nut chon anh tu gallery',
                icon: Icons.task_alt,
                screen: const Bai1TaskWithImageScreen(),
              ),
              _MenuItem(
                title: 'Bài 1: image_picker',
                subtitle: 'Chon anh gallery/camera, preview, nen chat luong',
                icon: Icons.photo_library,
                screen: const Bai1ImagePickerScreen(),
              ),
              _MenuItem(
                title: 'Bài 2: file_picker',
                subtitle: 'Chon tai lieu PDF/DOC/XLSX, hien thi thong tin',
                icon: Icons.attach_file,
                screen: const Bai2FilePickerScreen(),
              ),
              _MenuItem(
                title: 'Bài 4+5: Upload + Tiến trình',
                subtitle:
                    'Dio multipart, LinearProgressIndicator, xu ly loi 413/timeout',
                icon: Icons.cloud_upload,
                screen: const Bai4Bai5UploadScreen(),
              ),
            ],
          ),
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
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap:
            () => Navigator.push(
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
