import 'package:flutter/material.dart';
import '../../models/task_model.dart';

class ChildTasksList extends StatelessWidget {
  final List<Task> childTasks;
  final bool isLoading;
  final Function(Task) onTaskTap;

  const ChildTasksList({
    super.key,
    required this.childTasks,
    required this.isLoading,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.list_alt, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Text(
                    '子任务 (${childTasks.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (childTasks.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '暂无子任务',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: childTasks.length,
                itemBuilder: (context, index) {
                  return _buildChildTaskItem(childTasks[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildTaskItem(Task childTask) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        color: Colors.white,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getStatusColor(childTask.status).withOpacity(0.1),
            border: Border.all(
              color: _getStatusColor(childTask.status).withOpacity(0.3),
            ),
          ),
          child: Icon(
            _getStatusIcon(childTask.status),
            size: 20,
            color: _getStatusColor(childTask.status),
          ),
        ),
        title: Text(
          childTask.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (childTask.description?.isNotEmpty == true) ...[
              const SizedBox(height: 4),
              Text(
                childTask.description!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                _buildPriorityChip(childTask.priority),
                const SizedBox(width: 8),
                if (childTask.dueDate != null)
                  Text(
                    _formatDate(childTask.dueDate!),
                    style: TextStyle(
                      fontSize: 12,
                      color: childTask.dueDate!.isBefore(DateTime.now())
                          ? Colors.red
                          : Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: _buildStatusChip(childTask.status),
        onTap: () => onTaskTap(childTask),
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

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
