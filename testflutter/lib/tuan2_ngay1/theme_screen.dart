import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_cubit.dart';

/// Màn hình demo HydratedCubit:
/// Bật/tắt Dark Mode → tắt hẳn app → mở lại → theme vẫn giữ nguyên
///
/// LƯU Ý: Không dùng MaterialApp lồng bên trong — sẽ gây màn hình đen
/// Theme được điều khiển từ MyApp bên ngoài thông qua ThemeCubit
class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: const _ThemeView(),
    );
  }
}

class _ThemeView extends StatelessWidget {
  const _ThemeView();

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 2 - Ngày 1: HydratedBloc'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              size: 80,
              color: isDark ? Colors.yellow : Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              isDark ? 'Dark Mode 🌙' : 'Light Mode ☀️',
              style: TextStyle(
                fontSize: 24,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tắt app → mở lại → theme vẫn giữ nguyên',
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Đổi Theme'),
              onPressed: () => context.read<ThemeCubit>().toggle(),
            ),
          ],
        ),
      ),
    );
  }
}
