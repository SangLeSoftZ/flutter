import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 3 — Demo khi nào PHẢI gọi pump()
// Tuần 2 Ngày 6 (Sáng)
//
// Lưu ý thực tế (Flutter 3.x):
//   tap() callback được xử lý ngay — không cần pump() cho callback
//   NHƯNG pump() vẫn BẮT BUỘC khi cần UI REBUILD (setState)
//
// Quy tắc đúng:
//   pump()          → cần khi setState() thay đổi UI
//   pumpAndSettle() → cần khi có animation/async đang chạy
//
// Chạy: flutter test test/tuan2_ngay6/bai3_pump_demo_test.dart
// ══════════════════════════════════════════════════════════════════

// Widget demo: bấm nút → setState → đổi text
class _CounterWidget extends StatefulWidget {
  const _CounterWidget();

  @override
  State<_CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<_CounterWidget> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Count: $_count', key: const Key('counter_text')),
        ElevatedButton(
          key: const Key('increment_button'),
          onPressed: () => setState(() => _count++),
          child: const Text('Tăng'),
        ),
      ],
    );
  }
}

void main() {
  Widget buildCounter() => const MaterialApp(
        home: Scaffold(body: Center(child: _CounterWidget())),
      );

  // ── Test ĐÚNG — có pump() sau setState ────────────────────────
  testWidgets('✅ CÓ pump() — UI hiển thị đúng sau setState',
      (tester) async {
    await tester.pumpWidget(buildCounter());

    // Trước khi tap
    expect(find.text('Count: 0'), findsOneWidget);

    await tester.tap(find.byKey(const Key('increment_button')));

    // ✅ BẮT BUỘC pump() để Flutter rebuild UI sau setState
    // Không có pump() → UI vẫn hiển thị "Count: 0"
    await tester.pump();

    expect(find.text('Count: 1'), findsOneWidget); // ✅ PASS
    expect(find.text('Count: 0'), findsNothing);
  });

  // ── Test THIẾU pump() — UI KHÔNG được rebuild ─────────────────
  testWidgets('❌ THIẾU pump() — UI KHÔNG đổi dù đã tap',
      (tester) async {
    await tester.pumpWidget(buildCounter());

    await tester.tap(find.byKey(const Key('increment_button')));

    // KHÔNG gọi pump() → Flutter chưa rebuild UI
    // UI vẫn hiển thị "Count: 0" dù _count đã = 1 trong state
    expect(find.text('Count: 0'), findsOneWidget); // ← vẫn thấy "Count: 0"
    expect(find.text('Count: 1'), findsNothing);  // ← chưa thấy "Count: 1"
    // Đây là lý do PHẢI gọi pump() sau tap() khi UI cần rebuild
  });

  // ── Demo pumpAndSettle() cho animation ────────────────────────
  testWidgets('pumpAndSettle() chờ animation xong rồi mới assert',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          builder: (_, value, __) => Opacity(
            opacity: value,
            child: const Text('Animated Text'),
          ),
        ),
      ),
    ));

    // pumpAndSettle() chạy đến khi không còn frame nào pending
    await tester.pumpAndSettle();

    expect(find.text('Animated Text'), findsOneWidget); // ✅ PASS
  });

  // ── Tóm tắt quy tắc ──────────────────────────────────────────
  testWidgets('Tóm tắt: pump() cần thiết sau setState', (tester) async {
    await tester.pumpWidget(buildCounter());

    // Tap 3 lần
    await tester.tap(find.byKey(const Key('increment_button')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('increment_button')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('increment_button')));
    await tester.pump();

    expect(find.text('Count: 3'), findsOneWidget);
  });
}
