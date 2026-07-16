import '../../domain/entities/category_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_local_repository.dart';
import '../local/drift_database.dart';

// ══════════════════════════════════════════════════════════════
// REPOSITORY IMPLEMENTATION — Data Layer
// Dùng AppDatabase (raw SQL) thay vì Drift generated code
// ══════════════════════════════════════════════════════════════

class TaskLocalRepositoryImpl implements TaskLocalRepository {
  final AppDatabase _db;
  TaskLocalRepositoryImpl(this._db);

  // ── Mapping: Row → Domain Entity ─────────────────────────
  CategoryEntity _toCategoryEntity(CategoryRow row) =>
      CategoryEntity(id: row.id, ten: row.ten);

  TaskEntity _toTaskEntity(TaskRow row) => TaskEntity(
        id: row.id,
        tieuDe: row.tieuDe,
        hoanThanh: row.hoanThanh,
        categoryId: row.categoryId,
      );

  // ── Category CRUD ─────────────────────────────────────────
  @override
  Future<List<CategoryEntity>> layTatCaCategory() async {
    final rows = await _db.getAllCategories();
    return rows.map(_toCategoryEntity).toList();
  }

  @override
  Future<int> themCategory(CategoryEntity entity) {
    return _db.insertCategory(entity.ten);
  }

  @override
  Future<void> xoaCategory(int id) {
    return _db.deleteCategory(id);
  }

  // ── Task CRUD ─────────────────────────────────────────────
  @override
  Future<List<TaskEntity>> layTatCaTask() async {
    final rows = await _db.getAllTasks();
    return rows.map(_toTaskEntity).toList();
  }

  @override
  Future<List<TaskEntity>> layTaskTheoCategory(int categoryId) async {
    final rows = await _db.getTasksByCategory(categoryId);
    return rows.map(_toTaskEntity).toList();
  }

  @override
  Future<int> themTask(TaskEntity entity) {
    return _db.insertTask(entity.tieuDe, entity.categoryId);
  }

  @override
  Future<void> capNhatTask(TaskEntity entity) {
    return _db.updateTask(
      entity.id!,
      entity.tieuDe,
      entity.hoanThanh,
      entity.categoryId,
    );
  }

  @override
  Future<void> xoaTask(int id) {
    return _db.deleteTask(id);
  }
}
