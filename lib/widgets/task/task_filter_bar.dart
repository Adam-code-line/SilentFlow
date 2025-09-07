import 'package:flutter/material.dart';
import '../../models/task_model.dart';

/// 任务搜索和筛选栏组件
class TaskFilterBar extends StatelessWidget {
  final String searchQuery;
  final TaskStatus? filterStatus;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<TaskStatus?> onStatusFilterChanged;
  final VoidCallback onWorkflowPressed;

  const TaskFilterBar({
    super.key,
    required this.searchQuery,
    required this.filterStatus,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.onWorkflowPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        children: [
          // 搜索框
          TextField(
            decoration: InputDecoration(
              hintText: '搜索任务...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor:
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 12),

          // 状态筛选和快速工具
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        '全部',
                        filterStatus == null,
                        () => onStatusFilterChanged(null),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        '待处理',
                        filterStatus == TaskStatus.pending,
                        () => onStatusFilterChanged(
                            filterStatus == TaskStatus.pending
                                ? null
                                : TaskStatus.pending),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        '进行中',
                        filterStatus == TaskStatus.inProgress,
                        () => onStatusFilterChanged(
                            filterStatus == TaskStatus.inProgress
                                ? null
                                : TaskStatus.inProgress),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        '已完成',
                        filterStatus == TaskStatus.completed,
                        () => onStatusFilterChanged(
                            filterStatus == TaskStatus.completed
                                ? null
                                : TaskStatus.completed),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        '被阻塞',
                        filterStatus == TaskStatus.blocked,
                        () => onStatusFilterChanged(
                            filterStatus == TaskStatus.blocked
                                ? null
                                : TaskStatus.blocked),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 工作流图快速访问按钮
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: onWorkflowPressed,
                  icon: const Icon(Icons.account_tree),
                  color: const Color(0xFF667eea),
                  tooltip: '查看工作流图',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onPressed) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onPressed(),
    );
  }
}
