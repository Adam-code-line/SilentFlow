import 'package:flutter/material.dart';
import '../../models/task_model.dart';

class TaskCardWidget extends StatelessWidget {
  final Task task;
  final Function(Task) onTap;
  final Function(Task, String) onMenuAction;
  final bool showAssignButton;

  const TaskCardWidget({
    super.key,
    required this.task,
    required this.onTap,
    required this.onMenuAction,
    this.showAssignButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => onTap(task),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                _getStatusColor(task.status).withOpacity(0.02),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题行
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => onMenuAction(task, value),
                      itemBuilder: (context) => [
                        if (showAssignButton && task.assigneeId == null)
                          const PopupMenuItem(
                            value: 'assign',
                            child: Row(
                              children: [
                                Icon(Icons.person_add,
                                    size: 18, color: Colors.green),
                                SizedBox(width: 8),
                                Text('认领'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('编辑'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'status',
                          child: Row(
                            children: [
                              Icon(Icons.swap_horiz,
                                  size: 18, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('更改状态'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('删除'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // 描述
                if (task.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    task.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                // 状态、优先级和分配信息
                Row(
                  children: [
                    _buildStatusChip(task.status),
                    const SizedBox(width: 8),
                    _buildPriorityChip(task.priority),
                    const Spacer(),
                    if (task.assigneeId != null)
                      _buildAssigneeChip(task.assigneeId!),
                  ],
                ),

                // 底部信息行
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (task.estimatedMinutes > 0) ...[
                      Icon(
                        Icons.timer,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${task.estimatedMinutes}分钟',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (task.dueDate != null) ...[
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: task.dueDate!.isBefore(DateTime.now())
                            ? Colors.red
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(task.dueDate!),
                        style: TextStyle(
                          fontSize: 12,
                          color: task.dueDate!.isBefore(DateTime.now())
                              ? Colors.red
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(TaskStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.3),
        ),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getPriorityColor(priority).withOpacity(0.3),
        ),
      ),
      child: Text(
        _getPriorityText(priority),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _getPriorityColor(priority),
        ),
      ),
    );
  }

  Widget _buildAssigneeChip(String assigneeId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person, size: 12, color: Colors.blue),
          const SizedBox(width: 2),
          Text(
            assigneeId,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
        ],
      ),
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
        return '受阻';
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

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
