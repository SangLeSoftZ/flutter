import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_local_repository.dart';

// ══════════════════════════════════════════════════════════════
// CUBIT + STATE — Presentation Layer
// Tuần 2 Ngày 5: Drift
//
// Cubit gọi Repository (domain) — không gọi trực tiếp Drift
// Đây là nguyên tắc Clean Architecture: Presentation → Domain → Data
// ══════════════════════════════════════════════════════════════

// ── State ─────────────────────────────────────────────────────
abstract class DriftTaskState {}

class DriftTaskInitial extends DriftTaskState {}

class DriftTaskLoading extends DriftTaskState {}

class DriftTaskLoaded extends DriftTaskState {
  final List<CategoryEntity> categories;
  final List<TaskEntity> tasks;
  final CategoryEntity? selectedCategory; // null = xem tất cả

  DriftTaskLoaded({
    required this.categories,
    required this.tasks,
    this.selectedCategory,
  });

  List<TaskEntity> get filteredTasks => selectedCategory == null
      ? tasks
      : tasks.where((t) => t.categoryId == selectedCategory!.id).toList();
}

class DriftTaskError extends DriftTaskState {
  final String message;
  DriftTaskError(this.message);
}

// ── Cubit ─────────────────────────────────────────────────────
class DriftTaskCubit extends Cubit<DriftTaskState> {
  final TaskLocalRepository _repo;

  DriftTaskCubit(this._repo) : super(DriftTaskInitial());

  Future<void> taiDuLieu() async {
    emit(DriftTaskLoading());
    try {
      final categories = await _repo.layTatCaCategory();
      final tasks = await _repo.layTatCaTask();
      emit(DriftTaskLoaded(categories: categories, tasks: tasks));
    } catch (e) {
      emit(DriftTaskError('Lỗi tải dữ liệu: $e'));
    }
  }

  Future<void> themCategory(String ten) async {
    await _repo.themCategory(CategoryEntity(ten: ten));
    await taiDuLieu();
  }

  Future<void> themTask(String tieuDe, int categoryId) async {
    await _repo.themTask(TaskEntity(tieuDe: tieuDe, categoryId: categoryId));
    await taiDuLieu();
  }

  Future<void> toggleHoanThanh(TaskEntity task) async {
    await _repo.capNhatTask(task.copyWith(hoanThanh: !task.hoanThanh));
    await taiDuLieu();
  }

  Future<void> xoaTask(int id) async {
    await _repo.xoaTask(id);
    await taiDuLieu();
  }

  void chonCategory(CategoryEntity? category) {
    final current = state;
    if (current is DriftTaskLoaded) {
      emit(DriftTaskLoaded(
        categories: current.categories,
        tasks: current.tasks,
        selectedCategory: category,
      ));
    }
  }
}
