// ══════════════════════════════════════════════════════════════════
// BÀI 1 — Sealed Class: TaskState an toàn kiểu tuyệt đối
// Tuần 3 Ngày 7 (Sáng)
//
// PHÂN BIỆT abstract vs sealed:
//   abstract: class con có thể ở bất kỳ file nào
//             → trình biên dịch không biết đã đủ nhánh chưa
//             → quên xử lý 1 nhánh không có lỗi biên dịch
//   sealed:   class con CHỈ được khai báo trong cùng file này
//             → trình biên dịch biết chính xác tất cả nhánh
//             → quên 1 nhánh trong switch → LỖI BIÊN DỊCH NGAY
// ══════════════════════════════════════════════════════════════════

import '../bai4_api/task_model.dart';

// ── Sealed TaskState — Bài 1 ──────────────────────────────────────
sealed class TaskSealedState {}

class TaskSealedInitial extends TaskSealedState {}

class TaskSealedLoading extends TaskSealedState {}

class TaskSealedLoaded extends TaskSealedState {
  final List<Task> danhSach;
  TaskSealedLoaded(this.danhSach);
}

class TaskSealedError extends TaskSealedState {
  final String thongDiep;
  TaskSealedError(this.thongDiep);
}

// ── BÀI 2: Thêm class con mới để test exhaustiveness ─────────────
// Bỏ comment dòng dưới → switch trong bai2_sealed_demo_screen.dart
// sẽ báo lỗi biên dịch NGAY nếu chưa xử lý TaskSealedEmpty
// class TaskSealedEmpty extends TaskSealedState {}

// ── So sánh: Abstract class CŨ (không an toàn) ───────────────────
// abstract class TaskStateOld {}
// class TaskInitialOld extends TaskStateOld {}
// class TaskLoadingOld extends TaskStateOld {}
// class TaskLoadedOld extends TaskStateOld {
//   final List<Task> danhSach;
//   TaskLoadedOld(this.danhSach);
// }
// Với abstract: có thể thêm class ở file khác
// → switch không bao giờ biết đủ nhánh → không có exhaustiveness check
