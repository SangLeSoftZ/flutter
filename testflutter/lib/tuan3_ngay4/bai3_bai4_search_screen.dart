import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bai4_api/api_client.dart';
import 'bai3_bai4_search_bloc.dart';

// BÀI 3 + 4 — Màn hình so sánh restartable vs sequential
// Chuyển tab để thấy khác biệt khi gõ nhanh
class SearchTransformerScreen extends StatelessWidget {
  const SearchTransformerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tuần 3 Ngày 4 — Bloc Transformer'),
          backgroundColor: Colors.indigo.shade700,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Bài 3: restartable()', icon: Icon(Icons.restart_alt)),
              Tab(text: 'Bài 4: sequential()', icon: Icon(Icons.queue)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SearchTab(
              bloc: SearchBlocRestartable(ApiClient()),
              label: 'restartable()',
              color: Colors.green,
              desc: 'Event mới → HỦY Event cũ\nChỉ kết quả mới nhất được hiển thị\n→ Luôn đúng dù gõ nhanh',
            ),
            _SearchTab(
              bloc: SearchBlocSequential(ApiClient()),
              label: 'sequential()',
              color: Colors.orange,
              desc: 'Event mới → CHỜ Event cũ xong\nGõ nhanh → kết quả sai thứ tự\n→ Hiển thị kết quả cũ sau kết quả mới',
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchTab extends StatefulWidget {
  final dynamic bloc;
  final String label;
  final Color color;
  final String desc;

  const _SearchTab({required this.bloc, required this.label, required this.color, required this.desc});

  @override
  State<_SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<_SearchTab> {
  final _ctrl = TextEditingController();
  int _soLanGo = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.bloc,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: widget.color.withOpacity(0.3)),
            ),
            child: Text(widget.desc, style: TextStyle(fontSize: 12, color: widget.color)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: BlocBuilder(
              bloc: widget.bloc,
              builder: (context, state) {
                int? requestSo;
                String? tuKhoaHienTai;
                if (state is SearchLoaded) {
                  requestSo = state.requestSo;
                  tuKhoaHienTai = state.tuKhoa;
                } else if (state is SearchLoading) {
                  tuKhoaHienTai = state.tuKhoa;
                }
                return Column(
                  children: [
                    TextField(
                      controller: _ctrl,
                      onChanged: (v) {
                        setState(() => _soLanGo++);
                        widget.bloc.add(TimKiemThayDoi(v));
                      },
                      decoration: InputDecoration(
                        hintText: 'Gõ nhanh để thấy khác biệt...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _ctrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _ctrl.clear();
                                  setState(() => _soLanGo = 0);
                                  widget.bloc.add(TimKiemThayDoi(''));
                                })
                            : null,
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _chip('Ký tự gõ', '$_soLanGo', Colors.orange),
                        const SizedBox(width: 8),
                        if (requestSo != null) _chip('Request #$requestSo', tuKhoaHienTai ?? '', widget.color),
                        if (state is SearchLoading)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: widget.color),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder(
              bloc: widget.bloc,
              builder: (context, state) {
                if (state is SearchInitial) return const Center(child: Text('Gõ để tìm kiếm', style: TextStyle(color: Colors.grey)));
                if (state is SearchLoading) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(color: widget.color), const SizedBox(height: 8), Text('Đang tìm "${state.tuKhoa}"...', style: const TextStyle(color: Colors.grey))]));
                if (state is SearchError) return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                if (state is SearchLoaded) {
                  if (state.ketQua.isEmpty) return Center(child: Text('Không có "${state.tuKhoa}"', style: const TextStyle(color: Colors.grey)));
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('Kết quả cho "${state.tuKhoa}" — request #${state.requestSo}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.ketQua.length,
                          itemBuilder: (_, i) => ListTile(dense: true, leading: Icon(Icons.task_alt, color: widget.color, size: 20), title: Text(state.ketQua[i].tieuDe)),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.4))),
    child: Column(children: [Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)), Text(label, style: TextStyle(fontSize: 10, color: color))]),
  );
}
