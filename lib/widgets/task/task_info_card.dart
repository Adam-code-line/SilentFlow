import 'package:flutter/material.dart';
import '../../models/task_model.dart';

class TaskInfoCard extends StatelessWidget {
  final Task task;
  final Function(String) onMenuAction;

  const TaskInfoCard({
    super.key,
    required this.task,
    required this.onMenuAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: onMenuAction,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('编辑任务'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'status',
                      child: Row(
                        children: [
                          Icon(Icons.swap_horiz, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('更改状态'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('删除任务'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (task.description?.isNotEmpty == true) ...[
              Text(
                task.description!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
            ],
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildInfoItem(
                  _getStatusIcon(task.status),
                  '状态',
                  _getStatusText(task.status),
                  _getStatusColor(task.status),
                ),
                _buildInfoItem(
                  Icons.flag,
                  '优先级',
                  _getPriorityText(task.priority),
                  _getPriorityColor(task.priority),
                ),
                _buildInfoItem(
                  Icons.category,
                  '类型',
                  _getTaskLevelText(task.level),
                  Colors.blue,
                ),
                if (task.assigneeId != null)
                  _buildInfoItem(
                    Icons.person,
                    '负责人',
                    task.assigneeId!,
                    Colors.purple,
                  ),
              ],
            ),
            if (task.dueDate != null) ...[
              const SizedBox(height: 12),
              _buildInfoItem(
                Icons.schedule,
                '截止时间',
                _formatDate(task.dueDate!),
                task.dueDate!.isBefore(DateTime.now())
                    ? Colors.red
                    : Colors.green,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return '待处理';
      case TaskStatus.inProgress:
        return '进行中';
      case TaskStatus.completed:
        return '已完成';
      case TaskStatus.blocked:
        return '阻塞';
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.schedule;
      case TaskStatus.inProgress:
        return Icons.play_circle;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.blocked:
        return Icons.block;
    }
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

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return '低';
      case TaskPriority.medium:
        return '中';
      case TaskPriority.high:
        return '高';
      case TaskPriority.urgent:
        return '紧急';
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.purple;
    }
  }

  String _getTaskLevelText(TaskLevel level) {
    switch (level) {
      case TaskLevel.project:
        return '项目';
      case TaskLevel.task:
        return '任务';
      case TaskLevel.taskPoint:
        return '任务点';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
