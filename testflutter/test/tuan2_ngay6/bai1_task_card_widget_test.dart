import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testflutter/bai4_api/task_model.dart';
import 'package:testflutter/tuan2_ngay4/task_card.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 1 — Widget Test cho TaskCard
// Tuần 2 Ngày 6 (Sáng)
//
// PHÂN BIỆT với bloc_test (Ngày 6 Tuần 1):
//   bloc_test  → kiểm tra LOGIC (Cubit phát đúng state không)
//   testWidgets → kiểm tra UI THẬT (widget render đúng không)
//
// Chạy: flutter test test/tuan2_ngay6/bai1_task_card_widget_test.dart
// ══════════════════════════════════════════════════════════════════

void main() {
  // ── Helper: dựng TaskCard trong môi trường giả lập ────────────
  // Bắt buộc bọc MaterialApp vì TaskCard dùng Material widgets
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

  // Task giả — không cần Cubit, không cần server
  const taskDangLam = Task(
    id: 1,
    tieuDe: 'Học Widget Test',
    moTa: 'Viết test cho bài Tuần 2 Ngày 6',
    trangThai: 'DANG_LAM',
  );

  const taskHoanThanh = Task(
    id: 2,
    tieuDe: 'Học Bloc Test',
    moTa: '',
    trangThai: 'HOAN_THANH',
  );

  // ────────────────────────────────────────────────────────────────
  group('TaskCard — hiển thị UI đúng', () {
    testWidgets('hiển thị tiêu đề task', (WidgetTester tester) async {
      // Arrange: dựng Widget lên màn hình giả lập
      await tester.pumpWidget(buildTaskCard(task: taskDangLam));

      // Assert: tìm text 'Học Widget Test' trong cây Widget
      expect(find.text('Học Widget Test'), findsOneWidget);
    });

    testWidgets('hiển thị mô tả khi có nội dung', (tester) async {
      await tester.pumpWidget(buildTaskCard(task: taskDangLam));

      expect(find.text('Viết test cho bài Tuần 2 Ngày 6'), findsOneWidget);
    });

    testWidgets('không hiển thị mô tả khi moTa rỗng', (tester) async {
      await tester.pumpWidget(buildTaskCard(task: taskHoanThanh));

      // taskHoanThanh.moTa = '' → không có subtitle
      expect(find.text('Viết test cho bài Tuần 2 Ngày 6'), findsNothing);
    });

    testWidgets('hiển thị label "Đang làm" khi trangThai = DANG_LAM',
        (tester) async {
      await tester.pumpWidget(buildTaskCard(task: taskDangLam));

      expect(find.text('Đang làm'), findsOneWidget);
    });

    testWidgets('hiển thị label "Hoàn thành" khi trangThai = HOAN_THANH',
        (tester) async {
      await tester.pumpWidget(buildTaskCard(task: taskHoanThanh));

      expect(find.text('Hoàn thành'), findsOneWidget);
    });

    testWidgets('ẩn nút xóa khi showDeleteButton = false', (tester) async {
      await tester.pumpWidget(
          buildTaskCard(task: taskDangLam, showDeleteButton: false));

      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });
  });

  // ────────────────────────────────────────────────────────────────
  group('TaskCard — callback hoạt động đúng', () {
    testWidgets('gọi onXoa khi nhấn nút xóa', (tester) async {
      bool daXoa = false;

      // Arrange
      await tester.pumpWidget(buildTaskCard(
        task: taskDangLam,
        onXoa: () => daXoa = true,
      ));

      // Act: giả lập tap nút xóa
      await tester.tap(find.byIcon(Icons.delete_outline));

      // ✅ BẮT BUỘC gọi pump() sau tap() để Flutter xử lý sự kiện
      // Quên pump() → daXoa vẫn = false → test thất bại dù code đúng
      await tester.pump();

      // Assert
      expect(daXoa, isTrue);
    });

    testWidgets('gọi onTap khi nhấn vào ListTile', (tester) async {
      bool daTap = false;

      await tester.pumpWidget(buildTaskCard(
        task: taskDangLam,
        onTap: () => daTap = true,
      ));

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(daTap, isTrue);
    });

    testWidgets('onXoa KHÔNG được gọi khi tap ListTile', (tester) async {
      bool daXoa = false;

      await tester.pumpWidget(buildTaskCard(
        task: taskDangLam,
        onXoa: () => daXoa = true,
      ));

      // Tap vào ListTile (không phải nút xóa)
      await tester.tap(find.byType(ListTile));
      await tester.pump();

      // onXoa không được gọi khi tap ListTile
      expect(daXoa, isFalse);
    });
  });
}
