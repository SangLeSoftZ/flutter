import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

// ══════════════════════════════════════════════════════════════
// APP DATABASE — sqflite (SQLite local database)
// Tuần 2 Ngày 5: Local DB quan hệ
//
// Dùng sqflite thay vì Drift để tránh vấn đề codegen conflict
// Tư duy hoàn toàn giống Drift: bảng, khóa ngoại, JOIN
// Cú pháp SQL giống hệt MariaDB đã học
//
// So sánh với Spring Boot:
//   openDatabase()  = DataSource / EntityManagerFactory
//   AppTables       = @Table(name=...)
//   AppDatabase     = JdbcTemplate / Repository
// ══════════════════════════════════════════════════════════════

class AppTables {
  static const categories = 'categories';
  static const tasks = 'tasks';
}

class CategoryColumns {
  static const id = 'id';
  static const ten = 'ten';
}

class TaskColumns {
  static const id = 'id';
  static const tieuDe = 'tieu_de';
  static const hoanThanh = 'hoan_thanh';
  static const categoryId = 'category_id';
}

class CategoryRow {
  final int id;
  final String ten;
  const CategoryRow({required this.id, required this.ten});

  factory CategoryRow.fromMap(Map<String, dynamic> map) =>
      CategoryRow(
        id: map[CategoryColumns.id] as int,
        ten: map[CategoryColumns.ten] as String,
      );
}

class TaskRow {
  final int id;
  final String tieuDe;
  final bool hoanThanh;
  final int categoryId;

  const TaskRow({
    required this.id,
    required this.tieuDe,
    required this.hoanThanh,
    required this.categoryId,
  });

  factory TaskRow.fromMap(Map<String, dynamic> map) => TaskRow(
        id: map[TaskColumns.id] as int,
        tieuDe: map[TaskColumns.tieuDe] as String,
        hoanThanh: (map[TaskColumns.hoanThanh] as int) == 1,
        categoryId: map[TaskColumns.categoryId] as int,
      );
}

class AppDatabase {
  final Database _db;
  AppDatabase(this._db);

  // ── Category CRUD ─────────────────────────────────────────
  Future<List<CategoryRow>> getAllCategories() async {
    final rows = await _db.query(AppTables.categories);
    return rows.map(CategoryRow.fromMap).toList();
  }

  Future<int> insertCategory(String ten) {
    return _db.insert(
      AppTables.categories,
      {CategoryColumns.ten: ten},
    );
  }

  Future<void> deleteCategory(int id) async {
    await _db.delete(
      AppTables.categories,
      where: '${CategoryColumns.id} = ?',
      whereArgs: [id],
    );
  }

  // ── Task CRUD ─────────────────────────────────────────────
  Future<List<TaskRow>> getAllTasks() async {
    final rows = await _db.query(AppTables.tasks);
    return rows.map(TaskRow.fromMap).toList();
  }

  // JOIN logic — lấy task theo category (tương đương WHERE bên Spring Boot)
  Future<List<TaskRow>> getTasksByCategory(int categoryId) async {
    final rows = await _db.query(
      AppTables.tasks,
      where: '${TaskColumns.categoryId} = ?',
      whereArgs: [categoryId],
    );
    return rows.map(TaskRow.fromMap).toList();
  }

  Future<int> insertTask(String tieuDe, int categoryId) {
    return _db.insert(
      AppTables.tasks,
      {
        TaskColumns.tieuDe: tieuDe,
        TaskColumns.categoryId: categoryId,
        TaskColumns.hoanThanh: 0,
      },
    );
  }

  Future<void> updateTask(
      int id, String tieuDe, bool hoanThanh, int categoryId) async {
    await _db.update(
      AppTables.tasks,
      {
        TaskColumns.tieuDe: tieuDe,
        TaskColumns.hoanThanh: hoanThanh ? 1 : 0,
        TaskColumns.categoryId: categoryId,
      },
      where: '${TaskColumns.id} = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteTask(int id) async {
    await _db.delete(
      AppTables.tasks,
      where: '${TaskColumns.id} = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() => _db.close();
}

// ── Mở database — tương đương DataSource config bên Spring Boot ──
Future<AppDatabase> openAppDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = p.join(dbPath, 'tuan2_ngay5.db');

  final db = await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      // Tạo bảng Categories — giống @Entity Category + @Table
      await db.execute('''
        CREATE TABLE ${AppTables.categories} (
          ${CategoryColumns.id}  INTEGER PRIMARY KEY AUTOINCREMENT,
          ${CategoryColumns.ten} TEXT    NOT NULL
        )
      ''');
      // Tạo bảng Tasks với khóa ngoại — giống @ManyToOne + @JoinColumn
      await db.execute('''
        CREATE TABLE ${AppTables.tasks} (
          ${TaskColumns.id}         INTEGER PRIMARY KEY AUTOINCREMENT,
          ${TaskColumns.tieuDe}     TEXT    NOT NULL,
          ${TaskColumns.hoanThanh}  INTEGER NOT NULL DEFAULT 0,
          ${TaskColumns.categoryId} INTEGER NOT NULL,
          FOREIGN KEY (${TaskColumns.categoryId})
            REFERENCES ${AppTables.categories}(${CategoryColumns.id})
        )
      ''');
    },
  );

  return AppDatabase(db);
}
