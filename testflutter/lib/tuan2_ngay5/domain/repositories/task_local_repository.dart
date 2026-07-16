// ══════════════════════════════════════════════════════════════
// REPOSITORY INTERFACE — Domain Layer
// Clean Architecture: Domain chỉ khai báo interface (abstract)
// Data layer sẽ implement bằng Drift
// Tương đương interface Repository bên Spring Boot
// ══════════════════════════════════════════════════════════════
import '../entities/category_entity.dart';
import '../entities/task_entity.dart';

abstract class TaskLocalRepository {
  // ── Category CRUD ──────────────────────────────────────────
  Future<List<CategoryEntity>> layTatCaCategory();
  Future<int> themCategory(CategoryEntity category);
  Future<void> xoaCategory(int id);

  // ── Task CRUD ──────────────────────────────────────────────
  Future<List<TaskEntity>> layTatCaTask();
  Future<List<TaskEntity>> layTaskTheoCategory(int categoryId);
  Future<int> themTask(TaskEntity task);
  Future<void> capNhatTask(TaskEntity task);
  Future<void> xoaTask(int id);
}
