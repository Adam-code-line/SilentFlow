import 'package:flutter/material.dart';
import '../../models/task_model.dart';

/// 任务卡片组件 - 统一的任务显示样式
class TaskCard extends StatelessWidget {
  final Task task;
  final bool isMyTask;
  final bool isSubTask;
  final bool isInProjectCard;
  final VoidCallback? onTap;
  final PopupMenuItemBuilder<String>? menuBuilder;
  final ValueChanged<String>? onMenuSelected;

  const TaskCard({
    super.key,
    required this.task,
    this.isMyTask = false,
    this.isSubTask = false,
    this.isInProjectCard = false,
    this.onTap,
    this.menuBuilder,
    this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isProject = task.level == TaskLevel.project;

    // 根据层级确定样式
    Color? borderColor;
    double elevation = 1;
    EdgeInsets margin = const EdgeInsets.only(bottom: 12);
    IconData leadingIcon;
    Color leadingIconColor;

    if (isProject && !isInProjectCard) {
      borderColor = colorScheme.primary;
      elevation = 4;
      leadingIcon = Icons.folder;
      leadingIconColor = colorScheme.primary;
    } else if (isSubTask) {
      leadingIcon = Icons.subdirectory_arrow_right;
      leadingIconColor = colorScheme.tertiary;
      margin = const EdgeInsets.only(bottom: 8, left: 8, right: 8);
    } else {
      leadingIcon = Icons.assignment;
      leadingIconColor = colorScheme.secondary;
    }

    return Container(
      margin: margin,
      child: Card(
        elevation: elevation,
        child: Container(
          decoration: borderColor != null && !isInProjectCard
              ? BoxDecoration(
                  border: Border.all(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: ListTile(
            contentPadding: EdgeInsets.all(isSubTask ? 12 : 16),
            leading: Icon(leadingIcon,
                color: leadingIconColor, size: isSubTask ? 20 : 24),
            title: _buildTitle(context, isProject, isSubTask, colorScheme),
            subtitle: _buildSubtitle(isProject, isSubTask),
            trailing: _buildTrailing(),
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, bool isProject, bool isSubTask,
      ColorScheme colorScheme) {
    return Row(
      children: [
        if (isProject && !isInProjectCard)
          const Icon(Icons.star, color: Colors.amber, size: 16),
        if (isProject && !isInProjectCard) const SizedBox(width: 4),
        if (isSubTask)
          const Icon(Icons.arrow_right, color: Colors.grey, size: 16),
        if (isSubTask) const SizedBox(width: 4),
        Expanded(
          child: Text(
            task.title,
            style: TextStyle(
              fontWeight: isProject
                  ? FontWeight.w700
                  : isSubTask
                      ? FontWeight.w500
                      : FontWeight.bold,
              fontSize: isProject
                  ? 16
                  : isSubTask
                      ? 13
                      : 14,
              color: isProject ? colorScheme.primary : null,
            ),
          ),
        ),
        if (!isInProjectCard) TaskLevelChip(level: task.level),
        if (!isInProjectCard) const SizedBox(width: 8),
        TaskStatusChip(status: task.status),
      ],
    );
  }

  Widget _buildSubtitle(bool isProject, bool isSubTask) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (task.description != null) ...[
          const SizedBox(height: 8),
          Text(
            task.description!,
            maxLines: isProject
                ? 3
                : isSubTask
                    ? 1
                    : 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: isSubTask ? 12 : 14),
          ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text('${task.estimatedMinutes}分钟',
                style: TextStyle(fontSize: isSubTask ? 11 : 12)),
            const SizedBox(width: 12),
            Icon(Icons.flag, size: 14, color: _getPriorityColor(task.priority)),
            const SizedBox(width: 4),
            Text(task.priority.displayName,
                style: TextStyle(fontSize: isSubTask ? 11 : 12)),
          ],
        ),
      ],
    );
  }

  Widget? _buildTrailing() {
    if (isMyTask && menuBuilder != null) {
      return PopupMenuButton<String>(
        onSelected: onMenuSelected,
        itemBuilder: menuBuilder!,
      );
    } else if (!isMyTask) {
      return IconButton(
        icon: const Icon(Icons.assignment_turned_in),
        onPressed: onTap,
      );
    }
    return null;
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return Colors.red;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.low:
        return Colors.green;
    }
  }
}

/// 任务层级标签组件
class TaskLevelChip extends StatelessWidget {
  final TaskLevel level;

  const TaskLevelChip({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color chipColor;
    String chipText;
    IconData chipIcon;

    switch (level) {
      case TaskLevel.project:
        chipColor = colorScheme.primary;
        chipText = '项目';
        chipIcon = Icons.folder;
        break;
      case TaskLevel.task:
        chipColor = colorScheme.secondary;
        chipText = '任务';
        chipIcon = Icons.assignment;
        break;
      case TaskLevel.taskPoint:
        chipColor = colorScheme.tertiary;
        chipText = '任务点';
        chipIcon = Icons.task_alt;
        break;
    }

    return Chip(
      avatar: Icon(chipIcon, size: 16, color: Colors.white),
      label: Text(
        chipText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

/// 任务状态标签组件
class TaskStatusChip extends StatelessWidget {
  final TaskStatus status;

  const TaskStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case TaskStatus.pending:
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case TaskStatus.inProgress:
        color = Colors.blue;
        icon = Icons.play_arrow;
        break;
      case TaskStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case TaskStatus.blocked:
        color = Colors.red;
        icon = Icons.block;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            _getStatusText(status),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
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
        return '被阻塞';
    }
  }
}
