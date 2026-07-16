import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testflutter/bai4_api/task_model.dart';
import 'package:testflutter/tuan2_ngay4/task_card.dart';

// ══════════════════════════════════════════════════════════════════
// WIDGET TEST cho TaskCard — Tuần 2 Ngày 4 (Sáng) Bài 2
//
// Tại sao "dumb widget" dễ test:
//   - Không cần setup Cubit, Provider, GetIt
//   - Chỉ cần truyền Task giả vào constructor
//   - Test độc lập hoàn toàn với business logic
// ══════════════════════════════════════════════════════════════════

void main() {
  // Task giả để dùng trong tất cả test
  const taskMau = Task(
    id: 1,
    tieuDe: 'Học Flutter Widget Test',
    moTa: 'Viết test cho TaskCard',
    trangThai: 'DANG_LAM',
  );

  const taskHoanThanh = Task(
    id: 2,
    tieuDe: 'Task đã hoàn thành',
    moTa: '',
    trangThai: 'HOAN_THANH',
  );

  // Helper: build widget trong môi trường test
  Widget buildTaskCard({
    required Task task,
    VoidCallback? onXoa,
    VoidCallback? onTap,
    bool showDeleteButton = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: TaskCard(
          task: task,
          onXoa: onXoa,
          onTap: onTap,
          showDeleteButton: showDeleteButton,
        ),
      ),
    );
  }

  group('TaskCard — hiển thị đúng nội dung', () {
    testWidgets('hiển thị tiêu đề task', (tester) async {
      await tester.pumpWidget(buildTaskCard(task: taskMau));

      expect(find.text('Học Flutter Widget Test'), findsOneWidget);
    });

    testWidgets('hiển thị mô tả task', (tester) async {
      await tester.pumpWidget(buildTaskCard(task: taskMau));

      expect(find.text('Viết test cho TaskCard'), findsOneWidget);
    });

    testWidgets('hiển thị label "Đang làm" khi trangThai = DANG_LAM',
        (tester) async {
      await tester.pumpWidget(buildTaskCard(task: taskMau));

      expect(find.text('Đang làm'), findsOneWidget);
    });

    testWidgets('hiển thị label "Hoàn thành" khi trangThai = HOAN_THANH',
        (tester) async {
      await tester.pumpWidget(buildTaskCard(task: taskHoanThanh));

      expect(find.text('Hoàn thành'), findsOneWidget);
    });

    testWidgets('không hiển thị mô tả khi moTa rỗng', (tester) async {
      await tester.pumpWidget(buildTaskCard(task: taskHoanThanh));

      expect(find.text('Viết test cho TaskCard'), findsNothing);
    });
  });

  group('TaskCard — callback hoạt động đúng', () {
    testWidgets('gọi onXoa khi nhấn nút xóa', (tester) async {
      bool daGoi = false;

      await tester.pumpWidget(buildTaskCard(
        task: taskMau,
        onXoa: () => daGoi = true,
      ));

      // Tìm và nhấn nút xóa
      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      expect(daGoi, isTrue);
    });

    testWidgets('gọi onTap khi nhấn vào card', (tester) async {
      bool daGoi = false;

      await tester.pumpWidget(buildTaskCard(
        task: taskMau,
        onTap: () => daGoi = true,
      ));

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(daGoi, isTrue);
    });

    testWidgets('không hiển thị nút xóa khi showDeleteButton = false',
        (tester) async {
      await tester.pumpWidget(buildTaskCard(
        task: taskMau,
        showDeleteButton: false,
      ));

      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });
  });
}
