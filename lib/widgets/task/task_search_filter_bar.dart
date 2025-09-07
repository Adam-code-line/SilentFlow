import 'package:flutter/material.dart';
import '../../models/task_model.dart';

class TaskSearchAndFilterBar extends StatelessWidget {
  final String searchQuery;
  final TaskStatus? filterStatus;
  final Function(String) onSearchChanged;
  final Function(TaskStatus?) onFilterChanged;

  const TaskSearchAndFilterBar({
    super.key,
    required this.searchQuery,
    required this.filterStatus,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 搜索框
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: '搜索任务...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => onSearchChanged(''),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 状态筛选器
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('全部', null),
                const SizedBox(width: 8),
                _buildFilterChip('待处理', TaskStatus.pending),
                const SizedBox(width: 8),
                _buildFilterChip('进行中', TaskStatus.inProgress),
                const SizedBox(width: 8),
                _buildFilterChip('已完成', TaskStatus.completed),
                const SizedBox(width: 8),
                _buildFilterChip('受阻', TaskStatus.blocked),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TaskStatus? status) {
    final isSelected = filterStatus == status;
    final color = status != null ? _getStatusColor(status) : Colors.blue;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) => onFilterChanged(selected ? status : null),
      backgroundColor: Colors.grey[100],
      selectedColor: color,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? color : color.withOpacity(0.3),
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return const Color(0xFFED8936);
      case TaskStatus.inProgress:
        return const Color(0xFF4299E1);
      case TaskStatus.completed:
        return const Color(0xFF48BB78);
      case TaskStatus.blocked:
        return const Color(0xFFE53E3E);
    }
  }
}
