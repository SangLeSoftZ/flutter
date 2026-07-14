import 'package:go_router/go_router.dart';
import '../../bai4_api/task_model.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'task_detail_screen.dart';

// Toàn bộ bản đồ điều hướng — 1 chỗ duy nhất
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/tasks/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        // Nhận Task object từ extra nếu có (truyền từ HomeScreen)
        final task = state.extra as Task?;
        return TaskDetailScreen(taskId: id, task: task);
      },
    ),
  ],
);
