import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════
// CUSTOM WIDGET: TaskSearchBar — Tuần 2 Ngày 4 (Sáng)
//
// "Dumb widget" cho thanh tìm kiếm:
//   - Nhận onSearch callback qua constructor
//   - KHÔNG tự lọc danh sách — chỉ "báo" ra ngoài từ khóa
//   - Màn hình cha quyết định logic lọc
//
// Tái sử dụng được ở bất kỳ màn hình nào cần search bar
// ══════════════════════════════════════════════════════════════════

class TaskSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearch; // callback khi text thay đổi
  final String hintText;
  final VoidCallback? onClear;

  const TaskSearchBar({
    super.key,
    required this.onSearch,
    this.hintText = 'Tìm kiếm task...',
    this.onClear,
  });

  @override
  State<TaskSearchBar> createState() => _TaskSearchBarState();
}

class _TaskSearchBarState extends State<TaskSearchBar> {
  final _controller = TextEditingController();
  bool _coNoidung = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _coNoidung = _controller.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onSearch('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        controller: _controller,
        onChanged: widget.onSearch, // chỉ báo ra ngoài, không tự xử lý
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _coNoidung
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clear,
                )
              : null,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
