import 'package:go_router/go_router.dart';
import 'auth_state.dart';
import 'login_screen_guard.dart';
import 'home_screen_guard.dart';
import '../tuan2_ngay2/task_detail_screen.dart';
import '../bai4_api/task_model.dart';

// ══════════════════════════════════════════════════════════════════
// APP ROUTER GUARD — Tuần 2 Ngày 2 (Chiều): Route Guard
//
// PHÂN BIỆT với tuan2_ngay2/app_router.dart (buổi sáng):
//   Buổi sáng: không có redirect — ai cũng vào được /home
//   Buổi chiều: có redirect — chưa đăng nhập bị đá về /login
//
// Cơ chế:
//   refreshListenable: authState → mỗi khi authState.c x`apNhat()
//     được gọi, go_router tự chạy lại hàm redirect() bên dưới
// ══════════════════════════════════════════════════════════════════

final GoRouter appRouterGuard = GoRouter(
  initialLocation: '/home', // thử vào /home thẳng → bị redirect về /login

  // Lắng nghe AuthState — khi login/logout → router tự redirect
  refreshListenable: authState,

  redirect: (context, state) {
    final daDangNhap = authState.daDangNhap;
    final dangOManLogin = state.matchedLocation == '/login';

    // Chưa đăng nhập + đang cố vào màn khác → đá về /login
    if (!daDangNhap && !dangOManLogin) return '/login';

    // Đã đăng nhập + đang ở /login → tự động vào /home
    if (daDangNhap && dangOManLogin) return '/home';

    // Cho đi tiếp bình thường
    return null;
  },

  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreenGuard(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreenGuard(),
    ),
    GoRoute(
      path: '/tasks/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final task = state.extra as Task?;
        return TaskDetailScreen(taskId: id, task: task);
      },
    ),
  ],
);
