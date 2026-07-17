import 'package:stomp_dart_client/stomp_dart_client.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 4 — StompService: chuẩn bị kết nối STOMP tới Spring Boot
// Tuần 3 Ngày 2 (Chiều)
//
// Tại sao cần STOMP thay vì WebSocket thuần?
//   WebSocket thuần: chỉ gửi/nhận byte, không có khái niệm "kênh"
//   STOMP: thêm "destination" (/topic/tasks) → subscribe đúng kênh
//   → 10 tính năng real-time dùng chung 1 kết nối mà không lẫn lộn
//
// URL WebSocket:
//   Android Emulator: ws://10.0.2.2:8080/ws (10.0.2.2 = localhost máy thật)
//   Thiết bị thật:    ws://<IP_máy>:8080/ws (VD: ws://192.168.1.5:8080/ws)
//   Web/iOS Sim:      ws://localhost:8080/ws
// ══════════════════════════════════════════════════════════════════

typedef OnTaskReceived = void Function(String jsonBody);

class StompService {
  StompClient? _stompClient;
  bool _daKetNoi = false;
  bool get daKetNoi => _daKetNoi;

  // URL Spring Boot WebSocket endpoint (cấu hình ở phần Tối)
  // Android Emulator dùng 10.0.2.2 thay cho localhost
  static const String _wsUrl = 'ws://10.0.2.2:8080/ws';

  // Callback được gọi khi nhận được task mới từ server
  OnTaskReceived? onTaskReceived;

  void ketNoi({OnTaskReceived? onTask}) {
    onTaskReceived = onTask;

    _stompClient = StompClient(
      config: StompConfig(
        url: _wsUrl,
        onConnect: _onConnect,
        onDisconnect: (frame) {
          _daKetNoi = false;
          // ignore: avoid_print
          print('[STOMP] Đã ngắt kết nối');
        },
        onWebSocketError: (error) {
          // ignore: avoid_print
          print('[STOMP] Lỗi WebSocket: $error');
        },
        onStompError: (frame) {
          // ignore: avoid_print
          print('[STOMP] Lỗi STOMP: ${frame.body}');
        },
        // Tự động reconnect sau 5 giây nếu mất kết nối
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _stompClient!.activate();
    // ignore: avoid_print
    print('[STOMP] Đang kết nối tới $_wsUrl...');
  }

  void _onConnect(StompFrame frame) {
    _daKetNoi = true;
    // ignore: avoid_print
    print('[STOMP] Đã kết nối thành công');

    // Subscribe kênh /topic/tasks
    // Server sẽ broadcast mỗi khi có Task mới được tạo
    // (cấu hình ở Spring Boot phần Tối)
    _stompClient!.subscribe(
      destination: '/topic/tasks',
      callback: (frame) {
        final body = frame.body ?? '';
        // ignore: avoid_print
        print('[STOMP] Nhận task mới: $body');
        onTaskReceived?.call(body);
      },
    );
  }

  // Gửi message lên server (VD: tạo task mới qua WebSocket)
  void guiMessage(String destination, String body) {
    if (!_daKetNoi) return;
    _stompClient!.send(destination: destination, body: body);
  }

  void ngatKetNoi() {
    _stompClient?.deactivate();
    _daKetNoi = false;
  }
}
