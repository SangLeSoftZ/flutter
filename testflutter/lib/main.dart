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
import 'tuan2_ngay1/theme_screen.dart';

// ── Tuần 2 Ngày 2: go_router ─────────────────────────────────────
import 'tuan2_ngay2/app_router.dart';

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ══════════════════════════════════════════════════════════
    // ĐỔI DÒNG return bên dưới để chạy từng bài
    // ══════════════════════════════════════════════════════════

    // ── Tuần 2 Ngày 2: go_router (đang bật) ──────────────────
    return MaterialApp.router(
      title: 'Bai Tap Flutter',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );

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
