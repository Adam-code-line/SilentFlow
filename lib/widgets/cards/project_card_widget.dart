import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import 'task_card_widget.dart';

/// 项目卡片组件 - 包含子任务的项目展示
class ProjectCard extends StatelessWidget {
  final Task project;
  final List<Task> allTasks;
  final bool isMyTask;
  final void Function(Task, String) onTaskAction;
  final VoidCallback? onClaimTask;
  final VoidCallback? onShowDetails;

  const ProjectCard({
    super.key,
    required this.project,
    required this.allTasks,
    required this.isMyTask,
    required this.onTaskAction,
    this.onClaimTask,
    this.onShowDetails,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // 查找属于这个项目的子任务
    final projectSubTasks =
        allTasks.where((t) => t.parentTaskId == project.id).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // 项目主体
            TaskCard(
              task: project,
              isMyTask: isMyTask,
              isInProjectCard: true,
              onTap: onShowDetails,
              menuBuilder: isMyTask ? _buildProjectMenu : null,
              onMenuSelected:
                  isMyTask ? (value) => onTaskAction(project, value) : null,
            ),

            // 项目的子任务
            if (projectSubTasks.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                ),
                child: Text(
                  '子任务 (${projectSubTasks.length})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              ...projectSubTasks.map((subTask) => Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: TaskCard(
                      task: subTask,
                      isMyTask: isMyTask,
                      isSubTask: true,
                      onTap: () => onShowDetails?.call(),
                      menuBuilder: isMyTask ? _buildSubTaskMenu : null,
                      onMenuSelected: isMyTask
                          ? (value) => onTaskAction(subTask, value)
                          : null,
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildProjectMenu(BuildContext context) {
    return [
      const PopupMenuItem(value: 'create_subtask', child: Text('创建子任务')),
      if (project.status == TaskStatus.pending)
        const PopupMenuItem(value: 'start', child: Text('开始任务')),
      if (project.status == TaskStatus.inProgress)
        const PopupMenuItem(value: 'complete', child: Text('完成任务')),
      if (project.status == TaskStatus.inProgress)
        const PopupMenuItem(value: 'block', child: Text('标记阻塞')),
      const PopupMenuItem(value: 'details', child: Text('查看详情')),
    ];
  }

  List<PopupMenuEntry<String>> _buildSubTaskMenu(BuildContext context) {
    return [
      if (project.status == TaskStatus.pending)
        const PopupMenuItem(value: 'start', child: Text('开始任务')),
      if (project.status == TaskStatus.inProgress)
        const PopupMenuItem(value: 'complete', child: Text('完成任务')),
      if (project.status == TaskStatus.inProgress)
        const PopupMenuItem(value: 'block', child: Text('标记阻塞')),
      const PopupMenuItem(value: 'details', child: Text('查看详情')),
    ];
  }
}
