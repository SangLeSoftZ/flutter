import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 3 — Định nghĩa lightTheme và darkTheme
// Tuần 2 Ngày 4 (Chiều): Theming
//
// ColorScheme.fromSeed là gì?
//   Thay vì tự định nghĩa từng màu (primary, secondary, error...)
//   chỉ cần 1 màu "hạt giống" → Flutter tự sinh bộ màu hài hòa
//   theo chuẩn Material 3, đảm bảo tương phản tốt (accessibility)
//
// Tại sao định nghĩa theme ở file riêng?
//   Dùng chung cho toàn app, tránh hardcode màu trong từng widget
// ══════════════════════════════════════════════════════════════════

final lightTheme = ThemeData(
  brightness: Brightness.light,
  // Seed color = màu chủ đạo, Flutter tự tạo toàn bộ bộ màu
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  useMaterial3: true,
  textTheme: const TextTheme(
    // titleLarge dùng cho tiêu đề màn hình
    titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    // bodyMedium dùng cho nội dung thông thường
    bodyMedium: TextStyle(fontSize: 14),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 1,
  ),
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  // Cùng seed color nhưng thêm brightness: dark
  // Flutter tự tạo bộ màu tối phù hợp
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    bodyMedium: TextStyle(fontSize: 14),
  ),
  appBarTheme: const AppBarTheme(
    elevation: 1,
  ),
  cardTheme: CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
