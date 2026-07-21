import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// ══════════════════════════════════════════════════════════════════
// BÀI 3 — WebSocket Echo: gửi message, nhận lại đúng message đó
// Tuần 3 Ngày 2 (Chiều)
//
// PHÂN BIỆT HTTP vs WebSocket:
//   HTTP     : client hỏi → server trả lời → đóng kết nối
//   WebSocket: bắt tay 1 lần → kết nối GIỮ NGUYÊN 2 chiều mãi
//
// 2 phần của WebSocketChannel:
//   channel.stream → "tai nghe" — nhận message từ server
//   channel.sink   → "miệng nói" — gửi message lên server
//   Hay nhầm stream/sink — nhớ: stream=nghe, sink=nói
// ══════════════════════════════════════════════════════════════════

class WebSocketEchoScreen extends StatefulWidget {
  const WebSocketEchoScreen({super.key});

  @override
  State<WebSocketEchoScreen> createState() => _WebSocketEchoScreenState();
}

class _WebSocketEchoScreenState extends State<WebSocketEchoScreen> {
  WebSocketChannel? _channel;
  final _msgCtrl = TextEditingController();
  final List<_Message> _messages = [];
  bool _dangKetNoi = false;
  bool _daKetNoi = false;
  String _trangThai = 'Chưa kết nối';

  // Echo server công khai — không cần tự dựng server
  static const String _echoUrl = 'wss://echo.websocket.org';

  @override
  void dispose() {
    _channel?.sink.close(); // BẮT BUỘC đóng kết nối khi rời màn hình
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _ketNoi() async {
    setState(() {
      _dangKetNoi = true;
      _trangThai = 'Đang kết nối...';
    });

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_echoUrl));

      // Lắng nghe message từ server qua stream
      _channel!.stream.listen(
        (message) {
          setState(() {
            _messages.add(_Message(noidung: message.toString(), tuServer: true));
          });
        },
        onError: (error) {
          setState(() {
            _trangThai = 'Lỗi: $error';
            _daKetNoi = false;
          });
        },
        onDone: () {
          setState(() {
            _trangThai = 'Kết nối đã đóng';
            _daKetNoi = false;
          });
        },
      );

      setState(() {
        _dangKetNoi = false;
        _daKetNoi = true;
        _trangThai = 'Đã kết nối tới $_echoUrl';
      });
    } catch (e) {
      setState(() {
        _dangKetNoi = false;
        _trangThai = 'Lỗi kết nối: $e';
      });
    }
  }

  void _guiMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || !_daKetNoi) return;

    // Gửi message lên server qua sink
    _channel!.sink.add(text);
    setState(() {
      _messages.add(_Message(noidung: text, tuServer: false));
    });
    _msgCtrl.clear();
  }

  void _dongKetNoi() {
    _channel?.sink.close();
    setState(() {
      _daKetNoi = false;
      _trangThai = 'Đã ngắt kết nối';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 3 Ngày 2 — WebSocket Echo Bài 3'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Chú thích
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.indigo.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📌 WebSocket Echo — stream vs sink',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  'channel.stream → "tai nghe" — nhận từ server\n'
                  'channel.sink   → "miệng nói" — gửi lên server\n'
                  'Echo server tự động gửi lại đúng message bạn gửi',
                  style: TextStyle(fontSize: 12, color: Colors.indigo),
                ),
              ],
            ),
          ),

          // Trạng thái kết nối
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _daKetNoi ? Colors.green.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: _daKetNoi ? Colors.green.shade300 : Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  _daKetNoi ? Icons.wifi : Icons.wifi_off,
                  color: _daKetNoi ? Colors.green : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_trangThai,
                      style: TextStyle(
                          fontSize: 12,
                          color: _daKetNoi ? Colors.green.shade700 : Colors.grey)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Nút kết nối / ngắt kết nối
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                        backgroundColor:
                            _daKetNoi ? Colors.red : Colors.indigo),
                    onPressed: _dangKetNoi
                        ? null
                        : (_daKetNoi ? _dongKetNoi : _ketNoi),
                    icon: _dangKetNoi
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Icon(_daKetNoi ? Icons.close : Icons.wifi),
                    label: Text(_dangKetNoi
                        ? 'Đang kết nối...'
                        : (_daKetNoi ? 'Ngắt kết nối' : 'Kết nối')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // Danh sách message
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'Kết nối rồi gửi message\n'
                      'Server echo sẽ gửi lại đúng message đó',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return Align(
                        alignment: msg.tuServer
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: msg.tuServer
                                ? Colors.indigo.shade100
                                : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: msg.tuServer
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.end,
                            children: [
                              Text(
                                msg.tuServer ? '← Server (stream)' : '→ Gửi (sink)',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: msg.tuServer
                                        ? Colors.indigo
                                        : Colors.green.shade700),
                              ),
                              Text(msg.noidung),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Ô nhập message
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    enabled: _daKetNoi,
                    decoration: InputDecoration(
                      hintText: _daKetNoi
                          ? 'Nhập message để gửi...'
                          : 'Kết nối trước để gửi',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _guiMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                      backgroundColor: Colors.indigo),
                  onPressed: _daKetNoi ? _guiMessage : null,
                  icon: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String noidung;
  final bool tuServer; // true = từ server, false = từ mình gửi
  _Message({required this.noidung, required this.tuServer});
}
