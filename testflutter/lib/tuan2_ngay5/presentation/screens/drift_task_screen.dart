import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../cubit/drift_task_cubit.dart';

// ══════════════════════════════════════════════════════════════
// SCREEN — Presentation Layer
// Tuần 2 Ngày 5: Demo Drift + Clean Architecture
//
// Luồng: UI → Cubit → Repository (abstract) → Drift (impl)
// ══════════════════════════════════════════════════════════════

class DriftTaskScreen extends StatefulWidget {
  const DriftTaskScreen({super.key});

  @override
  State<DriftTaskScreen> createState() => _DriftTaskScreenState();
}

class _DriftTaskScreenState extends State<DriftTaskScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DriftTaskCubit>().taiDuLieu();
  }

  void _showThemCategory(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Thêm Category'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Tên category...'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          FilledButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                context.read<DriftTaskCubit>().themCategory(ctrl.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  void _showThemTask(BuildContext context, List<CategoryEntity> categories) {
    final ctrl = TextEditingController();
    CategoryEntity? selected = categories.isNotEmpty ? categories.first : null;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Thêm Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(hintText: 'Tiêu đề task...'),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              DropdownButton<CategoryEntity>(
                value: selected,
                isExpanded: true,
                hint: const Text('Chọn Category'),
                items: categories.map((c) => DropdownMenuItem(
                  value: c, child: Text(c.ten))).toList(),
                onChanged: (c) => setS(() => selected = c),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            FilledButton(
              onPressed: () {
                if (ctrl.text.trim().isNotEmpty && selected != null) {
                  context.read<DriftTaskCubit>().themTask(ctrl.text.trim(), selected!.id!);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tuần 2 Ngày 5 — Drift + Clean Architecture'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<DriftTaskCubit, DriftTaskState>(
        builder: (context, state) {
          if (state is DriftTaskLoading || state is DriftTaskInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DriftTaskError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          }
          if (state is! DriftTaskLoaded) return const SizedBox();

          return Column(
            children: [
              // Chú thích
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.deepPurple.shade200),
                ),
                child: const Text(
                  '📌 Clean Architecture:\n'
                  'Screen → Cubit → Repository (abstract) → Drift (impl)\n'
                  'Chọn category để lọc task (JOIN logic)',
                  style: TextStyle(fontSize: 12),
                ),
              ),

              // Filter by Category
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _CategoryChip(label: 'Tất cả', selected: state.selectedCategory == null,
                        onTap: () => context.read<DriftTaskCubit>().chonCategory(null)),
                    ...state.categories.map((c) => _CategoryChip(
                      label: c.ten,
                      selected: state.selectedCategory?.id == c.id,
                      onTap: () => context.read<DriftTaskCubit>().chonCategory(c),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Task list
              Expanded(
                child: state.filteredTasks.isEmpty
                    ? Center(
                        child: Text(
                          state.tasks.isEmpty ? 'Chưa có task nào\nNhấn + để thêm' : 'Category này chưa có task',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ))
                    : ListView.builder(
                        itemCount: state.filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = state.filteredTasks[index];
                          final cat = state.categories.firstWhere(
                            (c) => c.id == task.categoryId,
                            orElse: () => const CategoryEntity(ten: '?'),
                          );
                          return ListTile(
                            leading: Checkbox(
                              value: task.hoanThanh,
                              onChanged: (_) => context.read<DriftTaskCubit>().toggleHoanThanh(task),
                            ),
                            title: Text(task.tieuDe,
                                style: TextStyle(
                                  decoration: task.hoanThanh ? TextDecoration.lineThrough : null,
                                )),
                            subtitle: Text('Category: ${cat.ten}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => context.read<DriftTaskCubit>().xoaTask(task.id!),
                            ),
                          );
                        },
                      ),
              ),

              // Thêm Category button
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Thêm Category'),
                        onPressed: () => _showThemCategory(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(backgroundColor: Colors.deepPurple),
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm Task'),
                        onPressed: state.categories.isEmpty
                            ? null
                            : () => _showThemTask(context, state.categories),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: Colors.deepPurple.shade100,
      ),
    );
  }
}
