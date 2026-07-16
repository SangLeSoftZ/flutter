// ══════════════════════════════════════════════════════════════
// DOMAIN ENTITY: Category
// Clean Architecture — Layer: Domain
// Không phụ thuộc vào Drift hay bất kỳ framework nào
// Tương đương @Entity bên Spring Boot nhưng là pure Dart class
// ══════════════════════════════════════════════════════════════
class CategoryEntity {
  final int? id;
  final String ten;

  const CategoryEntity({this.id, required this.ten});

  CategoryEntity copyWith({int? id, String? ten}) {
    return CategoryEntity(id: id ?? this.id, ten: ten ?? this.ten);
  }

  @override
  String toString() => 'CategoryEntity(id: $id, ten: $ten)';
}
