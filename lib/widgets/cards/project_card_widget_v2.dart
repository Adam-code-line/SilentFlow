import 'package:flutter/material.dart';
import '../../models/task_model.dart';

class ProjectCardWidget extends StatelessWidget {
  final Task project;
  final Function(Task) onTap;
  final Function(Task) onMenuAction;

  const ProjectCardWidget({
    super.key,
    required this.project,
    required this.onTap,
    required this.onMenuAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => onTap(project),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getStatusColor(project.status).withOpacity(0.1),
                _getStatusColor(project.status).withOpacity(0.05),
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
                        project.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => onMenuAction(project),
                      itemBuilder: (context) => [
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
                if (project.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(
                    project.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: 12),

                // 状态和优先级
                Row(
                  children: [
                    _buildStatusChip(project.status),
                    const SizedBox(width: 8),
                    _buildPriorityChip(project.priority),
                    const Spacer(),
                    if (project.dueDate != null)
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: project.dueDate!.isBefore(DateTime.now())
                            ? Colors.red
                            : Colors.grey,
                      ),
                  ],
                ),

                // 进度指示器
                if (project.estimatedMinutes > 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '预估 ${project.estimatedMinutes} 分钟',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
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
}
