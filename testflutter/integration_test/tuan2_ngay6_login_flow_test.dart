import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:testflutter/bai5_storage/bai2_hive/task_hive_model.dart';
import 'package:testflutter/login/injection_container.dart';
import 'package:testflutter/login/data/datasources/auth_local_datasource.dart';
import 'package:testflutter/tuan2_ngay2_guard/auth_state.dart';
import 'package:testflutter/tuan2_ngay2_guard/app_router_guard.dart';
import 'package:testflutter/tuan2_ngay4_theme/app_themes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testflutter/tuan2_ngay1/theme_cubit.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 4 + 5 — Integration Test: Login flow end-to-end
// Tuần 2 Ngày 6 (Chiều)
//
// PHÂN BIỆT với Widget Test:
//   Widget Test: dựng 1 widget riêng lẻ, không chạy trên thiết bị
//   Integration Test: khởi động TOÀN BỘ app, chạy trên emulator thật
//
// Chạy: flutter test integration_test/tuan2_ngay6_login_flow_test.dart
//
// Yêu cầu: Spring Boot đang chạy tại localhost:8080
// ══════════════════════════════════════════════════════════════════

// Khởi động app đầy đủ cho integration test
Future<void> _startApp(WidgetTester tester) async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await HydratedStorage.build(
    storageDirectory: Directory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );
  HydratedBloc.storage = storage;

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TaskHiveModelAdapter());
  }
  if (!Hive.isBoxOpen(kTaskBox)) {
    await Hive.openBox<TaskHiveModel>(kTaskBox);
  }

  setupLocator();

  final authLocal = AuthLocalDataSource();
  // Xóa token cũ để đảm bảo bắt đầu từ màn Login
  await authLocal.clearAuthInfo();
  authState.khoiTao(false);

  await tester.pumpWidget(
    BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDark) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: Router(
            routerDelegate: appRouterGuard.routerDelegate,
            routeInformationParser: appRouterGuard.routeInformationParser,
            routeInformationProvider: appRouterGuard.routeInformationProvider,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ── Bài 4: Đăng nhập thành công ──────────────────────────────
  testWidgets('Bài 4 — Đăng nhập đúng → chuyển sang Home',
      (tester) async {
    await _startApp(tester);

    // Xác nhận đang ở màn Login
    expect(find.text('Đăng nhập'), findsWidgets);

    // Nhập thông tin đúng
    await tester.enterText(
        find.widgetWithText(TextField, 'Username'), 'admin');
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), '123456');

    // Bấm đăng nhập
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));

    // Chờ API response + điều hướng (timeout 5s)
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Xác nhận đã sang Home
    expect(find.text('Đăng nhập'), findsNothing);
  });

  // ── Bài 5: Đăng nhập sai → vẫn ở Login + hiện lỗi ───────────
  testWidgets('Bài 5 — Đăng nhập sai → vẫn ở Login, hiện lỗi',
      (tester) async {
    await _startApp(tester);

    // Nhập sai mật khẩu
    await tester.enterText(
        find.widgetWithText(TextField, 'Username'), 'admin');
    await tester.enterText(
        find.widgetWithText(TextField, 'Password'), 'sai_mat_khau');

    await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Vẫn ở màn Login (nút Đăng nhập vẫn còn)
    expect(find.widgetWithText(FilledButton, 'Đăng nhập'), findsOneWidget);
    // Hiển thị thông báo lỗi
    expect(find.textContaining('Sai'), findsOneWidget);
  });
}
