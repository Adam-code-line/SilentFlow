import 'package:flutter/material.dart';
import '../../../models/task_model.dart';

class ProjectOverviewCard extends StatelessWidget {
  final Task? teamProject;

  const ProjectOverviewCard({
    super.key,
    required this.teamProject,
  });

  @override
  Widget build(BuildContext context) {
    if (teamProject == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.folder, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  '团队项目',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                _buildStatusChip(teamProject!.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              teamProject!.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (teamProject!.description != null) ...[
              const SizedBox(height: 4),
              Text(
                teamProject!.description!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${teamProject!.estimatedMinutes}分钟'),
                const SizedBox(width: 16),
                Icon(Icons.flag,
                    size: 16, color: _getPriorityColor(teamProject!.priority)),
                const SizedBox(width: 4),
                Text(teamProject!.priority.displayName),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(TaskStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case TaskStatus.pending:
        color = Colors.orange;
        text = '待处理';
        icon = Icons.schedule;
        break;
      case TaskStatus.inProgress:
        color = Colors.blue;
        text = '进行中';
        icon = Icons.play_arrow;
        break;
      case TaskStatus.completed:
        color = Colors.green;
        text = '已完成';
        icon = Icons.check_circle;
        break;
      case TaskStatus.blocked:
        color = Colors.red;
        text = '被阻塞';
        icon = Icons.block;
        break;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.grey;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.urgent:
        return Colors.red;
    }
  }
}
