import 'package:get_it/get_it.dart';
import 'drift_database.dart';
import '../../domain/repositories/task_local_repository.dart';
import '../repositories/task_local_repository_impl.dart';

// ══════════════════════════════════════════════════════════════
// DATABASE PROVIDER — Đăng ký Drift vào GetIt
// Tuần 2 Ngày 5
//
// Gọi setupDriftLocator() trong main() sau setupLocator()
// ══════════════════════════════════════════════════════════════

final getIt = GetIt.instance;

Future<void> setupDriftLocator() async {
  final db = await openAppDatabase();
  // Singleton — dùng chung 1 database instance toàn app
  getIt.registerSingleton<AppDatabase>(db);
  getIt.registerSingleton<TaskLocalRepository>(
    TaskLocalRepositoryImpl(db),
  );
}
