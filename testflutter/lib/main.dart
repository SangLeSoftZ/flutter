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

// ── Tuần 2 Ngày 5: Drift + Clean Architecture ────────────────────
import 'tuan2_ngay5/data/local/database_provider.dart' as drift_provider;
import 'tuan2_ngay5/domain/repositories/task_local_repository.dart';
import 'tuan2_ngay5/presentation/cubit/drift_task_cubit.dart';
import 'tuan2_ngay5/presentation/screens/drift_task_screen.dart';

// ── Tuần 3 Ngày 1: Isolates + compute() ──────────────────────────
import 'tuan3_ngay1/bai1_isolate_demo_screen.dart';
import 'tuan3_ngay1/bai2_isolate_parse_screen.dart';

// ── Tuần 3 Ngày 1 Chiều: CustomPainter ───────────────────────────
import 'tuan3_ngay1/bai3_custom_painter_screen.dart';
import 'tuan3_ngay1/bai4_should_repaint_demo_screen.dart';

// ── Tuần 3 Ngày 2 Sáng: Stream Debounce ──────────────────────────
import 'tuan3_ngay2/bai1_debounce_search_screen.dart';

// ── Tuần 3 Ngày 2 Chiều: WebSocket + STOMP ───────────────────────
import 'tuan3_ngay2/bai3_websocket_echo_screen.dart';
import 'tuan3_ngay2/bai4_stomp_demo_screen.dart';

// ── Tuần 3 Ngày 3 Sáng: Generics + Mixin + Extension ────────────
import 'tuan3_ngay3/bai1_generics.dart';
import 'tuan3_ngay3/bai2_mixin.dart';
import 'tuan3_ngay3/bai3_extension.dart';

// ── Tuần 3 Ngày 3 Chiều: Riverpod ────────────────────────────────
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tuan3_ngay3/bai4_state_provider_screen.dart';
import 'tuan3_ngay3/bai5_notifier_screen.dart';

// ── Tuần 3 Ngày 4 Sáng: Platform Channel ─────────────────────────
import 'tuan3_ngay4/bai1_platform_channel_screen.dart';

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
  // Drift KHÔNG khởi tạo ở đây — tránh deadlock trước runApp
  // Sẽ được khởi tạo qua FutureBuilder trong build()

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

    // ── Tuần 3 Ngày 1 Chiều Bài 3: CustomPainter (đang bật) ──
    // return const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: CustomPainterScreen(),
    // );

    // ── Tuần 3 Ngày 2 Chiều Bài 3: WebSocket Echo (đang bật) ─
    // return const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: WebSocketEchoScreen(),
    // );

    // ── Tuần 3 Ngày 3 Bài 1: Generics (đang bật) ─────────────
    // return const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: GenericsScreen(),
    // );

    // // ── Tuần 3 Ngày 3 Bài 2: Mixin ───────────────────────────
    //    return const MaterialApp(
    //     debugShowCheckedModeBanner: false,
    //     home: MixinScreen(),
    //  );

    // ── Tuần 3 Ngày 3 Chiều Bài 4: Riverpod StateProvider ────
    // ProviderScope bọc app 1 lần — tương đương BlocProvider ở gốc
    // return const ProviderScope(
    //   child: MaterialApp(
    //     debugShowCheckedModeBanner: false,
    //     home: Bai4StateProviderScreen(),
    //   ),
    // );

    // ── Tuần 3 Ngày 4 Sáng: Platform Channel (đang bật) ──────
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PlatformChannelScreen(),
    );

    // ── Tuần 3 Ngày 3 Chiều Bài 4: Riverpod StateProvider ────
    // return const ProviderScope(
    //   child: MaterialApp(
    //     debugShowCheckedModeBanner: false,
    //     home: Bai4StateProviderScreen(),
    //   ),
    // );

    // ── Tuần 3 Ngày 3 Chiều Bài 5: Riverpod Notifier ─────────
    // return const ProviderScope(
    //   child: MaterialApp(
    //     debugShowCheckedModeBanner: false,
    //     home: Bai5NotifierScreen(),
    //   ),
    // );

    // ── Tuần 3 Ngày 3 Bài 3: Extension ───────────────────────
    // return const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: ExtensionScreen(),
    // );

    // ── Tuần 3 Ngày 2 Chiều Bài 4: STOMP Demo ────────────────
    // return const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: StompDemoScreen(),
    // );

    // ── Tuần 3 Ngày 2 Sáng: Stream Debounce ──────────────────
    // return const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: DebounceSearchScreen(),
    // );

    // ── Tuần 3 Ngày 1 Chiều Bài 4: shouldRepaint demo ────────
    // return const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: ShouldRepaintDemoScreen(),
    // );

    // ── Tuần 3 Ngày 1 Bài 1: Isolate demo — UI đơ vs mượt ────
    // return const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: IsolateDemoScreen(),
    // );

    // ── Tuần 3 Ngày 1 Bài 2: Isolate parse JSON lớn ──────────
    // return const MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: IsolateParseScreen(),
    // );

    // ── Tuần 2 Ngày 5: Drift + Clean Architecture ─────────────
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: FutureBuilder(
    //     future: drift_provider.setupDriftLocator(),
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState != ConnectionState.done) {
    //         return const Scaffold(body: Center(child: CircularProgressIndicator()));
    //       }
    //       return BlocProvider(
    //         create: (_) => DriftTaskCubit(drift_provider.getIt<TaskLocalRepository>()),
    //         child: const DriftTaskScreen(),
    //       );
    //     },
    //   ),
    // );

    // ── Tuần 2 Ngày 4 Chiều: Theming ─────────────────────────
    // return BlocProvider(
    //   create: (_) => ThemeCubit(),
    //   child: BlocBuilder<ThemeCubit, bool>(
    //     builder: (context, isDark) {
    //       return MaterialApp(
    //         debugShowCheckedModeBanner: false,
    //         theme: lightTheme,
    //         darkTheme: darkTheme,
    //         themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    //         home: const ThemedTaskScreen(),
    //       );
    //     },
    //   ),
    // );

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
