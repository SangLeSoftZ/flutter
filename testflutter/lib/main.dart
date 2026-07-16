// ignore_for_file: unused_import
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

// ── State Management ─────────────────────────────────────────────
import 'login/injection_container.dart';

// ── Bài 2: Hive ──────────────────────────────────────────────────
import 'bai5_storage/bai2_hive/task_hive_model.dart';
import 'bai5_storage/bai2_hive/hive_task_screen.dart';

// ── Bài 1: Onboarding ────────────────────────────────────────────
import 'bai5_storage/bai1_onboarding/app_startup.dart';

// ── Bài 3: MultiBlocProvider ─────────────────────────────────────
import 'bai5_storage/bai3_multi_bloc/multi_bloc_demo_screen.dart';

// ── Bài 3 cũ: FavoriteScreen ─────────────────────────────────────
import 'bai3_favorite/favorite_screen.dart';

// ── Bài 4: Task API ───────────────────────────────────────────────
import 'bai4_api/task_screen.dart';

// ── Login cũ ─────────────────────────────────────────────────────
import 'login_page.dart';

// ── Bài 4+5: Auth flow hoàn chỉnh (AuthStartup + Profile) ────────
import 'login/presentation/auth_startup.dart';
import 'login/presentation/login_clean_screen.dart';

// ── Tuần 2 Ngày 1: BlocObserver + HydratedBloc ───────────────────
import 'tuan2_ngay1/app_bloc_observer.dart';
import 'tuan2_ngay1/theme_cubit.dart';
import 'tuan2_ngay1/theme_screen.dart';

// ── Tuần 2 Ngày 2 Sáng: go_router cơ bản ────────────────────────
import 'tuan2_ngay2/app_router.dart';

// ── Tuần 2 Ngày 2 Chiều: Route Guard ─────────────────────────────
import 'login/data/datasources/auth_local_datasource.dart';
import 'tuan2_ngay2_guard/app_router_guard.dart';
import 'tuan2_ngay2_guard/auth_state.dart';

// ── Tuần 2 Ngày 3 Sáng: Implicit Animation ───────────────────────
import 'tuan2_ngay3/animated_box_screen.dart';
import 'tuan2_ngay3/login_animation_screen.dart';

// ── Tuần 2 Ngày 3 Chiều: Hero Animation ──────────────────────────
import 'tuan2_ngay3/hero_task_list_screen.dart';
import 'tuan2_ngay3/hero_task_detail_screen.dart';

// ── Tuần 2 Ngày 4 Sáng: Custom Widget ────────────────────────────
import 'tuan2_ngay4/custom_widget_screen.dart';

// ── Tuần 2 Ngày 4 Chiều: Theming Light/Dark ──────────────────────
import 'tuan2_ngay4_theme/app_themes.dart';
import 'tuan2_ngay4_theme/themed_task_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = AppBlocObserver();

  final storage = await HydratedStorage.build(
    storageDirectory: Directory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );
  HydratedBloc.storage = storage;

  await Hive.initFlutter();
  Hive.registerAdapter(TaskHiveModelAdapter());
  await Hive.openBox<TaskHiveModel>(kTaskBox);

  setupLocator();

  final authLocal = AuthLocalDataSource();
  final daCoToken = await authLocal.isLoggedIn();
  authState.khoiTao(daCoToken);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ══════════════════════════════════════════════════════════
    // ĐỔI DÒNG return bên dưới để chạy từng bài
    // ══════════════════════════════════════════════════════════

    // ── Tuần 2 Ngày 4 Chiều: Theming (đang bật) ──────────────
    // BlocProvider bọc bên ngoài MaterialApp để ThemeCubit
    // có thể điều khiển theme + darkTheme + themeMode
    return BlocProvider(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDark) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            // Kết nối lightTheme/darkTheme với ThemeCubit
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            home: const ThemedTaskScreen(),
          );
        },
      ),
    );

    // ── Tuần 2 Ngày 4 Sáng: Custom Widget ────────────────────
    // return const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: CustomWidgetScreen(),
    // );

    // ── Tuần 2 Ngày 3 Chiều: Hero Animation ──────────────────
    // return const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: HeroTaskListScreen(),
    // );

    // ── Tuần 2 Ngày 3 Bài 2: AnimatedOpacity + Login ─────────
    // return const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: LoginAnimationScreen(),
    // );

    // ── Tuần 2 Ngày 3 Bài 1: AnimatedContainer ───────────────
    // return const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: AnimatedBoxScreen(),
    // );

    // ── Tuần 2 Ngày 2 Chiều: Route Guard ─────────────────────
    // return MaterialApp.router(
    //   title: 'Bai Tap Flutter',
    //   debugShowCheckedModeBanner: false,
    //   routerConfig: appRouterGuard,
    // );

    // ── Tuần 2 Ngày 2 Sáng: go_router cơ bản ─────────────────
    // return MaterialApp.router(
    //   title: 'Bai Tap Flutter',
    //   debugShowCheckedModeBanner: false,
    //   routerConfig: appRouter,
    // );

    // ── Tuần 2 Ngày 1: HydratedBloc ──────────────────────────
    // return MaterialApp(
    //   title: 'Bai Tap Flutter',
    //   debugShowCheckedModeBanner: false,
    //   theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
    //   home: const ThemeScreen(),
    // );

    // ── Bài 4+5: Auth flow hoàn chỉnh ─────────────────────────
    // return MaterialApp(home: const AuthStartup());

    // ── Bài 5 storage: Onboarding ─────────────────────────────
    // return MaterialApp(home: const AppStartup());

    // ── Bài 5 storage: Hive Task CRUD ─────────────────────────
    // return MaterialApp(home: const HiveTaskScreen());

    // ── Bài 4: Task API ───────────────────────────────────────
    // return MaterialApp(home: const TaskScreen());

    // ── Bài 3: FavoriteScreen ─────────────────────────────────
    // return MaterialApp(home: const FavoriteScreen());
  }
}
