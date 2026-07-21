// ══════════════════════════════════════════════════════════════
// DOMAIN ENTITY: Task
// Clean Architecture — Layer: Domain
// categoryId = khóa ngoại → tương đương @ManyToOne Spring Boot
// ══════════════════════════════════════════════════════════════
class TaskEntity {
  final int? id;
  final String tieuDe;
  final bool hoanThanh;
  final int categoryId; // khóa ngoại trỏ tới Category

  const TaskEntity({
    this.id,
    required this.tieuDe,
    this.hoanThanh = false,
    required this.categoryId,
  });

  TaskEntity copyWith({int? id, String? tieuDe, bool? hoanThanh, int? categoryId}) {
    return TaskEntity(
      id: id ?? this.id,
      tieuDe: tieuDe ?? this.tieuDe,
      hoanThanh: hoanThanh ?? this.hoanThanh,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  String toString() => 'TaskEntity(id: $id, tieuDe: $tieuDe, hoanThanh: $hoanThanh, categoryId: $categoryId)';
}
